package es.example.spark.streaming

import es.example.spark.SparkHelper


/**
  * Ejemplo de uso de structured streaming
  *
  * Uso: Main <hostname> <port> <hostname2> <port2>
  * <hostname> y <port> describen el servidor TCP en el que Spark Streaming estara esperando por datos
  * <modo> describe la politica de update de la query continua de spark structured streaming
  *
  * Para ejecutar, primero ejecute un Netcat server
  *    `$ nc -lk 9999`
  * y luego conecte el ejemplo
  */
object StructuredStreaming {
  def main(args: Array[String]): Unit = {
    if (args.length < 3) {
      System.err.println("uso: StructuredStreaming <host> <puerto> <modo>")
      System.exit(1)
    }

    // Create the context with a 1 second batch size
    val sparkSession = SparkHelper.getAndConfigureSparkSession(Some("Spark Literature"), master = Some("local[2]"))
    sparkSession.sparkContext.setLogLevel("ERROR")

    import sparkSession.implicits._

    //----------- Bloque de entrada -----------
    val lines = sparkSession.readStream
      .format("socket")
      .option("host", args(0))
      .option("port", args(1))
      .load()

    //----------- Definicion de tablas continuas -----------
    // Split the lines into words
    val words = lines.as[String].flatMap(_.split(" "))
    // Generate running word count
    val wordCounts = words.groupBy("value").count()

    //----------- Bloque de salida -----------
    val output = wordCounts.writeStream
      .outputMode(args(2))
      .format("console")

    val query = output.start()
    query.awaitTermination()
  }
}
