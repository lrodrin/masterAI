resolvers += "Spark Packages Repo" at "https://dl.bintray.com/spark-packages/maven"

organization := "es.uimp.dmr"
name := "anomalyDetection"

version := "1.0"

scalaVersion := "2.11.12"
val sparkVersion = "2.4.4"

libraryDependencies ++= {
  Seq(
    "org.apache.spark" %% "spark-core" % sparkVersion % "provided",
    "org.apache.spark" %% "spark-sql" % sparkVersion % "provided",
    "org.apache.spark" %% "spark-streaming-kafka-0-8" % sparkVersion,
    "org.apache.spark" %% "spark-mllib" % sparkVersion % "provided",
    "com.databricks" %% "spark-csv" % "1.5.0",
    "org.slf4j" % "slf4j-simple" % "1.7.2",
    "com.univocity" % "univocity-parsers" % "1.5.1"
  )
}

assemblyMergeStrategy in assembly := {
  case PathList("org", "aopalliance", xs@_*) => MergeStrategy.last
  case PathList("javax", "inject", xs@_*) => MergeStrategy.last
  case PathList("javax", "servlet", xs@_*) => MergeStrategy.last
  case PathList("javax", "activation", xs@_*) => MergeStrategy.last
  case PathList("org", "apache", xs@_*) => MergeStrategy.last
  case PathList("com", "google", xs@_*) => MergeStrategy.last
  case PathList("com", "esotericsoftware", xs@_*) => MergeStrategy.last
  case PathList("com", "codahale", xs@_*) => MergeStrategy.last
  case PathList("com", "yammer", xs@_*) => MergeStrategy.last
  case "module-info.class" => MergeStrategy.discard
  case "git.properties" => MergeStrategy.discard
  case "about.html" => MergeStrategy.rename
  case "META-INF/ECLIPSEF.RSA" => MergeStrategy.last
  case "META-INF/mailcap" => MergeStrategy.last
  case "META-INF/mimetypes.default" => MergeStrategy.last
  case "plugin.properties" => MergeStrategy.last
  case "log4j.properties" => MergeStrategy.last
  case x =>
    val oldStrategy = (assemblyMergeStrategy in assembly).value
    oldStrategy(x)
}

