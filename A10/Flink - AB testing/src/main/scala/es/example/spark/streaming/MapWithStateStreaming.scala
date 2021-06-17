package es.example.spark.streaming


import es.example.spark.SparkHelper
import es.example.spark.streaming.model.{UserEvent, UserSession}
import org.apache.spark.streaming._
import org.json4s._
import org.json4s.jackson.JsonMethods._


/**
  * Agregacion de sesiones de usuario usando Spark Streaming
  *
  * Usage: MapWithStateStreaming <hostname> <port>
  * <hostname> y <port> definen el socket TCP al que conectarse.
  */
object MapWithStateStreaming {

  def main(args: Array[String]): Unit = {
    if (args.length < 2) {
      System.err.println("Usage: MapWithStateStreaming <hostname> <port>")
      System.exit(1)
    }

    val sparkSession = SparkHelper.getAndConfigureSparkSession(Some("Spark sessions"), master = Some("local[2]"))
    sparkSession.sparkContext.setLogLevel("ERROR")

    val ssc = StreamingContext.getOrCreate("./checkpoint", () => {
      val ssc = new StreamingContext(sparkSession.sparkContext, Seconds(5))
      ssc.checkpoint("./checkpoint")

      val stateSpec =
        StateSpec
          .function(updateUserEvents _)
          //.initialState(rdd) // Se podria haber definido un estado inicial a partir de un rdd
          .timeout(Minutes(1)) // Puedes hacer el timeout global para el estado DE TODAS LAS CLAVES configurable

      val sessions = ssc
        .socketTextStream(args(0), args(1).toInt)
        .flatMap(deserializeUserEvent)
        .map(u => (u.id, u))
        .mapWithState(stateSpec)

      sessions.foreachRDD { rdd =>
          if (!rdd.isEmpty()) {
            rdd.foreach(maybeUserSession => maybeUserSession.foreach {
              userSession =>
                // Store user session here
                println(userSession)
            })
          }
        }

      // sessions.stateSnapshots(), you can optionally create a snapshot of the state in an external system

      ssc
    })

    ssc.start()
    ssc.awaitTermination()
  }

  // general decode method
  def decode[T: Manifest](jsonStr: String): Option[T] = {
    implicit val formats = org.json4s.DefaultFormats
    parse(jsonStr).extractOpt[T]
  }


  def deserializeUserEvent(json: String): Option[UserEvent] = {
    try {
        decode[UserEvent](json)
    }catch {
      case _ : Throwable => None//(UserEvent.empty.id, UserEvent.empty)
    }
  }

  def updateUserEvents(key: Int,
                       value: Option[UserEvent],
                       state: State[UserSession]): Option[UserSession] = {
    def updateUserSessions(newEvent: UserEvent): Option[UserSession] = {
      val existingEvents: Seq[UserEvent] =
        state
          .getOption()
          .map(_.userEvents)
          .getOrElse(Seq[UserEvent]())

      val updatedUserSessions = UserSession(newEvent +: existingEvents)

      updatedUserSessions.userEvents.find(_.isLast) match {
        case Some(_) =>
          state.remove()
          Some(updatedUserSessions)
        case None =>
          state.update(updatedUserSessions)
          None
      }
    }

    value match {
      case Some(newEvent) => updateUserSessions(newEvent)
      case _ if state.isTimingOut() => state.getOption()
    }
  }
}

