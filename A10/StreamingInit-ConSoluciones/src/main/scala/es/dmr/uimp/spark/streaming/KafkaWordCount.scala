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
object KafkaWordCount {
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
    val wordsDstream = words.map(x => (x, 1))
      .reduceByKey(_ + _)
      .map { case (k: String, c: Int) => (k, (c, 1)) }

    val mappingFunc = (word: String, c: Option[(Int, Int)], state: State[(Float, Int)]) => {
      val s = state.getOption.getOrElse((0.0f, 0))
      val v = c.getOrElse((0, 0))
      val sum = s._1 * s._2 + v._1
      val count = s._2 + v._2

      if (count == 0) {
        val output = (0.0f, count)
        state.update(output)
        (word, output)
      } else {
        val output = (sum / count.toFloat, count)
        state.update(output)
        (word, output)
      }
    }
    val stateDstream = wordsDstream.mapWithState(StateSpec.function(mappingFunc))

    stateDstream.print()
    ssc.start()
    ssc.awaitTermination()
  }
}
