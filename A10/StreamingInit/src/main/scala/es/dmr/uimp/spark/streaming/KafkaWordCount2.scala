package es.dmr.uimp.spark.streaming

import org.apache.kafka.common.serialization.StringDeserializer
import org.apache.spark.SparkConf
import org.apache.spark.streaming.kafka010.ConsumerStrategies.Subscribe
import org.apache.spark.streaming.kafka010.KafkaUtils
import org.apache.spark.streaming.kafka010.LocationStrategies.PreferConsistent
import org.apache.spark.streaming.{Seconds, StreamingContext}

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

    val words = lines.flatMap(_.split(" "))
    
    /* Hemos duplicado la clase KafkaWordCount.scala, y ahora vamos a cambiar el cálculo sobre el
    pipeline de Kafka. Generamos un evento por cada aparición de un término
    */
    val wordDstream = words.map(x => (x, 1)) 
    
    // Creamos una función que suma evento cada vez que estos entren en la ventana
    val addCount = (x: Int, y: Int) => x + y
    
    /**
    Añadadimos una función que elimina conteos que caigan fuera de la ventana cuando
    esta se mueva hacia delante
    */
    val removeCount = (x: Int, y: Int) => x - y
    
    /**
    Añadimos una función que filtra términos que hayan desaparecido. Esto nos ayuda
    a que la memoria del cálculo en el cluster no crezca indefinidamente y sin
    necesidad
    */
    val filterEmpty = (x: (String, Int)) => x._2 != 0
    
    // Conectamos el cálculo a la entrada e imprimimos el resultado
    val runningCountStream = wordDstream.reduceByKeyAndWindow(addCount, removeCount, Seconds(10), Seconds(1), 2, filterEmpty)

    runningCountStream.print()
    ssc.start()
    ssc.awaitTermination()
  }
}
