#!/bin/bash

sh /opt/Kafka/kafka_2.11-2.3.0/bin/kafka-topics.sh --create --zookeeper localhost:2181 --topic cancelaciones --replication-factor 1 --partitions 3
sh /opt/Kafka/kafka_2.11-2.3.0/bin/kafka-topics.sh --create --zookeeper localhost:2181 --topic facturas_erroneas --replication-factor 1 --partitions 3
sh /opt/Kafka/kafka_2.11-2.3.0/bin/kafka-topics.sh --create --zookeeper localhost:2181 --topic anomalias_kmeans --replication-factor 1 --partitions 3
sh /opt/Kafka/kafka_2.11-2.3.0/bin/kafka-topics.sh --create --zookeeper localhost:2181 --topic anomalias_bisect_kmeans --replication-factor 1 --partitions 3
sh /opt/Kafka/kafka_2.11-2.3.0/bin/kafka-topics.sh --create --zookeeper localhost:2181 --topic purchases --replication-factor 1 --partitions 3

sh /opt/Kafka/kafka_2.11-2.3.0/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic cancelaciones --from-beginning
sh /opt/Kafka/kafka_2.11-2.3.0/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic facturas_erroneas --from-beginning
sh /opt/Kafka/kafka_2.11-2.3.0/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic anomalias_kmeans --from-beginning
sh /opt/Kafka/kafka_2.11-2.3.0/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic anomalias_bisect_kmeans --from-beginning
sh /opt/Kafka/kafka_2.11-2.3.0/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic purchases --from-beginning