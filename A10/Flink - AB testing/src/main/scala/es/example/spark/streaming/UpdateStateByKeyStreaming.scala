package es.example.spark.streaming

import es.example.spark.SparkHelper
import org.apache.spark.storage.StorageLevel
import org.apache.spark.streaming.{Seconds, StreamingContext}


/**
  * Ejemplo manejo de estado ad hoc
  *
  * Uso: Main <hostname> <port> <hostname2> <port2>
  * <hostname> y <port> describen el servidor TCP en el que Spark Streaming estara esperando por datos
  *
  * Para ejecutar, primero ejecute un Netcat server
  *    `$ nc -lk 9999`
  * y luego conecte el ejemplo
  */
object UpdateStateByKeyStreaming {
  def main(args: Array[String]): Unit = {
    if (args.length < 2) {
      System.err.println("uso: UpdateStateByKeyStreaming <host> <puerto>")
      System.exit(1)
    }

    // Create the context with a 1 second batch size
    val sparkSession = SparkHelper.getAndConfigureSparkSession(Some("Spark Literature"), master = Some("local[2]"))
    sparkSession.sparkContext.setLogLevel("ERROR")

    val ssc = StreamingContext.getOrCreate("./checkpoint", () => {
      val ssc = new StreamingContext(sparkSession.sparkContext, Seconds(5))
      ssc.checkpoint("./checkpoint")
      val lines = ssc.socketTextStream(args(0), args(1).toInt, StorageLevel.MEMORY_AND_DISK_SER)
      val words = lines.flatMap(_.split(" "))

      def updateRunningCount(values: Seq[Int], previous : Option[Long]) = {
        Some(previous.getOrElse(0L) + values.size)
      }
      val wordCounts = words.map(x => (x, 1)).updateStateByKey(updateRunningCount)
      wordCounts.print()

      ssc
    })

    ssc.start()
    ssc.awaitTermination()
  }
}
