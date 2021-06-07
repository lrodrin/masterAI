# Spark Streaming

## Conteo de palabras en stream

Para ejecutar la pipeline, primero se tiene que abrir un servidor en el que enviar datos. Para ello ejecutar:
```bash
$ nc -l 19999
```

Compilar la aplicación y ejecutar. Antes comprobar que la pipeline se ejecutará a un cluster local. Para hacerlo en un cluster remoto, solo habría que cambiar el argumento master.
```bash
$ sbt clean assembly
$ chmod +x execute.sh 
$ ./execute.sh es.dmr.uimp.spark.streaming.NetworkWordCount localhost 19999 
```

## Conteo total de palabras

Esta pipeline funciona igual que el ejemplo anterior, solo se tiene que cambiar la clase `NetworkWordCount` por `StatefulNetworkWordCount`.
```bash
$ nc -l 19999
$ sbt clean assembly
$ ./execute.sh es.dmr.uimp.spark.streaming.StatefulNetworkWordCount localhost 19999 
```

## Integrar Spark con Kafka

Arrancar Kafka, servidores de Zookeeper y Kafka en dos sessiones diferentes.
```bash
$ cd /opt/Kafka/kafka_2.11-2.3.0/
$ sudo bin/zookeeper-server-start.sh config/zookeeper.properties & 
$ sudo bin/kafka-server-start.sh config/server.properties & 
```
Define un topic.

1. Utilizar el script `kafka-topics.sh` para crear un nuevo topic.
```bash
 $ bin/kafka-topics.sh --create bin/kafka-topics.sh --topic my_topic --partitions 1 --replication-factor 1 --zookeeper localhost:2181
```
2. Utilizar la opción --list de `kafka-topics.sh`para verificar que el topic se ha creado correctamente:
```bash
$ bin/kafka-topics.sh --list --zookeeper localhost:2181
```
3. Prueba el topic.

Ejecuta el siguiente comando, que permite enviar mensajes a un tema desde la consola:
```bash
$ bin/kafka-console-producer.sh --broker-list localhost:9092 --topic my_topic
```
- Escribe un texto y pulsa Enter. Cada línea de texto envía un mensaje a my_topic.
- Pulsa `Ctrl + c` para detener el proceso.

Para consumir los mensajes escritos, ejecuta el programa siguiente:
```bash
$ bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic my_topic --from-beginning
```
- Se deberían ver los mensajes que se escribieron anteriormente.
- Pulsa `Ctrl + c` para detener el proceso.

Ejecuta la pipeline:

- Añade "sentences" en el cluster Kafka.
- Introduce datos utilizando `kafka-console-producer.sh`.
- Compila el proyecto y ejecuta la pipeline.
```bash
$ sbt clean assembly
$ ./execute.sh es.dmr.uimp.spark.streaming.KafkaWordCount localhost:9092 kafkaConsumer sentences 1
```

## Cálculos de ventana en Spark Streaming

Ejecuta la pipeline:

- Introduce datos utilizando `kafka-console-producer.sh`. Mirar sección [Integrar Spark con Kafka](#integrar-spark-con-kafka).
- Compila el proyecto y ejecuta la pipeline.
```bash
$ sbt clean assembly
$ ./execute.sh es.dmr.uimp.spark.streaming.KafkaWordCount2 localhost:9092 kafkaConsumer sentences 1
```
