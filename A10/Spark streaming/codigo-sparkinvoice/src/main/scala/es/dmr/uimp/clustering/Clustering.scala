package es.dmr.uimp.clustering

import java.io.{BufferedWriter, File, FileWriter}

import org.apache.commons.lang3.StringUtils
import org.apache.spark.SparkContext
import org.apache.spark.mllib.linalg.{Vector, Vectors}
import org.apache.spark.rdd.RDD
import org.apache.spark.sql.{DataFrame, SQLContext}
import org.apache.spark.sql.functions._

import scala.collection.mutable.ArrayBuffer

/**
 * Created by root on 3/12/17.
 */
object Clustering {
  /**
   * Load data from file, parse the data and normalize the data.
   */
  def loadData(sc: SparkContext, file: String): DataFrame = {
    val sqlContext = new SQLContext(sc)

    // Function to extract the hour from the date string
    val gethour = udf[Double, String]((date: String) => {
      var out = -1.0
      if (!StringUtils.isEmpty(date)) {
        val hour = date.substring(10).split(":")(0)
        if (!StringUtils.isEmpty(hour))
          out = hour.trim.toDouble
      }
      out
    })

    // Load the csv data
    val df = sqlContext.read
      .format("com.databricks.spark.csv")
      .option("header", "true") // Use first line of all files as header
      .option("inferSchema", "true") // Automatically infer data types
      .load(file)
      .withColumn("Hour", gethour(col("InvoiceDate")))

    df
  }

  def featurizeData(df: DataFrame): DataFrame = {
    df.groupBy("InvoiceNo").agg(
      mean("UnitPrice").alias("AvgUnitPrice"),
      min("UnitPrice").alias("MinUnitPrice"),
      max("UnitPrice").alias("MaxUnitPrice"),
      first("Hour").alias("Time"),
      sum("Quantity").alias("NumberItems")
    )
  }

  def filterData(df: DataFrame): DataFrame = {
    df.filter(not(substring(column("InvoiceNo"), 0, 1).equalTo("C"))
      .and(column("AvgUnitPrice").isNotNull)
      .and(column("MinUnitPrice").isNotNull)
      .and(column("MaxUnitPrice").isNotNull)
      .and(column("Time").isNotNull)
      .and(column("NumberItems").isNotNull)
    )
  }

  def toDataset(df: DataFrame): RDD[Vector] = {
    val data = df.select("AvgUnitPrice", "MinUnitPrice", "MaxUnitPrice", "Time", "NumberItems").rdd
      .map(row => {
        val buffer = ArrayBuffer[Double]()
        buffer.append(row.getAs("AvgUnitPrice"))
        buffer.append(row.getAs("MinUnitPrice"))
        buffer.append(row.getAs("MaxUnitPrice"))
        buffer.append(row.getAs("Time"))
        buffer.append(row.getLong(4).toDouble)
        val vector = Vectors.dense(buffer.toArray)
        vector
      })

    data
  }

  def elbowSelection(costs: Seq[Double], ratio: Double): Int = {
    costs.toList.sliding(2).map {
      case x :: y :: _ => y.toDouble / x.toDouble
      case _ => 0.0
    }.indexWhere(x => x > ratio) + 2
  }

  def saveThreshold(threshold: Double, fileName: String) = {
    val file = new File(fileName)
    val bw = new BufferedWriter(new FileWriter(file))
    // decide threshold for anomalies
    bw.write(threshold.toString) // last item is the threshold
    bw.close()
  }

}
