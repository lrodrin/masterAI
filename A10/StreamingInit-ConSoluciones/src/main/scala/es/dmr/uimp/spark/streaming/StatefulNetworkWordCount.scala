package es.dmr.uimp.spark.streaming

import org.apache.spark.SparkConf
import org.apache.spark.streaming.{Seconds, State, StateSpec, StreamingContext}

/**
 * Cuenta las palabras recibidas por red.
 *
 * Uso: NetworkWordCount <ip> <puerto>
 * <ip> y <puerto> describe la direccion TCP a la que se 
 * conecta Spark Streaming para recibir datos 
 *
 */
object StatefulNetworkWordCount {
  def main(args: Array[String]) {
    if (args.length < 2) {
      System.err.println("Usage: StatefulNetworkWordCount <hostname> <port>")
      System.exit(1)
    }

    // Introduzca su codigo aqui
    val sparkConf = new SparkConf().setAppName("StatefulNetworkWordCount")
    val ssc = new StreamingContext(sparkConf, Seconds(1))
    ssc.sparkContext.setLogLevel("WARN")
    ssc.checkpoint("./checkpoint")
    val lines = ssc.socketTextStream(args(0), args(1).toInt)
    val words = lines.flatMap(_.split(" "))
    val wordsDstream = words.map(x => (x, 1))
    val mappingFunc = (word: String, one: Option[Int], state: State[Int]) => {
      val sum = one.getOrElse(0) + state.getOption.getOrElse(0)
      val output = (word, sum)
      state.update(sum)
      output
    }
    val initialRDD = ssc.sparkContext.parallelize(List(("hello", 1), ("world", 1)))
    val stateDstream = wordsDstream.mapWithState(
      StateSpec.function(mappingFunc).initialState(initialRDD)
    )

    stateDstream.print()
    ssc.start()
    ssc.awaitTermination()
  }
}
