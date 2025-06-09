+++
title = "Dimension Table 정리"
draft = false
+++
## [Dimension] dim-equipment

### Schema
```sql
CREATE TABLE dim_equipment (
  equipment_id     STRING COMMENT '설비 고유 ID',
  equipment_type   STRING COMMENT '설비 유형 (예: hydraulic_press)',
  model            STRING COMMENT '설비 모델명',
  manufacturer     STRING COMMENT '제조사',
  install_date     DATE   COMMENT '설치 일자',
  retired_date     DATE   COMMENT '퇴역 일자',
  location_id      STRING COMMENT '설치된 위치 ID (dim_location 참조)',
  spec_json        STRING COMMENT '스펙 (JSON 구조)',
  is_critical      BOOLEAN COMMENT '중요 설비 여부',

  -- SCD 필드
  effective_from   TIMESTAMP,
  effective_to     TIMESTAMP,
  is_current       BOOLEAN,
  updated_at       TIMESTAMP,

  PRIMARY KEY (equipment_id, effective_from)
)
PARTITIONED BY (bucket(8, equipment_id));
```

## [Dimension] dim-device

### Schema
```sql
CREATE TABLE dim_device (
  device_id         STRING COMMENT '디바이스 고유 ID (MAC, Serial 등)',
  device_type       STRING COMMENT '센서, 게이트웨이, 컨트롤러 등',
  manufacturer      STRING COMMENT '제조사',
  firmware_version  STRING COMMENT '펌웨어 버전',
  install_date      DATE   COMMENT '설치일',
  retired_date      DATE   COMMENT '퇴역일',
  is_calibrated     BOOLEAN COMMENT '보정 여부',
  calibration_date  DATE COMMENT '보정 일자',
  location_id       STRING COMMENT '장착 위치 (dim_location 참조)',
  spec_voltage_mv   INT COMMENT '스펙 전압(mV)',
  spec_precision    DOUBLE COMMENT '정밀도 (예: ±0.05)',
  spec_unit         STRING COMMENT '측정 단위 (예: mm/s, °C)',

  equipment_id      STRING COMMENT '장착된 설비 ID (1:N 구조)',

  -- SCD 필드
  effective_from    TIMESTAMP,
  effective_to      TIMESTAMP,
  is_current        BOOLEAN,
  updated_at        TIMESTAMP,

  PRIMARY KEY (device_id, effective_from)
)
PARTITIONED BY (bucket(8, device_id));
```

## [Dimension] dim-operator
### Schema
```sql
CREATE TABLE dim_operator (
  operator_id       STRING COMMENT '작업자 고유 ID',
  name              STRING COMMENT '이름',
  organization_unit STRING COMMENT '소속 부서 (예: 품질관리팀)',
  team              STRING COMMENT '소속 팀 (예: 생산3조)',
  shift_group       STRING COMMENT '근무조 (A, B, C)',
  shift_id          STRING COMMENT '교대조 ID (dim_shift 참조)',
  role              STRING COMMENT '직무 (예: 오퍼레이터, 수리기사)',
  certification     STRING COMMENT '자격 등급 코드 (예: C01, C02)',
  experience_year   INT COMMENT '경력 연수',
  join_date         DATE COMMENT '입사일',
  retire_date       DATE COMMENT '퇴사일 또는 예정일',

  location_id       STRING COMMENT '주요 근무 위치 (dim_location 참조)',

  -- PII는 별도 저장
  contact_ref_id    STRING COMMENT 'PII 분리된 contact 테이블 FK',

  -- SCD 필드
  effective_from    TIMESTAMP,
  effective_to      TIMESTAMP,
  is_current        BOOLEAN,
  updated_at        TIMESTAMP,

  PRIMARY KEY (operator_id, effective_from)
)
PARTITIONED BY (bucket(4, operator_id));
```

### 별도 테이블 : PII 관리
```sql
CREATE TABLE pii_operator_contact (
  contact_ref_id STRING PRIMARY KEY,
  email          STRING,
  phone_number   STRING,
  updated_at     TIMESTAMP
)
```

# [Dimension] dim-location
### Schema
```sql
CREATE TABLE dim_location (
  location_id           STRING COMMENT '위치 ID (예: LOC_LINE_A_01)',
  factory_code          STRING COMMENT '공장 코드 (예: PLANT_001)',
  factory_name          STRING COMMENT '공장 명',
  building              STRING COMMENT '건물/동',
  floor                 STRING COMMENT '층',
  line_id               STRING COMMENT '라인 ID (예: LINE_A)',
  line_name             STRING COMMENT '생산 라인 이름',
  cell_id               STRING COMMENT '세부 공정 셀 ID',
  cell_name             STRING COMMENT '셀 이름',
  zone_type             STRING COMMENT '구역 유형 (e.g., 생산, 품질, 위험, 물류)',
  is_critical_area      BOOLEAN COMMENT '위험 구역 여부',
  valid_from            DATE,
  valid_to              DATE,
  created_at            TIMESTAMP,
  updated_at            TIMESTAMP,

  PRIMARY KEY (location_id)
)
PARTITIONED BY (bucket(6, location_id));
```

## [Dimension] dim-thresholds
### Schema
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

## [Dimension] dim-batch
### 개요
항목 | 설명
-|-
목적 | 설비, 제품, 작업자, 교대조 기준의 생산 배치 단위 추적 및 분석
사용 도메인 | equipment_metrics, qc_result, maintenance_log, dim_operator, dim_product, dim_shift 등
설계 유형 | Type 1 Dimension Table (SCD 가능성 고려됨, 단일 버전 관리

### Schema
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

## [Dimension] dim-certification-level
### Schema
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

## [Dimension] dim-product
### Schema
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

### 예시 데이터
product_id | product_name | type | material | line_id | spec | pressure_max | voltage_rating | from | to | current
-|-|-|-|-|-|-|-|-|-|-
P-001 | Core Press A | actuator | aluminum | LINE_1 | {"pressure":"1.2MPa"} | 1.2 | 12.0 | 2024-01-01T00:00:00 | 2024-10 | false
P-001 | Core Press A | actuator | aluminum | LINE_1 | {"pressure":"1.3MPa"} | 1.3 | 12.0 | 2024-10-01T00:00:00 | null | true

## [Dimension] dim-shift
### Schema
```sql
CREATE TABLE dim_shift (
  shift_code         STRING COMMENT '교대조 코드 (예: A, B, C, N)',
  shift_name         STRING COMMENT '교대조 이름',
  shift_sequence     INT COMMENT '하루 중 근무 순서 (1, 2, 3)',
  start_time         STRING COMMENT '근무 시작 시간 (24h 형식, ex: 07:00)',
  end_time           STRING COMMENT '근무 종료 시간 (24h 형식, ex: 15:00)',
  shift_duration_mins INT COMMENT '근무 시간 (분)',
  shift_type         STRING COMMENT '일반 / 야간 / 주말 등 유형',
  timezone           STRING COMMENT '근무 시간 기준 타임존 (예: Asia/Seoul)',
  country_code       STRING COMMENT '국가 코드 (예: KR, US, DE)',
  is_active          BOOLEAN COMMENT '활성 상태 여부',
  created_at         TIMESTAMP,
  updated_at         TIMESTAMP,

  PRIMARY KEY (shift_code)
)
PARTITIONED BY (
  shift_type
);
```

### Sample Data
shift_code | shift_name | sequence | start | end | dur | type | timezone | country | active
-|-|-|-|-|-|-|-|-|-
A | Day Shift | 1 | 07:00 | 15:00 | 480 | 일반 | Asia/Seoul | KR | true
B | Evening | 2 | 15:00 | 23:00 | 480 | 일반 | Asia/Seoul | KR | true
C | Night | 3 | 23:00 | 07:00 | 480 | 야간 | Asia/Seoul | KR | true
D | Weekend | 1 | 08:00 | 20:00 | 720 | 주말 | Asia/Seoul | KR | false
