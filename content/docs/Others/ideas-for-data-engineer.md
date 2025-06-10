+++
title = "Data Engineer의 프트폴리오 작성법"
draft = false
+++
{{< mermaid >}}
sequenceDiagram
    Alice->>+John: Hello John, how are you?
    Alice->>+John: John, can you hear me?
    John-->>-Alice: Hi Alice, I can hear you!
    John-->>-Alice: I feel great!
{{< /mermaid >}}
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

### 예시
> "3개의 API에서 기상 데이터를 수집하고, 정규화 및 병합하여 BigQuery에 120만 건의 일별 레코드를 파티션 테이블로 로드하는 Airflow 기반 ETL 파이프라인을 구축했습니다. 자동화된 경고로 99.95% 이상의 가동 시간을 유지했습니다."

### Source Data
- NYC Taxi data - 지저분한 timestamp, 중첩된 JSON, 지리공간 field
- OpenWeather API - 실시간 및 historical data, 누락된 값 포함
- YouTube나 Spotify public API - paginated, rate-limited data
- Kaggle dataset - 자체 수집 및 변환 계층 추가

## 2) "이벤트 스트리밍 구축법
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

### 예시
> "초당 5천건 이상의 이벤트를 일관된 200ms 미만의 end-to-end latency로 처리할 수 있는 실시간 데이터 파이프라인을 구축했습니다. 이 시스템은 Kafka를 사용해 시뮬레이션된 clickstream 트래픽을 수집하고, 