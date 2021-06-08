```bash
sbt clean assembly
```

```bash
cd /opt/Kafka/kafka_2.11-2.3.0/
sudo bin/zookeeper-server-start.sh config/zookeeper.properties
sudo bin/kafka-server-start.sh config/server.properties
```
```bash
bin/kafka-topics.sh --create --zookeeper localhost:2181 --topic cancelaciones --replication-factor 1 --partitions 3
bin/kafka-topics.sh --create --zookeeper localhost:2181 --topic facturas_erroneas --replication-factor 1 --partitions 3
bin/kafka-topics.sh --create --zookeeper localhost:2181 --topic anomalias_kmeans --replication-factor 1 --partitions 3
bin/kafka-topics.sh --create --zookeeper localhost:2181 --topic anomalias_bisect_kmeans --replication-factor 1 --partitions 3
```
```bash
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic cancelaciones --from-beginning
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic facturas_erroneas --from-beginning
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic anomalias_kmeans --from-beginning
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic anomalias_bisect_kmeans --from-beginning
```