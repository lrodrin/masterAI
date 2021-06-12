# Spark Streaming

- [Spark: 2.0.0](https://spark.apache.org/releases/spark-release-2-0-0.html)
- [Scala: 2.11](https://www.scala-lang.org/download/2.11.12.html)

Para compilar el proyecto basta con ejecutar el siguiente comando desde el directorio del proyecto:
```bash
sbt clean assembly
```

A continuación, arrancamos los servidores de [Zookeeper](https://zookeeper.apache.org/) y [Kafka](https://kafka.apache.org/):
```bash
cd /opt/Kafka/kafka_2.11-2.3.0/
sudo bin/zookeeper-server-start.sh config/zookeeper.properties &
sudo bin/kafka-server-start.sh config/server.properties &
```

Definimos los `topics`: cancelaciones, facturas_erroneas, anomalias_kmeans y anomalias_bisect_kmeans.
```bash
bin/kafka-topics.sh --create --zookeeper localhost:2181 --topic cancelaciones --replication-factor 1 --partitions 3
bin/kafka-topics.sh --create --zookeeper localhost:2181 --topic facturas_erroneas --replication-factor 1 --partitions 3
bin/kafka-topics.sh --create --zookeeper localhost:2181 --topic anomalias_kmeans --replication-factor 1 --partitions 3
bin/kafka-topics.sh --create --zookeeper localhost:2181 --topic anomalias_bisect_kmeans --replication-factor 1 --partitions 3
```

Utilizamos la opción --list de `kafka-topics.sh`para verificar que el topic se ha creado correctamente.
```bash
bin/kafka-topics.sh --list --zookeeper localhost:2181
```
Para consumir los `topics` definidos, ejecutamos:
```bash
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic cancelaciones --from-beginning
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic facturas_erroneas --from-beginning
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic anomalias_kmeans --from-beginning
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic anomalias_bisect_kmeans --from-beginning
```

## Entrenamiento

Efectuamos el entrenamiento de Kmeans y BisectionKmeans:
```bash
chmod +x execute.sh
chmod +x start_pipeline.sh
./start_pipeline.sh
```

Una vez finalizado el entrenamiento, se deberan haber creado las siguientes carpetas y archivos:

- clustering/
- clustering_bisect/
- threshold
- threshold_bisect

## Simulación

Añadimos "purchases" en el cluster Kafka y ejecutamos el simulador de compras:
```bash
bin/kafka-topics.sh --create --zookeeper localhost:2181 --topic purchases --replication-factor 1 --partitions 3
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic purchases --from-beginning
chmod +x productiondata.sh
./productiondata.sh
```

Una vez que se está ejecutando la aplicación de análisis de transmisión, podemos ejecutar la pipeline:
```bash
chmod +x start_pipeline.sh
./start_pipeline.sh
```

