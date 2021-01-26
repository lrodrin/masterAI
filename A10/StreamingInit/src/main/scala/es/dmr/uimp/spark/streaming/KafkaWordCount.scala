package es.dmr.uimp.spark.streaming

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
  }
}
