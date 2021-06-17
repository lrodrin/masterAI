package es.example.spark.streaming.model

case class UserEvent(id: Int, data: String, isLast: Boolean)

object UserEvent {
  lazy val empty = UserEvent(-1, "", isLast = false)
}
