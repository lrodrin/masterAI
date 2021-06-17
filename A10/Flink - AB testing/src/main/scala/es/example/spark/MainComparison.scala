package es.example.spark
import scala.io.Source

/**
  * Compara el uso de lenguaje en la obra de Edgar Allan Poe con la obra de Jane Austen
  *
  * Usage: Main [file]
  *
  * donde [file] es el lugar donde esta el fichero con la obra
  */
object MainComparison {
  def main(args: Array[String]): Unit = {

    if (args.length < 3) {
      System.err.println("uso: Main <file-stopwords> <file-poe> <file-poe2> <file-austen>")
      System.exit(1)
    }

    // Load the stopwords
    val source = Source.fromFile(args(0))
    val stopWords = source.getLines().map(_.toUpperCase).toList
    source.close()

    // Create the context with a 1 second batch size
    val sparkSession = SparkHelper.getAndConfigureSparkSession()
    val ssc = sparkSession.sparkContext
    val bcStopWords = ssc.broadcast(stopWords)


    val wordCountsPoe1 = ssc.textFile(args(1))
      .flatMap(_.split(" "))
      .map(x => x.replaceAll("\\W", "").toUpperCase)
    val wordCountsPoe2 = ssc.textFile(args(2))
      .flatMap(_.split(" "))
      .map(x => x.replaceAll("\\W", "").toUpperCase)

     val poeLanguage = wordCountsPoe1.union(wordCountsPoe2)
       .filter(w => !bcStopWords.value.contains(w))
       .map(x => (x, 1))
       .reduceByKey(_ + _)

    val austenLanguage = ssc.textFile(args(3))
      .flatMap(_.split(" "))
      .map(x => x.replaceAll("\\W", "").toUpperCase)
      .union(wordCountsPoe2)
      .filter(w => !bcStopWords.value.contains(w))
      .map(x => (x, 1))
      .reduceByKey(_ + _)

    val commonVocabulary = austenLanguage.join(poeLanguage)

    println("Poe language")
    println(poeLanguage.collect().sortBy(_._2).reverse.take(50).toList)
    println("Austen language")
    println(austenLanguage.collect().sortBy(_._2).reverse.take(50).toList)
    println("Common language")
    println(commonVocabulary.collect().sortBy(_._2).reverse.take(50).toList)
  }
}
