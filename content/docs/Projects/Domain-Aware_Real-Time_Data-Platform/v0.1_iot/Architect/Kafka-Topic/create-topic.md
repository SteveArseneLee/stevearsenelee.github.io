### Broker 접속
```sh
# Kafka Pod에 접속해서 실행 (예: steve-kafka-kafka-pool-dual-role-0)
kubectl -n kafka exec -ti steve-kafka-kafka-pool-dual-role-0 -- bash
```

### Fact Topics
```sh
bin/kafka-topics.sh --create --topic iot.equipment_metrics --bootstrap-server localhost:9092 --partitions 6 --replication-factor 3
bin/kafka-topics.sh --create --topic iot.qc_result --bootstrap-server localhost:9092 --partitions 3 --replication-factor 3
bin/kafka-topics.sh --create --topic iot.energy_usage --bootstrap-server localhost:9092 --partitions 3 --replication-factor 3
bin/kafka-topics.sh --create --topic iot.robot_status --bootstrap-server localhost:9092 --partitions 3 --replication-factor 3
bin/kafka-topics.sh --create --topic iot.environmental_readings --bootstrap-server localhost:9092 --partitions 3 --replication-factor 3
bin/kafka-topics.sh --create --topic iot.device_status --bootstrap-server localhost:9092 --partitions 3 --replication-factor 3
```

### Dimension Topics
```sh
bin/kafka-topics.sh --create --topic dim.equipment --bootstrap-server localhost:9092 --partitions 1 --replication-factor 3
bin/kafka-topics.sh --create --topic dim.product --bootstrap-server localhost:9092 --partitions 1 --replication-factor 3
bin/kafka-topics.sh --create --topic dim.process --bootstrap-server localhost:9092 --partitions 1 --replication-factor 3
bin/kafka-topics.sh --create --topic dim.inspection --bootstrap-server localhost:9092 --partitions 1 --replication-factor 3
bin/kafka-topics.sh --create --topic dim.location --bootstrap-server localhost:9092 --partitions 1 --replication-factor 3
bin/kafka-topics.sh --create --topic dim.sensor --bootstrap-server localhost:9092 --partitions 1 --replication-factor 3
bin/kafka-topics.sh --create --topic dim.factory --bootstrap-server localhost:9092 --partitions 1 --replication-factor 3
bin/kafka-topics.sh --create --topic dim.employee --bootstrap-server localhost:9092 --partitions 1 --replication-factor 3
bin/kafka-topics.sh --create --topic dim.defect_code --bootstrap-server localhost:9092 --partitions 1 --replication-factor 3
```