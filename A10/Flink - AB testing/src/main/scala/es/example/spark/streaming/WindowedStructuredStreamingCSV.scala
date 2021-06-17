package es.example.spark.streaming

import es.example.spark.SparkHelper
import org.apache.spark.sql.types.StructType
import org.apache.spark.sql.functions._

/**
  * Ejemplo de uso de structured streaming
  *
  * Uso: Main <directory>
  * <directory> es la carpeta donde se estara esperando por datos
  * <modo> describe la politica de update de la query continua de spark structured streaming
  *
  * Para ejecutar, deje en el directorio ficheros csv con el formato especificado
  * y luego conecte el ejemplo
  */
object WindowedStructuredStreamingCSV {
  def main(args: Array[String]): Unit = {
    if (args.length < 2) {
      System.err.println("uso: StructuredStreamingCSV <directory> <modo>")
      System.exit(1)
    }

    // Create the context with a 1 second batch size
    val sparkSession = SparkHelper.getAndConfigureSparkSession(Some("Spark Literature"), master = Some("local[2]"))
    sparkSession.sparkContext.setLogLevel("ERROR")

    //----------- Bloque de entrada -----------
    val userSchema = new StructType().add("name", "string").add("message", "string").add("timestamp", "timestamp")
    val messages = sparkSession
      .readStream
      .option("sep", ",")
      .option("timestampFormat", "yyyy-MM-dd hh:mm:ss")
      .schema(userSchema) // Esquema de los datos de entrada
      .csv(args(0))    // Directorio donde se reciben los datos

    //----------- Definicion de tablas continuas -----------
    import sparkSession.implicits._
    // Generate running word count
    val messageCount = messages
      .withWatermark(eventTime = "timestamp", delayThreshold = "1 minutes")
      .groupBy(
        window(timeColumn = $"timestamp", windowDuration = "1 minutes", slideDuration = "30 seconds"),
        $"name")
      .count()

    //----------- Bloque de salida -----------
    val query = messageCount.writeStream
      .outputMode(args(1))
      .format("console")
      .start()

    query.awaitTermination()
  }
}
