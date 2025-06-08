+++
title = "Flink to GCS"
draft = false
+++
## 개요
항목 | 설명
-|-
목적 | 작업자 자격 등급과 정책적 연계 정보 관리 (권한, 만료, 교육 등)
설계 유형 | Dimension Table (정규화 + 확장 가능)
사용 도메인 | dim_operator, certification_task_map, maintenance_log, qc_result 등

### Iceberg DDL
```sql
CREATE TABLE dim_certification_level (
  certification_level_id STRING COMMENT '자격 등급 ID (예: L1, L2, L3)',
  level_name             STRING COMMENT '자격 등급명 (표준 ENUM)',
  description            STRING COMMENT '등급 설명',
  issued_by_code         STRING COMMENT '발급 기관 코드',
  valid_from             DATE COMMENT '유효 시작일',
  valid_to               DATE COMMENT '유효 종료일',
  training_required      BOOLEAN COMMENT '사전 교육 필수 여부',
  row_version            INT COMMENT '버전 관리용',
  is_current             BOOLEAN COMMENT '현재 유효 여부',
  created_at             TIMESTAMP,
  updated_at             TIMESTAMP,

  PRIMARY KEY (certification_level_id, row_version)
)
PARTITIONED BY (bucket(4, certification_level_id));
```

### 연계 테이블 : certification_task_map
```sql
CREATE TABLE certification_task_map (
  certification_level_id STRING,
  task_id                STRING,
  created_at             TIMESTAMP,
  updated_at             TIMESTAMP,

  PRIMARY KEY (certification_level_id, task_id)
)
PARTITIONED BY (bucket(8, certification_level_id));
```
required_for_tasks는 array -> 관계형 테이블로 분리됨

### 코드 테이블 : dim_certifying_body
```sql
CREATE TABLE dim_certifying_body (
  certifying_body_code STRING,
  certifying_body_name STRING,
  country              STRING,
  accreditation_level  STRING,
  contact_info         STRING,
  created_at           TIMESTAMP,
  updated_at           TIMESTAMP,

  PRIMARY KEY (certifying_body_code)
);
```
issued_by_code는 이 테이블과 FK 연계

### 관리 정책
항목 | 설명
-|-
버전 관리 | SCD Type 2 (row_version, is_current) 사용
자격 갱신 | 신규 버전 INSERT + 기존 버전 is_current = false
만료 필터링 | valid_to < current_date 조건 처리
정합성 | certification_task_map, dim_operator FK로 검증

### 분석 활용 예시
목적 | 활용 컬럼
-|-
등급별 고위험 작업 수행률 | certification_task_map + qc_result, maintenance_log
자격 만료/갱신 모니터링 | valid_to, is_current
미이수 교육 대상 필터링 | training_required = true + dim_operator.last_training_date
등급별 자격 발급 분포 | issued_by_code, level_name

