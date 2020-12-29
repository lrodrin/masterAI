package uimp.student;

case class Subject(name : String)

class Student(name : String) {

  def study(s : Subject) = {
    println(s"$name is studying ${s.name}")
  }
}
