#!/bin/bash
CLASS=$1 
shift
spark-submit --class $CLASS --master local[4] target/scala-2.11/spark-streaming-exercises-assembly-0.0.1.jar $@
