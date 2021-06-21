#!/bin/bash

sh /opt/Kafka/kafka_2.11-2.3.0/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic cancelaciones --from-beginning &
sh /opt/Kafka/kafka_2.11-2.3.0/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic facturas_erroneas --from-beginning &
sh /opt/Kafka/kafka_2.11-2.3.0/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic anomalias_kmeans --from-beginning &
sh /opt/Kafka/kafka_2.11-2.3.0/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic anomalias_bisect_kmeans --from-beginning &
sh /opt/Kafka/kafka_2.11-2.3.0/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic purchases --from-beginning &