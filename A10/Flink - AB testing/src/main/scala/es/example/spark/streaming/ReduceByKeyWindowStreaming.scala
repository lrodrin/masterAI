package es.example.spark.streaming

import es.example.spark.SparkHelper
import org.apache.spark.storage.StorageLevel
import org.apache.spark.streaming.{Seconds, StreamingContext}


/**
  * Ejemplo de operacion por clave y ventana temporal
  *
  * Uso: Main <hostname> <port> <hostname2> <port2>
  * <hostname> y <port> describen el servidor TCP en el que Spark Streaming estara esperando por datos
  *
  * Para ejecutar, primero ejecute un Netcat server
  *    `$ nc -lk 9999`
  * y luego conecte el ejemplo
  */
object ReduceByKeyWindowStreaming {
  def main(args: Array[String]): Unit = {
    if (args.length < 2) {
      System.err.println("uso: ReduceByKeyWindowStreaming <host> <puerto>")
      System.exit(1)
    }

    // Create the context with a 1 second batch size
    val sparkSession = SparkHelper.getAndConfigureSparkSession(Some("Spark Literature"), master = Some("local[2]"))
    val ssc = new StreamingContext(sparkSession.sparkContext, Seconds(5))

    val lines = ssc.socketTextStream(args(0), args(1).toInt, StorageLevel.MEMORY_AND_DISK_SER)
    val words = lines.flatMap(_.split(" "))
    val wordCounts = words.map(x => (x, 1)).reduceByKeyAndWindow(_ + _, _ - _, Seconds(10), Seconds(5))
    wordCounts.print()
    ssc.start()
    ssc.awaitTermination()
  }
}
