package es.example.spark

import org.apache.spark.sql.SparkSession


object SparkHelper {
  def getAndConfigureSparkSession(appName : Option[String] = None, master: Option[String] = None): SparkSession = {

    master.map(
        SparkSession
          .builder()
          .appName(appName.getOrElse("Spark"))
          .master(_)
          .getOrCreate())
      .getOrElse(
        SparkSession
          .builder()
          .getOrCreate())
  }
}

