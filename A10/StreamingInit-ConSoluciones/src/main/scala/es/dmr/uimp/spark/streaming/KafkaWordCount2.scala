package es.dmr.uimp.spark.streaming

import org.apache.kafka.common.serialization.StringDeserializer
import org.apache.spark.SparkConf
import org.apache.spark.streaming.kafka010.ConsumerStrategies.Subscribe
import org.apache.spark.streaming.kafka010.KafkaUtils
import org.apache.spark.streaming.kafka010.LocationStrategies.PreferConsistent
import org.apache.spark.streaming.{Seconds, State, StateSpec, StreamingContext}

/**
 * Consume mensajes de uno o mas temas de Kafka
 * Uso: KafkaWordCount <zkQuorum> <group> <topics> <numTheads>
 *
 */
object KafkaWordCount2 {
  def main(args: Array[String]) {
    if (args.length < 4) {
      System.err.println("Uso: KafkaWordCount <zkQuorum> <group> <topics> <numTheads>")
      System.exit(1)
    }

    StreamingExamples.setStreamingLogLevels()

    // Introduzca su codigo aqui

    val sparkConf = new SparkConf().setAppName("KafkaNetworkWordCount")
    val ssc = new StreamingContext(sparkConf, Seconds(1))
    ssc.checkpoint("./checkpoint")

    val Array(zkQuorum, group, topics, numThreads) = args
    val topicMap = topics.split(",")

    val kafkaParams = Map[String, Object](
      "bootstrap.servers" -> zkQuorum,
      "key.deserializer" -> classOf[StringDeserializer],
      "value.deserializer" -> classOf[StringDeserializer],
      "group.id" -> group,
      "auto.offset.reset" -> "earliest",
      "enable.auto.commit" -> (false: java.lang.Boolean)
    )

    val lines = KafkaUtils.createDirectStream[String, String](
      ssc,
      PreferConsistent,
      Subscribe[String, String](topicMap, kafkaParams)
    ).map(_.value)

    val words = lines.flatMap(_.split(" "))
    val wordDstream = words.map(x => (x, 1))

    val addCount = (x: Int, y: Int) => x + y

    val removeCount = (x: Int, y: Int) => x - y

    val filterEmpty = (x: (String, Int)) => x._2 != 0

    val runningCountStream = wordDstream.reduceByKeyAndWindow(addCount, removeCount, Seconds(10), Seconds(1), 2, filterEmpty)

    runningCountStream.print()
    ssc.start()
    ssc.awaitTermination()
  }
}
