package es.dmr.uimp.spark.streaming

import org.apache.spark.SparkConf
import org.apache.spark.storage.StorageLevel
import org.apache.spark.streaming.{Seconds, StreamingContext}

/**
 * Cuenta las palabras recibidas por red.
 *
 * Uso: NetworkWordCount <ip> <puerto>
 * <ip> y <puerto> describe la direccion TCP a la que se 
 * conecta Spark Streaming para recibir datos 
 */
object NetworkWordCount {
  def main(args: Array[String]) {

    if (args.length < 2) {
      System.err.println("Uso: NetworkWordCount <hostname> <port>")
      System.exit(1)
    }

    StreamingExamples.setStreamingLogLevels()

    // Conéctese al cluster de Spark. Esta línea genérica serviría tanto para conectarse a un cluster (YARN/MESOS)
    // o para ejecutar en local. Sobre la conexión al cluster, creamos un StreamingContext, que nos permite la
    // planificación de trabajos continuamente
    val sparkConf = new SparkConf().setAppName("NetworkWordCount")
    val scc = new StreamingContext(sparkConf, Seconds(1))

    // Establezca los niveles de log para evaluar el funcionamiento continuo del pipeline. Observe que este método
    // que ya está incluido solamente incrementa el nivel de log hasta WARNING
    scc.sparkContext.setLogLevel("WARN")

    // Conecte la fuente de datos al socket. El host viene determinado por el primer argumento y el puerto por
    // el segundo. Los datos se van a mantener en memoria y disco de manera serializada para ahorrar espacio
    val lines = scc.socketTextStream(args(0), args(1).toInt, StorageLevel.MEMORY_AND_DISK_SER)

    // Divida los bloques de texto que llegan y cuente el número de palabras
    val words = lines.flatMap(_.split(" "))
    val wordCounts = words.map(x => (x, 1)).reduceByKey(_ + _)

    // Imprima el resultado por pantalla para poder evaluar el funcionamiento
    wordCounts.print()

    // Inicie la ejecución del pipeline.Este se mantendrá funcionando mientras se mantenga la conexión a la fuente
    // de datos o hasta que el trabajo sea terminado
    scc.start()
    scc.awaitTermination()


  }
}
