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
import org.apache.spark.rdd.RDD

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

    // TODO: Load model and broadcast
    val kMeansData = loadKMeansAndThreshold(sc, modelFile, thresholdFile)
    val kMeansModel: Broadcast[KMeansModel] = ssc.sparkContext.broadcast(kMeansData._1)
    val kMeansThreshold: Broadcast[Double] = ssc.sparkContext.broadcast(kMeansData._2)

    val bisectionKMeansData = loadBisectingKMeansAndThreshold(sc, modelFileBisect, thresholdFileBisect)
    val bisectionKMeans: Broadcast[BisectingKMeansModel] = ssc.sparkContext.broadcast(bisectionKMeansData._1)
    val bisectionThreshold: Broadcast[Double] = ssc.sparkContext.broadcast(bisectionKMeansData._2)

    val broadcastBrokers: Broadcast[String] = ssc.sparkContext.broadcast(brokers)

    // TODO: Build pipeline


    // connect to kafka
    val purchasesFeed = connectToPurchases(ssc, zkQuorum, group, topics, numThreads)
    val purchasesStream = getPurchasesStream(purchasesFeed)

    detectWrongPurchases(purchasesStream, broadcastBrokers)
    detectCancellations(purchasesStream, broadcastBrokers)

    // TODO: rest of pipeline

    ssc.start() // Start the computation
    ssc.awaitTermination()
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
   * Load the KMeans model information: centroid and threshold
   */
  def loadKMeansAndThreshold(sc: SparkContext, modelFile: String, thresholdFile: String): (KMeansModel, Double) = {
    val kmeans = KMeansModel.load(sc, modelFile)
    // parse threshold file
    val rawData = sc.textFile(thresholdFile, 20)
    val threshold = rawData.map { line => line.toDouble }.first()

    (kmeans, threshold)
  }

  /**
   * Load the KMeans bisection model information: centroid and threshold
   */
  def loadBisectingKMeansAndThreshold(sc: SparkContext, modelFile: String, thresholdFile: String): (BisectingKMeansModel, Double) = {
    val kmeans = BisectingKMeansModel.load(sc, modelFile)
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

  /**
   * Transforms the Kafka Stream into a new stream
   * with a the value parsed as a Purchase class
   */
  def getPurchasesStream(purchasesFeed: DStream[(String, String)]): DStream[(String, Purchase)] = {
    val purchasesStream = purchasesFeed.transform { inputRDD =>
      inputRDD.map { input =>
        val invoiceId = input._1
        val purchaseAsString = input._2

        val purchase = parsePurchase(purchaseAsString)

        (invoiceId, purchase)
      }
    }

    purchasesStream
  }

  /**
   * Given a purchases feed formatted as csv-like strings,
   * returns those purchases parsed as objects by using a
   * csv parser
   */
  def parsePurchase(purchase: String): Purchase = {
    val csvParserSettings = new CsvParserSettings()
    csvParserSettings.detectFormatAutomatically()

    val csvParser = new CsvParser(csvParserSettings)
    val parsedPurchase = csvParser.parseRecord(purchase)

    // Given a parsedPurchase object, create a Purchase object
    Purchase(
      parsedPurchase.getString(0),
      parsedPurchase.getInt(3),
      parsedPurchase.getString(4),
      parsedPurchase.getDouble(5),
      parsedPurchase.getString(6),
      parsedPurchase.getString(7)
    )
  }

  /**
   * Given a Purchase Stream, detects the wrong purchases (with any missing or wrong field)
   * and sends the feedback to the facturas_erroneas Kafka topic
   */
  def detectWrongPurchases(purchasesStream: DStream[(String, Purchase)], broadcastBrokers: Broadcast[String]): Unit = {
    purchasesStream
      .filter(tuple => isWrongPurchase(tuple._2))
      .transform { purchasesTupleRDD =>
        purchasesTupleRDD.map(purchase => (purchase._1, purchase._2.toString))
      }
      .foreachRDD { rdd =>
        publishToKafka("facturas_erroneas")(broadcastBrokers)(rdd)
      }
  }

  /**
   * Checks if the purchase has any missing or wrong property
   */
  def isWrongPurchase(purchase: Purchase): Boolean = {
    purchase.invoiceNo == null || purchase.invoiceDate == null || purchase.customerID == null ||
      purchase.invoiceNo.isEmpty || purchase.invoiceDate.isEmpty || purchase.customerID.isEmpty ||
      purchase.unitPrice.isNaN || purchase.quantity.isNaN || purchase.country.isEmpty ||
      purchase.unitPrice.<(0)
  }

  /**
   * Given a Purchase Stream, detects the cancellations (the quantity property is negative)
   * and calculates the number of cancellations for the last 8 minutes.
   * It gives this feedback to the cancelaciones Kafka topic every second
   */
  def detectCancellations(purchasesStream: DStream[(String, Purchase)], broadcastBrokers: Broadcast[String]): Unit = {
    purchasesStream
      .filter(tuple => tuple._2.quantity.<(0))
      .countByWindow(Minutes(8), Seconds(1))
      .transform { invoicesTupleRDD =>
        invoicesTupleRDD.map(count => (count.toString, count.toString))
      }
      .foreachRDD { rdd =>
        publishToKafka("cancelaciones")(broadcastBrokers)(rdd)
      }
  }

}
