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

    // Introduzca la conexión a Spark e inicie el entorno de Streaming
    val sparkConf = new SparkConf().setAppName("KafkaNetworkWordCount")
    val ssc = new StreamingContext(sparkConf, Seconds(1))

    // Añada un directorio de checkpoint para que el pipeline guarde el estado
    ssc.checkpoint("./checkpoint")

    /** Conéctese a Kafka. Para ello es necesario indicar: 
     * Dónde se encuentra el cluster de Zookeeper con la información acerca del cluster de Kafka
     * y todos los topics, partitions, etc
     * El identificador de consumer group que los lectores van a compartir
     * La lista de temas de la que se quieren consumir mensajes
     * El número de consumidores que van a leer de Kafka y crear el Dstream
     */
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

    /** Ahora vamos a realizar el cálculo de la media de apariciones. Para ello, vamos
     * a hacer un calculo rolling. Cada RDD de entrada es un batch de 1 segundo y lo
     * que queremos es tener el número de apariciones por segundo. Por lo tanto, por
     * cada batch se genera un valor
     */
    val words = lines.flatMap(_.split(" "))
    val wordsDstream = words.map(x => (x, 1))
      .reduceByKey(_ + _)
      .map { case (k: String, c: Int) => (k, (c, 1)) }

    /**
     * Ahora vamos a hacer el calculo de la media. En cada batch se genera un valor
     * con clave con (count, 1). Para hacer el calculo de la media, los estadísticos
     * suficientes son (media actual, numero de batches). En base a esto se puede
     * hacer la actualización
     */
    val mappingFunc = (word: String, c: Option[(Int, Int)], state:
    State[(Float, Int)]) => {
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

    // Conecte el calculo de la media de apariciones con el stream de entrada
    val stateDstream = wordsDstream.mapWithState(StateSpec.function(mappingFunc))

    // Imprima el resultado y comience la ejecución del pipeline de cálculo
    stateDstream.print()
    ssc.start()
    ssc.awaitTermination()
  }
}
