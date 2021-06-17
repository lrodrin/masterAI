package es.example.spark.streaming

import es.example.spark.SparkHelper
import es.example.spark.streaming.model.{UserEvent, UserSession}
import org.apache.spark.sql._
import org.apache.spark.sql.streaming.{GroupState, GroupStateTimeout, OutputMode}
import org.json4s.jackson.JsonMethods.parse

object MapGroupWithStateStreaming {

  implicit val userEventEncoder: Encoder[UserEvent] = Encoders.kryo[UserEvent]
  implicit val userSessionEncoder: Encoder[Option[UserSession]] = Encoders.kryo[Option[UserSession]]

  def main(args: Array[String]): Unit = {

    if (args.length < 2) {
      System.err.println("Usage: MapGroupWithStateStreaming <hostname> <port>")
      System.exit(1)
    }

    val host = args(0)
    val port = args(1).toInt

    val sparkSession = SparkHelper.getAndConfigureSparkSession(Some("Spark sessions structured"), master = Some("local[2]"))
    sparkSession.sparkContext.setLogLevel("ERROR")


    import sparkSession.implicits._

    val userEventsStream: Dataset[String] = sparkSession.readStream
      .format("socket")
      .option("host", host)
      .option("port", port)
      .load()
      .as[String]

    val finishedUserSessionsStream: Dataset[UserSession] =
      userEventsStream
        .map(deserializeUserEvent)
        .filter(_.id != UserEvent.empty.id)
        .groupByKey(_.id)
        .mapGroupsWithState(GroupStateTimeout.ProcessingTimeTimeout())(updateSessionEvents _)
        .flatMap(userSession => userSession)


    finishedUserSessionsStream.writeStream
      .outputMode(OutputMode.Update())
      .format("console")
      .option("checkpointLocation", "./checkpoint")
      .start()
      .awaitTermination()
  }

  def updateSessionEvents(id: Int, userEvents: Iterator[UserEvent],
                           state: GroupState[UserSession]): Option[UserSession] = {
    if (state.hasTimedOut) {
      // Si la sesion ha expirado, la eliminamos y la emitimos
      state.remove()
      state.getOption
    } else {
      /*
       Para cada nuevo evento, revisamos si ya hay una sesion, si no hay se crea con el nuevo evento. Si existe,
       se agregan los nuevos eventos a la sesion existente.
       */
      val currentState = state.getOption
      val updatedUserSession = currentState.fold(UserSession(userEvents.toSeq))(currentUserSession =>
        UserSession(currentUserSession.userEvents ++ userEvents.toSeq))
      state.update(updatedUserSession)

      if (updatedUserSession.userEvents.exists(_.isLast)) {
        // En el caso que nos indiquen que la sesion ha expirado, la eliminamos.del estado y emitimos la sesion

        val userSession = state.getOption
        state.remove()
        userSession
      } else {
        // En caso de que la sesion siga activa, la mantenemos durante otro minuto
        state.setTimeoutDuration("1 minute")
        None
      }
    }
  }

  // general decode method
  def decode[T: Manifest](jsonStr: String): Option[T] = {
    implicit val formats = org.json4s.DefaultFormats
    parse(jsonStr).extractOpt[T]
  }


  def deserializeUserEvent(json: String): UserEvent = {
    try {
      val userEvent = decode[UserEvent](json)
      userEvent.map(ue => ue).getOrElse(UserEvent.empty)
    }catch {
      case _ : Throwable => UserEvent.empty
    }
  }

}
