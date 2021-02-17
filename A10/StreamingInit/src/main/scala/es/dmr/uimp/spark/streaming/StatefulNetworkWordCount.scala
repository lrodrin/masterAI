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

    StreamingExamples.setStreamingLogLevels()

    // Establezca la conexión con Spark y el entorno de Streaming
    val sparkConf = new SparkConf().setAppName("StatefulNetworkWordCount")
    val ssc = new StreamingContext(sparkConf, Seconds(1))

    // Configure el nivel de log
    ssc.sparkContext.setLogLevel("WARN")

    // En este ejercicio, la pipeline va a mantener una cuenta total del número de veces que un término ha aparecido
    // en el stream. Para que la computación sea fiable, es necesario que periódicamente se haga un backup del estado
    // del pipeline. Establecemos la localización donde este backup se va a mantener
    ssc.checkpoint("./checkpoint")

    // Creamos una conexión al socket y distribuimos las palabras encontradas
    val lines = ssc.socketTextStream(args(0), args(1).toInt)
    val words = lines.flatMap(_.split(" "))
    val wordsDstream = words.map(x => (x, 1))

    // Construimos la actualización del conteo total. En paraello, es necesario una función que toma como entrada
    // la clave, el valor y el estado actual para esa clave, y lleva a cabo la actualización. La salida es el
    // nuevo valor para el estado
    val mappingFunc = (word: String, one: Option[Int], state:
    State[Int]) => {
      val sum = one.getOrElse(0) + state.getOption.getOrElse(0)
      val output = (word, sum)
      state.update(sum)
      output
    }

    // Conectamos la actualización del valor con el origen de datos
    // Comenzamos con un estado inicial
    val initialRDD = ssc.sparkContext.parallelize(List(("hello", 1), ("world", 1)))

    // Conectamos el calculo con el stream de entrada
    val stateDstream = wordsDstream.mapWithState(
      StateSpec.function(mappingFunc).initialState(initialRDD)
    )

    // Mostramos el nuevo estado por pantalla
    stateDstream.print()

    // Arrancamos la pipeline
    ssc.start()
    ssc.awaitTermination()
  }
}
