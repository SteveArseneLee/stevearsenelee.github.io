+++
title = "Data Engineer의 프트폴리오 작성법"
date = 2025-06-10
draft = false
+++
### 유념해야할 사항들
- 데이터를 이동하고 정리하는 방법을 알고 있음을 증명하는 ***production-level ETL pipeline***
- Fraud detection, chatbots, live dashboards를 지원할 수 있는 실시간 처리
- 비즈니스 요구 사항에 맞춰 확장되는 ***Cloud-native data warehousing***
- 단순히 도구를 사용하는 것이 아니라 ***도구를 개선한다는 오픈소스 증거***


# Portfolio Roadmap
## 1) "ETL 프로젝트가 없다면 이력서를 넘길 수 있음"
- 복원력(resilient) 있고 모듈식(modular)이며, 확장 가능한(scalable) 시스템을 구축할 수 있는 능력
- It's ELT-first
- It's cloud-native (serverless > monoliths)
- It's monitored, version-controlled, and productionized

### Production Code를 배포할 수 있다는 것을 보여주는 실제 ETL 프로젝트
- **다양한 소스 활용** : API, SQL dump, 공개 데이터셋, 로그 스트림 등 다양한 소스에서 데이터 수집.
- **의미있는 변환** : 데이터 유형 적용, 비즈니스 로직(fuzzy matching이나 join) 구현, 중복 제거 등.
- **증분 적재** : CDC를 이해하고 있음을 보여주기. 전체를 무차별 재처리하지 말기.
- **데이터 유효성 검사 계층** : 파이프라인이 단순히 실행되는 것뿐만 아니라 올바르게 실행되는지 검사
- **Workflow orchestration** : Airflow나 Prefect DAG를 설정하고, retries, alerting, modular task를 수행하기.

### Stack
- Airflow / Prefect - DAG orchestration (scheduling, dependencies, alerts)을 위해
- Spark / dbt / Pandas — 무거운 작업과 복잡한 변환을 위해
- AWS Glue / GCP Dataflow / Azure Data Factory - cloud-native
- BigQuery / Snowflake / Redshift / PostgreSQL — 정리된 데이터 적재
- Docker / Terraform - (선택사항) 인프라 기술을 보여줄 수 있다면 보여주기

### 경쟁력
- Observability : Log successes, failures, retries, and run durations
- Version data models : dbt나 schema migraion  전략을 사용해 장기적 관점 보여주기
- 확장성 최적화 : Partitioning, Batch strategies, 대량 sample 데이터셋으로 테스트
- System architect처럼 설계 : 다이어그램과 trade-off를 설명한 간단한 README 포함하기

{{% hint "info" %}}
**예시**
"3개의 API에서 기상 데이터를 수집하고, 정규화 및 병합하여 BigQuery에 120만 건의 일별 레코드를 파티션 테이블로 로드하는 Airflow 기반 ETL 파이프라인을 구축했습니다. 자동화된 경고로 99.95% 이상의 가동 시간을 유지했습니다."
{{% /hint %}}

### Source Data
- NYC Taxi data - 지저분한 timestamp, 중첩된 JSON, 지리공간 field
- OpenWeather API - 실시간 및 historical data, 누락된 값 포함
- YouTube나 Spotify public API - paginated, rate-limited data
- Kaggle dataset - 자체 수집 및 변환 계층 추가

## 2) "이벤트 스트리밍 구축"
### 실시간 대시보드를 위한 스트리밍 클릭스트림 프로젝트 예시
1. Event Ingestion : Kafka 토픽으로 실시간 클릭스트림 전송
2. Stream Processing : Kafka + Kafka Streams 또는 Flink를 사용해 실시간으로 데이터를 정리, 필터링 및 보강
3. Windowed Aggregation : 분당 page view, 이탈률, 활성 사용자와 같은 지표 계산을 위한 sliding window 구현
4. Output & Serving : 처리된 데이터를 Redis에 저장해 빠른 조회 또는 실시간 대시보드(Websocket이나 Rest API 사용)에 업데이트
5. Real-Time Alerting : rule-based 엔진이나 이상 탐지기로 경고 트리거

### Stack
- Apache Kafka / Redpanda
- Kafka Streams / Flink / Spark Structured Streaming
- Debezium + Kafka Connect
- Redis / Apache Pinot
- Superset / Grafana / Streamlit
- Python / FastAPI

{{% hint "info" %}}
**예시**  
"초당 5천건 이상의 이벤트를 일관된 200ms 미만의 end-to-end latency로 처리할 수 있는 실시간 데이터 파이프라인을 구축했습니다. 이 시스템은 Kafka를 사용해 시뮬레이션된 clickstream 트래픽을 수집하고, Kafka Streams를 통해 이벤트를 처리하며, Redis와 Superset으로 구동되는 실시간 대시보드에 정제된 metric을 표시합니다."
{{% /hint %}}

- Redis peak load 중 \(< 45ms\) 의 쿼리 지연 시간 달성
- 24h 부하 테스트에서 \(99.99\%\) 이상의 가동 시간 유지
- 메시지 중복 제거 및 재시도 처리를 통해 \(0.05\%\) 미만의 오류율 보장
- \(over 10K event/second\) 에서 데이터 손실 없이 수평적 확장

## 3) "Cloud Data Warehouse"
- Snowflake, Bigquery, Redshift는 modern analytics와 AI 파이프라인의 근간임
- Delta Lake와 Iceberg와 같은 기술을 활용해 Data Lake의 유연성과 Warehouse의 고성능 쿼리 속도를 결합한 hybrid 아키텍쳐를 구축할 수 있음
### Cloud Warehousing 프로젝트
- Data ingestion 
- Schema design : dimensional modeling, star schema, snowflake schema, data vault 등으로 쿼리 속도와 유지 관리성 최적화
- Query optimization : 파티셔닝, 클러스터링 및 materialized view를 활용해 클라우드 비용 증가 없이 빠른 인사이트를 얻기
- Data governance : metadata 관리, 세부적인 권한 제어 및 계보 추적을 통해 데이터의 신뢰성과 규정 준수를 유지
- Lakehouse innovation : 클라우드 object storage에 Delta Lake나 Iceberg를 구축해 Data Lake와 Warehouse의 장점을 결합

### Stack
- Snowflake, BigQuery, or AWS Redshift for warehouses
- Delta Lake (Databricks) or Apache Iceberg for lakehouse projects
- dbt (data build tool) for transformations, testing, and documentation
- Cloud platforms: AWS, GCP, or Azure
- Data governance tools: Apache Atlas, Amundsen, or open metadata platforms

{{% hint "info" %}}
**예시**  
"Bigquery에 클라우드 데이터 웨어하우징 프로젝트를 구축해 Kafka와 Airflow 파이프라인을 통해 일일 100만건 이상의 이벤트를 수집했습니다. 파티셔닝과 클러스터링을 통해 최적화된 스타 스키마를 설계해 쿼리 대기 시간을 60% 줄이고 월간 쿼리 비용을 35% 절감했습니다. dbt 자동화 테스트와 Aumndsen의 메타데이터 관리 및 데이터 계보 기능을 통합했습니다. AWS S3의 Delta Lake와 결합해 Lake 유연성과 웨어하우스 성능을 제공했습니다. Superset 대시보드를 구축해 초당 KPI 업데이트를 제공하며 대규모 end-to-end 분석 기능을 구현했습니다"
{{% /hint %}}