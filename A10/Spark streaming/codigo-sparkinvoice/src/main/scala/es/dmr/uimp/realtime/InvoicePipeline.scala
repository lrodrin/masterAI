package es.dmr.uimp.realtime

import org.apache.commons.lang3.StringUtils
import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
import org.apache.spark.mllib.clustering._
import org.apache.spark.streaming._
import org.apache.spark.streaming.dstream.DStream
import org.apache.spark.streaming.kafka.KafkaUtils
import org.apache.kafka.clients.producer.{KafkaProducer, ProducerConfig, ProducerRecord}

import java.util.HashMap
import com.univocity.parsers.csv.{CsvParser, CsvParserSettings}
import es.dmr.uimp.clustering.KMeansClusterInvoices
import org.apache.spark.broadcast.Broadcast
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.util.Saveable
import org.apache.spark.rdd.RDD

import scala.collection.mutable.ArrayBuffer

object InvoicePipeline {

  case class Purchase(invoiceNo: String, quantity: Int, invoiceDate: String,
                      unitPrice: Double, customerID: String, country: String)

  case class Invoice(invoiceNo: String, avgUnitPrice: Double,
                     minUnitPrice: Double, maxUnitPrice: Double, time: Double,
                     numberItems: Double, lastUpdated: Long, lines: Int, customerId: String)


  def main(args: Array[String]) {

    val Array(modelFile, thresholdFile, modelFileBisect, thresholdFileBisect, zkQuorum, group, topics, numThreads, brokers) = args
    val sparkConf = new SparkConf().setAppName("InvoicePipeline")
    val sc = new SparkContext(sparkConf)
    val ssc = new StreamingContext(sc, Seconds(20))

    // Checkpointing
    ssc.checkpoint("./checkpoint")

    val KMeans = loadKMeansAndThreshold(sc, modelFile, thresholdFile)
    val KMeansModel = ssc.sparkContext.broadcast(KMeans._1)
    val KMeansThreshold = ssc.sparkContext.broadcast(KMeans._2)

    val KMeansBisect = loadKMeansAndThreshold(sc, modelFileBisect, thresholdFileBisect)
    val KMeansBisectModel: Broadcast[BisectingKMeansModel] = ssc.sparkContext.broadcast(KMeansBisect._1)
    val KMeansBisectThreshold: Broadcast[Double] = ssc.sparkContext.broadcast(KMeansBisect._2)

    val broadcastBrokers: Broadcast[String] = ssc.sparkContext.broadcast(brokers)

    // Connect to kafka
    val purchasesFeed: DStream[(String, String)] = connectToPurchases(ssc, zkQuorum, group, topics, numThreads)
    val purchasesStream = getpurchasesStream(purchasesFeed)

    detectCancelPurchases(purchasesStream, broadcastBrokers)
    detectWrongPurchases(purchasesStream, broadcastBrokers)

    val invoices: DStream[(String, Invoice)] = purchasesStream
      .filter(data => !isWrongPurchase(data._2))
      .window(Seconds(40), Seconds(1))
      .updateStateByKey(updateFunc = calculateInvoice)

    val anomalies = isAnomaly(KMeansModel, KMeansBisectModel, KMeansThreshold, KMeansBisectThreshold)(_, _)
    detectAnomaly(invoices, "kmeans", broadcastBrokers)(anomalies)
    detectAnomaly(invoices, "bisection", broadcastBrokers)(anomalies)

    ssc.start() // Start the computation
    ssc.awaitTermination()
  }

  def getpurchasesStream(purchasesFeed: DStream[(String, String)]): DStream[(String, Purchase)] = {
    val purchasesStream = purchasesFeed.transform { inputRDD =>
      inputRDD.map { input =>
        val invoiceID = input._1
        val purchaseAsString = input._2

        val purchase = parsePurchase(purchaseAsString)

        (invoiceID, purchase)
      }
    }
    purchasesStream
  }

  def parsePurchase(purchase: String): Purchase = {
    val csvParserSettings = new CsvParserSettings()
    val csvParser = new CsvParser(csvParserSettings)
    val parsedPurchase = csvParser.parseRecord(purchase)

    Purchase(
      parsedPurchase.getString(0),
      parsedPurchase.getInt(3),
      parsedPurchase.getString(4),
      parsedPurchase.getDouble(5),
      parsedPurchase.getString(6),
      parsedPurchase.getString(7)
    )
  }

  def detectCancelPurchases(purchaseStream: DStream[(String, Purchase)], broadcastBrokers: Broadcast[String]): Unit = {
    purchaseStream
      .filter(data => data._2.invoiceNo.startsWith("C"))
      .countByWindow(Minutes(8), Minutes(1))
      .transform { invoicesTupleRDD =>
        invoicesTupleRDD.map(count => (count.toString, "The number of invoices cancelled are: " + count.toString))
      }
      .foreachRDD { rdd =>
        publishToKafka("cancelledPurchases")(broadcastBrokers)(rdd)
      }
  }

  def detectWrongPurchases(purchaseStream: DStream[(String, Purchase)], broadcastBrokers: Broadcast[String]): Unit = {
    purchaseStream
      .filter(data => isWrongPurchase(data._2))
      .transform { rdd =>
        rdd.map(purchase => (purchase._1, "The invoice " + purchase._1 + "contains wrong purchases."))
      }
      .foreachRDD { rdd =>
        publishToKafka("wrongPurchases")(broadcastBrokers)(rdd)
      }
  }

  def isWrongPurchase(purchase: Purchase): Boolean = {
    (purchase.invoiceNo == null || purchase.invoiceDate == null || purchase.customerID == null ||
      purchase.invoiceNo.isEmpty || purchase.invoiceDate.isEmpty || purchase.customerID.isEmpty || purchase.country.isEmpty ||
      purchase.unitPrice.isNaN || purchase.quantity.isNaN ||
      purchase.unitPrice.<(0)) && !purchase.invoiceNo.startsWith("C")
  }

  def calculateInvoice(newValues: Seq[Purchase], state: Option[Invoice]): Option[Invoice] = {
    val invoiceNo = newValues.head.invoiceNo
    val unitPrices = newValues.map(purchase => purchase.unitPrice)

    val avgUnitPrice = unitPrices.sum / unitPrices.length
    val minUnitPrice = unitPrices.min
    val maxUnitPrice = unitPrices.max
    val time = newValues.head.invoiceDate.split(' ')(1).split(':')(0).toDouble
    val numberItems = newValues.map(purchase => purchase.quantity).sum
    val customerID = newValues.head.customerID

    val lines = newValues.length
    val lastUpdated = 0

    Some(Invoice(invoiceNo, avgUnitPrice, minUnitPrice, maxUnitPrice, time, numberItems, lastUpdated, lines, customerID))
  }

  def detectAnomaly(invoices: DStream[(String, Invoice)], model: String, broadcastBrokers: Broadcast[String])
                   (anomalies: (Invoice, String) => Boolean) = {

    def sendInvoices(topic: String) = {
      invoices
        .filter { data =>
          anomalies(data._2, model)
        }
        .transform { rdd =>
          rdd.map(data => (data._1, "Anomaly detected by " + model + " inside invoice: " + data._1.toString))
        }
        .foreachRDD { rdd =>
          publishToKafka(topic)(broadcastBrokers)(rdd)
        }
    }

    if (model == "kmeans") {
      sendInvoices("anomalyKMeans")
    }
    else {
      sendInvoices("anomalyBisection")
    }
  }

  def isAnomaly(KMeansModel: Broadcast[KMeansModel], KMeansBisectModel: Broadcast[BisectingKMeansModel],
                KMeansThreshold: Broadcast[Double], KMeansBisectTreshold: Broadcast[Double])
               (invoice: Invoice, modelType: String): Boolean = {

    val features = ArrayBuffer[Double]()
    features.append(invoice.avgUnitPrice)
    features.append(invoice.minUnitPrice)
    features.append(invoice.maxUnitPrice)
    features.append(invoice.time)
    features.append(invoice.numberItems)

    val featuresVector = Vectors.dense(features.toArray)
    if (modelType == "kmeans") {
      val distanceKmeans = KMeansClusterInvoices.distToCentroid(featuresVector, KMeansModel.value)
      distanceKmeans > KMeansThreshold.value
    }
    else {
      val distancesBisect = KMeansClusterInvoices.distToCentroid(featuresVector, KMeansBisectModel.value)
      distancesBisect > KMeansBisectTreshold.value
    }
  }

  def publishToKafka(topic: String)(kafkaBrokers: Broadcast[String])(rdd: RDD[(String, String)]) = {
    rdd.foreachPartition(partition => {
      val producer = new KafkaProducer[String, String](kafkaConf(kafkaBrokers.value))
      partition.foreach(record => {
        producer.send(new ProducerRecord[String, String](topic, record._1, record._2.toString))
      })
      producer.close()
    })
  }

  def kafkaConf(brokers: String) = {
    val props = new HashMap[String, Object]()
    props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, brokers)
    props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, "org.apache.kafka.common.serialization.StringSerializer")
    props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, "org.apache.kafka.common.serialization.StringSerializer")
    props
  }

  /**
   * Load the model information: centroid and threshold
   */
  def loadKMeansAndThreshold(sc: SparkContext, modelFile: String, thresholdFile: String): Tuple2[KMeansModel, Double] = {
    val kmeans = KMeansModel.load(sc, modelFile)
    // parse threshold file
    val rawData = sc.textFile(thresholdFile, 20)
    val threshold = rawData.map { line => line.toDouble }.first()

    (kmeans, threshold)
  }


  def connectToPurchases(ssc: StreamingContext, zkQuorum: String, group: String,
                         topics: String, numThreads: String): DStream[(String, String)] = {

    ssc.checkpoint("checkpoint")
    val topicMap = topics.split(",").map((_, numThreads.toInt)).toMap
    KafkaUtils.createStream(ssc, zkQuorum, group, topicMap)
  }

}
