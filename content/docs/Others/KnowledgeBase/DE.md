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
- Kafka: CP 성향 (리더 선출 시 일시적 가용성 저하 허용)
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
🎯 면접 포인트
{{% /hint %}}
### Normalize / Denormalize
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트
{{% /hint %}}

### ELT vs ETL
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트
{{% /hint %}}
### 배치 vs 스트리밍
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트
{{% /hint %}}
### 멱등성
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트
{{% /hint %}}
### 샤딩

{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트
{{% /hint %}}

### 복제
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트
{{% /hint %}}

### Consistency vs Latency 트레이드오프
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트
{{% /hint %}}
### Eventual Consistency
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트
{{% /hint %}}

### Throughput vs Latency
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}

## 🏗️ 2. 데이터 모델링 & 스키마
### Fact & Dimension
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### SCD
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}

### Schema Evolution
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### Star vs Snowflake
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### 데이터 타입 최적화
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### 스키마 레지스트리
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### Data Vault
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}


## 🔧 3. 데이터 처리 & 최적화
### Backfilling
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### 파티셔닝
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### CDC
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### 인덱싱 전략
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### 압축 포맷 (Parquet, ORC)
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### 파티션 프루닝
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}

### 조인 최적화
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### 벡터화
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### Columnar Storage
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}

## 🏢 4. 모던 데이터 플랫폼 & 거버넌스
### 데이터 마트 / 레이크하우스
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### Data Mesh / Discovery / Hub
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### Data Catalog
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### 데이터 품질
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### Lineage
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### Governance
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### Metadata 관리
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### Data Contract
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}

## ⚡ 5. Kafka
### KRaft vs Zookeeper
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### 파티션 전략
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### 컨슈머 그룹 & 오프셋
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### Exactly once
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### Schema Registry
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### Kafka Connect
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### 트랜잭션 & 멱등성
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### Backpressure
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}

## 🚀 6. Spark
### Tungsten
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### RDD vs DF vs DS
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### 파티셔닝 전략
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### 조인 방식 (Broadcast, Shuffle)
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}

### DPP (동적 파티션 프루닝)
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}### AQE

### Catalyst
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### 스트리밍
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### Checkpointing
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}

## 🌊 7. Flink
### 이벤트 시간 vs 처리 시간
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### Watermark
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### 윈도우 연산
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### Checkpointing & Savepoint
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### 백프레셔 (Backpressure)
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### 정확히 한 번 처리
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### 상태 관리 (State Backend)
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### CEP (Complex Event Processing)
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}

## 🗄️ 8. 테이블 포맷 (Iceberg & Delta Lake)
### ACID 트랜잭션
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### 시간 여행 (Time Travel)
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### 스키마 진화
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### 파티션 진화
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### 압축 (Compaction)
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### 메타데이터 관리
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### Z-ordering
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### 동시성 제어
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### 증분 읽기
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)

{{% /hint %}}


## 🌊 9. Airflow
### 여러 Executor
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### DAG 설계 전략
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### XCom
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### Branching
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### Sensor
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### Hook
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### SubDAG
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### 동적 DAG
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
{{% /hint %}}
### Backfill
{{% hint info %}}
📌 핵심 정의
💡 실무 포인트
🎯 면접 포인트 (있을 경우)
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
