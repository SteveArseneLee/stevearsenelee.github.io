+++
title = "[Dimension] Product"
draft = false
+++
### 개요
항목 | 설명
-|-
목적 | 제품군/모델/사양 정보 관리 및 SCD 이력 기반 분석 연계
적용 도메인 | qc_result, equipment_metrics, dim_thresholds, dim_batch 등
설계 유형 | Type 2 SCD Dimension Table

### Iceberg DDL
```sql
CREATE TABLE dim_product (
  product_id         STRING COMMENT '제품 고유 ID',
  product_name       STRING COMMENT '제품명 또는 모델명',
  product_type       STRING COMMENT '제품군 (ex. piston, actuator, pcb)',
  material_type      STRING COMMENT '재질 분류 (ex. aluminum, polymer)',
  line_id            STRING COMMENT '생산 라인 ID',
  specification      STRING COMMENT '주요 사양 (JSON or TEXT)',
  pressure_max       DOUBLE COMMENT '최대 허용 압력 (예시)',
  voltage_rating     DOUBLE COMMENT '정격 전압 (예시)',
  valid_from         TIMESTAMP COMMENT '이 버전 유효 시작일시 (UTC)',
  valid_to           TIMESTAMP COMMENT '이 버전 유효 종료일시 (null이면 현재)',
  is_current         BOOLEAN COMMENT '현재 유효 여부',
  timezone           STRING COMMENT '시간대 (예: Asia/Seoul)',
  created_at         TIMESTAMP,
  updated_at         TIMESTAMP,

  PRIMARY KEY (product_id, valid_from)
)
PARTITIONED BY (
  bucket(10, product_id),
  days(valid_from)
);
```

### 예시 데이용
product_id | product_name | type | material | line_id | spec | pressure_max | voltage_rating | from | to | current
-|-|-|-|-|-|-|-|-|-|-
P-001 | Core Press A | actuator | aluminum | LINE_1 | {"pressure":"1.2MPa"} | 1.2 | 12.0 | 2024-01-01T00:00:00 | 2024-10 | false
P-001 | Core Press A | actuator | aluminum | LINE_1 | {"pressure":"1.3MPa"} | 1.3 | 12.0 | 2024-10-01T00:00:00 | null | true

### 사용 예시 및 조인
대상 도메인 | 조인 조건 | 활용 목적
-|-|-
qc_result | product_id, qc_result.timestamp BETWEEN valid_from AND valid_to | 사양 기준 품질 분석
equipment_metrics | product_id + line_id | 기준 스펙 기반 이상 탐지 분석
dim_thresholds | product_type, material_type | 제품 유형별 기준 임계값 적용
dim_batch | product_id | 배치별 제품 매핑 및 추적성 확보

### 유지 전략 및 유입 방식
항목 | 내용
-|-
운영 방식 | 초기: 수동 등록 / 이후: MES or 제품 DB 연계
버전 관리 | 사양 변경 시 diff 비교 → Spark 기반 SCD 처리
관리 주체 | 개발 초기에는 수기 또는 파생 로직, 실서비스 전환 시 연계 자동화 고려

### 정규화 후보 필드
필드 | 정규화 여부 | 대상 테이블 제안
-|-|-
product_type | ENUM or FK | dim_product_type
material_type | ENUM or FK | dim_material_type
line_id | FK | dim_equipment_line 또는 dim_location 참조