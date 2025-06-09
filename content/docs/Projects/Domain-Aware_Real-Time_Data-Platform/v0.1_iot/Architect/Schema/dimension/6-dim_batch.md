+++
title = "[Dimension] Batch"
draft = false
+++
### 개요
항목 | 설명
-|-
목적 | 설비, 제품, 작업자, 교대조 기준의 생산 배치 단위 추적 및 분석
사용 도메인 | equipment_metrics, qc_result, maintenance_log, dim_operator, dim_product, dim_shift 등
설계 유형 | Type 1 Dimension Table (SCD 가능성 고려됨, 단일 버전 관리

### Iceberg DDL
```sql
CREATE TABLE dim_batch (
  batch_id            STRING COMMENT '배치 고유 ID (ex: BATCH_20250601_001)',
  product_id          STRING COMMENT '제품 ID (FK to dim_product)',
  equipment_id        STRING COMMENT '설비 ID (FK to dim_equipment)',
  production_line_id  STRING COMMENT '라인 ID (FK to dim_location or line)',
  operator_id         STRING COMMENT '작업자 ID (FK to dim_operator)',
  shift_code          STRING COMMENT '교대조 코드 (FK to dim_shift)',
  planned_start_time  TIMESTAMP COMMENT '계획 시작 시간 (UTC)',
  actual_start_time   TIMESTAMP COMMENT '실제 시작 시간 (UTC)',
  actual_end_time     TIMESTAMP COMMENT '실제 종료 시간 (UTC)',
  quantity_planned    INT COMMENT '계획 생산 수량 (EA)',
  quantity_produced   INT COMMENT '실제 생산 수량 (EA)',
  status              STRING COMMENT '상태 (scheduled, running, completed, aborted)',
  remarks             STRING COMMENT '특이사항 또는 예외 기록',
  created_at          TIMESTAMP,
  updated_at          TIMESTAMP,

  PRIMARY KEY (batch_id)
)
PARTITIONED BY (
  days(actual_start_time)
);
```

### 예시 데이터
batch_id | product_id | equipment_id | line_id | operator_id | shift_code | start | end | produced | status
-|-|-|-|-|-|-|-|-|-
BATCH_20250601_001 | P-001 | EQ-001 | LINE_1 | OP001 | A | 2025-06-01 08:00:00 | 2025-06-01 12:30:00 | 940 | completed
BATCH_20250601_002 | P-002 | EQ-003 | LINE_2 | OP002 | B | 2025-06-01 13:00:00 | 2025-06-01 17:00:00 | 860 | completed

### 조인 연계 및 활용 예시
대상 도메인 | 조인 조건 | 활용 목적
-|-|-
equipment_metrics | equipment_id + timestamp BETWEEN start AND end | 배치별 설비 센서 조인
qc_result | batch_id | 배치별 품질 평가 결과 추적
maintenance_log | equipment_id + batch_id or timestamp | 배치 중 장애 및 고장 분석
dim_product | product_id | 제품 사양 기반 분석
dim_operator | operator_id | 작업자 기준 생산 이력 조회
dim_shift | shift_code | 교대조별 운영 비교

### 운영 및 유입 전략
항목 | 내용
-|-
배치 ID 생성 | 규칙 기반 (BATCH_YYYYMMDD_XXX), 실시간 or 사후 입력 모두 가능
생성 방식 | 초기 수동 / 자동 생성 스크립트 / MES API 연동
종료 시점 기록 | API 혹은 배치 상태 업데이트 이벤트 기반으로 actual_end_time 입력

### 정규화 항목 및 동기화 상태
필드 | 정규화 여부 | 참조 테이블
-|-|-
product_id | ✅ FK | dim_product
equipment_id | ✅ FK | dim_equipment
operator_id | ✅ FK | dim_operator
production_line_id | ✅ FK (가능) | dim_location or 별도
shift_code | ✅ FK | dim_shift

