package uimp
import  uimp.student.{Subject, Student}

object Job2 {
    def main(args: Array[String]) = {
        val bd = Subject("Big Data")
        val student = new Student("Pepe Gotera")
        student.study(bd)
    }
}