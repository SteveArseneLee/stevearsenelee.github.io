+++
title = "DE 기본 용어 정리"
draft = false
+++

# 📘 데이터 엔지니어링 및 플랫폼 용어 정리집
✅ 키워드
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트

## 📊 1. 데이터 아키텍처 & 설계
### 행/열 기반 (Row vs Column)
{{% hint info %}}
📌 핵심 정의
- Row-based: 데이터를 행 단위로 저장. OLTP 시스템에 최적화됨. (e.g. MySQL, PostgreSQL)
- Column-based: 데이터를 열 단위로 저장. OLAP 시스템 및 분석에 최적화됨.(e.g. Parquet, ORC, ClickHouse)

💡 실무 포인트
- Row-based: 전체 행 단위로 읽고 쓰므로 실시간 트랜잭션에 적합
- Column-based: Parquet, ORC, ClickHouse, Druid → 분석 쿼리에 유리
- 압축률: 컬럼 기반이 동일 데이터 타입 연속 저장으로 압축률 높음
- Columnar DB는 벡터화, late materialization 같은 쿼리 최적화 전략과 궁합이 좋음

🎯 면접 포인트
- "왜 데이터 웨어하우스에서는 컬럼 기반을 선호하나요?" → 분석 성능 최적화를 위해 I/O 비용 최소화 가능
{{% /hint %}}

### CAP
{{% hint info %}}
📌 핵심 정의  
분산 시스템에서는 세 가지 속성 중 두 가지까지만 동시에 보장할 수 있음:

- Consistency (C): 모든 노드가 같은 데이터를 읽음
- Availability (A): 모든 요청에 대해 응답을 반환함
- Partition Tolerance (P): 네트워크 단절 상황에서도 시스템이 작동 가능

💡 실무 포인트
- Kafka: 상황별로 CP/AP 선택 (브로커 장애 시 CP, 네트워크 분할 시 AP)
    - 브로커 장애 시: CP (일관성 우선, 가용성 일시 저하)
    - 파티션 분할 시: AP (가용성 우선, 일관성 eventual)
- Cassandra: AP 시스템 (높은 가용성, 일시적 불일치 허용)
- Zookeeper: CP 시스템 (일관성 중심)

🎯 면접 포인트  
- "Kafka는 CAP에서 어떤 선택을 했나요?" → Partition 상황에서 Consistency를 유지하고 Availability를 잠시 희생 (CP)
{{% /hint %}}

### OLTP vs OLAP
{{% hint info %}}
📌 핵심 정의  
- OLTP: 실시간 트랜잭션 처리. 다중 사용자 환경에 적합
- OLAP: 대규모 데이터 집계 및 분석에 적합. 다차원 쿼리 처리

💡 실무 포인트
- OLTP: 정규화 스키마, 낮은 지연, 강한 일관성 (예: 은행 시스템)
- OLAP: 비정규화, 데이터 마트/웨어하우스에서 사용 (예: 판매 분석)

🎯 면접 포인트
- "OLTP 데이터를 OLAP로 어떻게 변환하나요?" → ETL/ELT로 정제 → 모델링 → 적재
{{% /hint %}}

### Normalize / Denormalize
{{% hint info %}}
📌 핵심 정의  
- 정규화 (Normalization): 데이터 중복 제거, 무결성 보장, 테이블 분해 중심
- 비정규화 (Denormalization): 쿼리 최적화를 위해 의도적 중복 허용

💡 실무 포인트
- OLTP 시스템: 정규화 (데이터 무결성과 저장 공간 절약)
- OLAP 시스템: 비정규화 (조인 최소화로 빠른 쿼리)

🎯 면접 포인트
- "분석 환경에서 비정규화를 선택하는 이유는?" → 다량의 조인을 피하고 쿼리 응답 시간을 줄이기 위함
{{% /hint %}}

### ELT vs ETL
{{% hint info %}}
📌 핵심 정의
- ETL: 데이터를 추출 → 변환 → 적재 (전통적인 방식)
- ELT: 데이터를 추출 → 적재 → 변환 (클라우드 시대 등장)

💡 실무 포인트
- ETL: Spark, Informatica, Talend 등에서 사용
- ELT: BigQuery, Snowflake 등에서 Push-down 방식으로 처리
- ELT는 유연성과 유지보수성이 높고, 스토리지 가격 하락으로 부담 적음

🎯 면접 포인트
- "ELT가 최근 더 선호되는 이유는?" → Cloud DWH의 성능 향상 + 저장 비용 하락 + 유연한 쿼리 모델
{{% /hint %}}

### 배치 vs 스트리밍
{{% hint info %}}
📌 핵심 정의
- 배치: 데이터가 일정 기간 동안 누적된 후 일괄 처리
- 스트리밍: 데이터가 도착하자마자 실시간 처리됨

💡 실무 포인트
- 배치: 대량 처리, 정확성 중요, Spark, Airflow, Hive
- 스트리밍: 실시간 반응, Kafka, Flink, Spark Structured Streaming

🎯 면접 포인트
- "스트리밍이 필요한 대표적인 사례는?" → 실시간 사기 탐지, 실시간 로그 모니터링, IoT 데이터 분석 등
{{% /hint %}}

### 멱등성(idempotence)
{{% hint info %}}
📌 핵심 정의
- 같은 연산을 여러 번 적용해도 결과가 동일한 성질

💡 실무 포인트
- ETL/ELT 재시도 시 동일 결과 보장 필요
- Upsert 또는 Merge 전략, 멱등 키(idempotent key) 활용

🎯 면접 포인트
"왜 데이터 파이프라인에서 멱등성이 중요할까?" → 장애 발생 시 중복 실행에 대한 안전성 확보를 위해 필수
{{% /hint %}}

### 샤딩
{{% hint info %}}
📌 핵심 정의
- 하나의 테이블을 여러 물리적 노드로 분산해 저장하여 확장성과 처리량을 확보하는 방식

💡 실무 포인트
- 샤드 키: 균등 분포 + 쿼리 효율성 고려
- 크로스 샤드 연산은 복잡하고 비용 증가
- MongoDB, Elasticsearch 등에서 널리 사용

🎯 면접 포인트
- "샤드 키는 어떻게 고르는가?" → 균등 분산, 불변성, 쿼리 접근 패턴을 만족해야 함
{{% /hint %}}

### 복제
{{% hint info %}}
📌 핵심 정의
- 데이터의 고가용성(HA)을 보장하기 위해 복수의 노드에 데이터를 복사하는 기술

💡 실무 포인트
- 읽기 확장 (Read Replica)
- 장애 복구 (Failover)
- 이중화, Multi-region 복제 등으로 활용

🎯 면접 포인트
- "복제 지연이 발생했을 때 어떻게 대응하나요?" → 읽기 일관성 조절, Staleness 허용 여부 판단
{{% /hint %}}

### Consistency vs Latency 트레이드오프
{{% hint info %}}
📌 핵심 정의
- 일관성 보장을 강화하면, 일반적으로 응답 시간(latency)은 늘어남

💡 실무 포인트
- Redis: strong consistency (LAT ↑)
- DynamoDB: eventual consistency (LAT ↓)
- DB마다 조절 가능한 읽기 일관성 옵션 존재

🎯 면접 포인트
- "분산 캐시 시스템에서 어떤 일관성 수준이 필요한가요?" → 캐시 특성상 latency 우선, 일관성 희생 가능
{{% /hint %}}

### Eventual Consistency
{{% hint info %}}
📌 핵심 정의
- 시간이 지나면 결국 모든 복제 노드에 동일한 데이터가 반영됨을 보장

💡 실무 포인트
- DNS, SNS 좋아요 수 등 실시간 정합성 불필요한 서비스에 적합
- Write Fast, Read Eventually Accurate 전략

🎯 면접 포인트
- "최종 일관성이 적용된 시스템 예시는?" → SNS 좋아요 수, 쇼핑몰 상품 찜 수 등
{{% /hint %}}

### Throughput vs Latency
{{% hint info %}}
📌 핵심 정의
- Throughput: 초당 처리 가능한 작업량
- Latency: 단일 요청 처리에 걸리는 시간

💡 실무 포인트
- Throughput 중심: 배치 파이프라인 (Spark)
- Latency 중심: 실시간 응답 (REST API, Kafka)
- Kafka: 파티션 증가 → 처리량 증가, 단 latency 증가 가능

🎯 면접 포인트
- "Kafka에서 Throughput을 높이는 방법은?" → batch.size, linger.ms 조정 + 압축 활성화 + 파티션 수 증가
{{% /hint %}}

## 🏗️ 2. 데이터 모델링 & 스키마
### Fact & Dimension
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}

### SCD
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}

### Schema Evolution
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### Star vs Snowflake
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### 데이터 타입 최적화
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### 스키마 레지스트리
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### Data Vault
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}


## 🔧 3. 데이터 처리 & 최적화
### Backfilling
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### 파티셔닝
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### CDC
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### 인덱싱 전략
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### 압축 포맷 (Parquet, ORC)
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### 파티션 프루닝
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}

### 조인 최적화
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### 벡터화
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### Columnar Storage
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}

## 🏢 4. 모던 데이터 플랫폼 & 거버넌스
### 데이터 마트 / 레이크하우스
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### Data Mesh / Discovery / Hub
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### Data Catalog
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### 데이터 품질
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### Lineage
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### Governance
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### Metadata 관리
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### Data Contract
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}

## ⚡ 5. Kafka
### KRaft vs Zookeeper
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### 파티션 전략
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### 컨슈머 그룹 & 오프셋
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### Exactly once
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### Schema Registry
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### Kafka Connect
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### 트랜잭션 & 멱등성
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### Backpressure
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}

## 🚀 6. Spark
### Tungsten
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### RDD vs DF vs DS
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### 파티셔닝 전략
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### 조인 방식 (Broadcast, Shuffle)
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}

### DPP (동적 파티션 프루닝)
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}### AQE

### Catalyst
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### 스트리밍
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### Checkpointing
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}

## 🌊 7. Flink
### 이벤트 시간 vs 처리 시간
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### Watermark
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### 윈도우 연산
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### Checkpointing & Savepoint
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### 백프레셔 (Backpressure)
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### 정확히 한 번 처리
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### 상태 관리 (State Backend)
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### CEP (Complex Event Processing)
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}

## 🗄️ 8. 테이블 포맷 (Iceberg & Delta Lake)
### ACID 트랜잭션
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### 시간 여행 (Time Travel)
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### 스키마 진화
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### 파티션 진화
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### 압축 (Compaction)
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### 메타데이터 관리
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### Z-ordering
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### 동시성 제어
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### 증분 읽기
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 

{{% /hint %}}


## 🌊 9. Airflow
### 여러 Executor
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### DAG 설계 전략
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### XCom
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### Branching
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### Sensor
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### Hook
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### SubDAG
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### 동적 DAG
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}
### Backfill
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 
{{% /hint %}}

## 📈 10. 모니터링 & 관찰가능성
### 파이프라인 모니터링
{{% hint info %}}

{{% /hint %}}
### 메트릭 수집 (Prometheus, Grafana)
{{% hint info %}}

{{% /hint %}}
### 로그 집계
{{% hint info %}}

{{% /hint %}}
### 분산 추적
{{% hint info %}}

{{% /hint %}}
### SLA/SLO
{{% hint info %}}

{{% /hint %}}
### 데이터 드리프트
{{% hint info %}}

{{% /hint %}}

## ☁️ 11. 클라우드 & 인프라
### K8s 기반 파이프라인
{{% hint info %}}

{{% /hint %}}
### Serverless
{{% hint info %}}

{{% /hint %}}
### 컨테이너 오케스트레이션
{{% hint info %}}

{{% /hint %}}
### 멀티 클라우드
{{% hint info %}}

{{% /hint %}}
### 비용 최적화
{{% hint info %}}

{{% /hint %}}

## 🧪 12. 테스팅 & 품질
### 파이프라인 테스트 전략
{{% hint info %}}

{{% /hint %}}
### 데이터 검증 / 프로파일링
{{% hint info %}}

{{% /hint %}}
### 품질 메트릭
{{% hint info %}}

{{% /hint %}}
### A/B 테스팅 인프라
{{% hint info %}}

{{% /hint %}}
