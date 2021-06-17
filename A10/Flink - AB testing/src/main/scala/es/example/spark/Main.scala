package es.example.spark

/**
  * Cuenta las palabras en la obra de Edgar Allan Poe
  *
  * Usage: Main [file]
  *
  * donde [file] es el lugar donde esta el fichero con la obra
  */
object Main {
  def main(args: Array[String]): Unit = {

    if (args.length < 1) {
      System.err.println("uso: Main <file>")
      System.exit(1)
    }

    // Create the context
    val sparkSession = SparkHelper.getAndConfigureSparkSession(Some("Spark Literature"), master = Some("local[2]"))
    val ssc = sparkSession.sparkContext

    val lines = ssc.textFile(args(0))
    val words = lines.flatMap(_.split(" "))
    val wordCounts = words.map(x => (x.toUpperCase, 1)).reduceByKey(_ + _)
    println(wordCounts.collect().sortBy(_._2).reverse.take(20).toList)
  }
}
