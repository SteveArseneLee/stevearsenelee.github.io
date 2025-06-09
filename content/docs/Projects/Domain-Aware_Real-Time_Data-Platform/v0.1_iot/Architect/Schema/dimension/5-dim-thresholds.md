+++
title = "[Dimension] Thresholds"
draft = false
+++
### 개요
항목 | 설명
-|-
목적 | 장비 센서 기준값을 다조건(시즌, 교대조, 제품 등)으로 관리하여 실시간 이상 탐지에 활용
사용 도메인 | equipment_metrics, alarm_log, maintenance_log 등
특징 | Slowly Changing Dimension (SCD Type 2), Spark 실시간 조인 최적화

### Iceberg DDL
```sql
CREATE TABLE dim_thresholds (
  threshold_id        STRING COMMENT 'surrogate key: 해시 또는 UUID (필수 조건 조합 기반)',
  equipment_id        STRING COMMENT '설비 ID',
  sensor_type         STRING COMMENT '센서 종류 (예: temperature)',
  season              STRING COMMENT '계절 또는 외부 조건 (예: winter)',
  shift               STRING COMMENT '근무 교대조 (예: A, B)',
  product_type        STRING COMMENT '제품 유형 (nullable)',
  min_threshold       DOUBLE COMMENT '이상 탐지 하한값',
  max_threshold       DOUBLE COMMENT '이상 탐지 상한값',
  confidence_level    STRING COMMENT '기준 산출 신뢰도 (RULE_BASED / AI_BASED / HYBRID)',
  valid_from          TIMESTAMP,
  valid_to            TIMESTAMP,
  row_version         INT COMMENT 'SCD 이력 관리용 버전',
  is_current          BOOLEAN COMMENT '현재 적용 여부',
  created_at          TIMESTAMP,
  updated_at          TIMESTAMP,

  PRIMARY KEY (threshold_id, row_version)
)
PARTITIONED BY (
  bucket(8, equipment_id),
  sensor_type,
  season
);
```

### 정규화 항목 및 ENUM 정의
항목 | 처리 방식
-|-
sensor_type | ENUM or dim_sensor_type (표준화)
season | ENUM or dim_season (summer, winter, etc.)
shift | ENUM (A, B, C, Night)
product_type | dim_product로 정규화 가능
confidence_level | ENUM(RULE_BASED, AI_BASED, HYBRID)

### Spark Join 설계 시 고려사항
```scala
// 조건 Null-safe broadcast join (product_type nullable 허용)
val joined = metrics
  .join(thresholds.hint("broadcast"),
        metrics("equipment_id") <=> thresholds("equipment_id") &&
        metrics("sensor_type") <=> thresholds("sensor_type") &&
        metrics("season") <=> thresholds("season") &&
        metrics("shift") <=> thresholds("shift") &&
        (metrics("product_type") <=> thresholds("product_type") || thresholds("product_type").isNull),
        "left_outer")
  .filter($"is_current" === true)
```

### 활용 예시
목적 | 활용 필드
-|-
교대조/계절별 이상률 분석 | shift, season
AI 기반 threshold 적용률 모니터링 | confidence_level = 'AI_BASED'
기준값 변경 이력 트래킹 | valid_from, valid_to, row_version
센서별 허용 편차 시각화 | min_threshold, max_threshold 추이

### 유효성 체크 규칙 (ETL or Airflow DAG)
규칙 항목
설명
min_threshold < max_threshold
필수 조건, 아니면 reject
동일 조건 중복 방지
(equipment_id + sensor_type + season + shift + product_type + valid_from) unique
valid_to > valid_from
시간 역전 방지
is_current = true row 1개
장비+센서 조건 당 최신 row는 1개만 존재해야 함

