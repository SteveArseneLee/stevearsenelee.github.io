+++
title = "Kafka의 데이터 구조"
draft = false
bookHidden = true
+++

Kafka의 메세지 저장 구조는 **논리적 구조**와 **물리적 구조**로 나눠서 생각하는 것이 좋다. Kafka는 단순한 message queue를 넘어서 ***Log-structured Storage***로 설계되어, 메세지의 저장 및 조회 방식이 일반적인 RDBMS나 단순 queueing system과는 다르다.

### 논리적 구조
```sh
Kafka Cluster
 └─ Topic
     └─ Partition (복수 개 가능)
         └─ Offset 기반 메시지 로그 (Append-Only)
```
🔹 Topic
- 논리적인 메시지 스트림 단위 (예: sensor-temperature, chat-logs 등)
- 실제 저장은 partition 단위로 이루어짐

🔹 Partition
- 메시지의 병렬 처리 단위
- 각 파티션은 내부적으로 append-only log로 구현됨
- 각 메시지는 Offset을 기준으로 순차적으로 저장됨
- 하나의 파티션은 한 번에 하나의 consumer에게만 할당됨 (Consumer Group 기준)


### 물리적 구조
```sh
/log.dirs/<topic>-<partition>/
 ├─ 00000000000000000000.log
 ├─ 00000000000000000000.index
 ├─ 00000000000000000000.timeindex
 ├─ 00000000000000010000.log
 ├─ 00000000000000010000.index
 ├─ ...
```
🔹 Segment (세그먼트)
- 파티션은 실제로 여러 개의 segment 파일로 구성됨
- 기본적으로 log.segment.bytes 설정 (기본값: 1GB)마다 새로운 세그먼트 파일 생성
- Partition당 오직 하나의 Segment가 Active 되어 있음
- 각 세그먼트는 다음 3가지 파일로 구성됨:

|File name| Description|
|-|-|
|.log| 메세지 본문이 저장된 파일|
|.index| offset -> file 위치 매핑(binary)|
|.timeindex| timestamp -> offset 매핑(시간 기준 조회용)|

![kafka segment](/dataengineering/kafka/kafka-segment.png)
