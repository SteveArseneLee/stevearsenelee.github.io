+++
title = "Flink to GCS"
draft = false
+++
# [Dimension] dim-equipment
### 개요
항목 | 내용
-|-
목적 | 각 설비의 메타 정보(모델, 종류, 설치 위치 등)를 저장하고, Fact 테이블과 조인 시 기준값 제공
사용 도메인 | equipment_metrics, qc_result, robot_status, maintenance_log 등
조인 키 | equipment_id (string)
설계 유형 | Dimension Table (SCD Type 2)
갱신 주기 | 비정기 (설비 추가/교체/이동 등 시점 기준)



### Table Schema (Iceberg DDL)
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

### 관리 정책
항목 | 설명
-|-
SCD 유형 | Type 2 (이력 유지)
생성/수정 주체 | 수동 정의 또는 Faker 기반 dummy generator
갱신 조건 | 설비 모델 변경, 이동, 교체 등
폐기 처리 | retired_date 입력 + is_current = false

### 정규화 항목
항목 | 정규화 여부 | 참조 테이블 / 방식
-|-|-
equipment_type | ✅ 별도 enum 테이블 (e.g. dim_equipment_type)
manufacturer | ⚠️ 선택 사항 (제조사 수가 많을 경우만 분리)
location_id | ✅ dim_location 참조
spec_json | ❌ 비정형 → raw JSON 필드로 유지

### 데이터 수급 및 동기화
항목 | 내용
-|-
데이터 생성 방식 | 자체 정의 schema + Python faker 기반 generator
초기 수급 방식 | 일괄 100~500건 규모의 mock 데이터
갱신 방식 | 스크립트 기반 diff-injection (장비 ID 단위)
외부 연계 | 없음 (실장비 없음) → 전체 내부 제어 방식
데이터Hub 등록 | 수동 등록 or CLI 기반 ingestion 사용 예정

### 연계 도메인 및 조인 흐름
참조 Fact 도메인 | 조인 키 | 설명
-|-|-
equipment_metrics | equipment_id | 센서 데이터 수집 시 설비별 스펙/위치 매핑
qc_result | equipment_id | 설비별 품질 트렌드 분석
robot_status | equipment_id | 로봇 가동률, 오류율 연계 분석
maintenance_log | equipment_id | 설비별 고장 이력 트래킹

### 사용 시나리오
분석 목적 | 활용 필드
-|-
설비 유형별 이상 발생률 비교 | equipment_type, is_critical
제조사별 MTBF 분석 | manufacturer, install_date
위치별 센서 알람 히트맵 | location_id, 조인된 equipment_metrics
신규 설비 평균 초기 고장률 파악 | install_date, equipment_type, status

# [Dimension] dim-device
### 개요
항목 | 내용
-|-
목적 | 센서, 게이트웨이, 컨트롤러 등 모든 측정 장비의 메타정보 저장 및 분석 연계
사용 도메인 | equipment_metrics, energy_usage, environmental_readings
조인 키 | device_id (string)
설계 유형 | Dimension Table (SCD Type 2 + 관계 테이블 고려)
갱신 주기 | 비정기 (설치/보정/교체/업데이트 발생 시)

### Iceberg DDL
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

### 관리 정책
항목 | 내용
-|-
SCD 유형 | Type 2 (변경 이력 유지)
장비 연결 구조 | equipment_id는 FK, 1:N 가능 (센서 다중 장착 허용)
폐기 처리 | retired_date와 is_current = false 조합
spec 관리 | JSON → 컬럼 분리로 전환 (스키마 정합성 ↑)

### 정규화 항목
항목 | 정규화 여부 | 참조 방식
-|-|-
device_type | ✅ dim_device_type 또는 enum |
manufacturer | ⚠️ 필요 시 enum 또는 코드 테이블 | 
location_id | ✅ dim_location 참조 |
equipment_id | ✅ dim_equipment 참조 | 
firmware_version | ❌ (버전 다양성 ↑, 유지됨)

### 데이터 수급 및 동기화
항목 | 내용
-|-
생성 방식 | faker or 자체 정의 스크립트
생성 수 | 300~1000 단위 센서/디바이스
변경 발생 조건 | 보정, 교체, 펌웨어 업데이트, 위치 이동 등
연계 테이블 | equipment_device_map (필요 시)
데이터Hub 등록 | 수동 또는 CLI 등록 예정

### 연계 도메인 및 조인 흐름
참조 Fact 도메인 | 조인 키  | 설명
-|-|-
equipment_metrics | device_id | 센서 데이터 정합성 및 유효성 확인
energy_usage | device_id | 전력 감시 센서 기준 집계
environmental_readings | device_id | 환경 데이터 센서 연결 분석

### 사용 시나리오
분석 목적 | 활용 필드
-|-
센서 유형별 이상 비율 분석 | device_type, is_calibrated
제조사별 펌웨어 오류율 비교 | manufacturer, firmware_version
장비별 센서 수명 분석 | install_date, retired_date, equipment_id
센서 위치 기반 알람 분포 분석 | location_id, 연계된 equipment_metrics

# [Dimension] dim-operator
### 개요
항목 | 내용
-|-
목적 | 설비 작업자 식별 및 근무 이력 관리, 분석 기준 제공
사용 도메인 | equipment_metrics, qc_result, maintenance_log
조인 키 | operator_id (string)
설계 유형 | Dimension Table (SCD Type 2)
갱신 주기 | 배치 이동, 자격 변경, 근무조 변경 시

### Iceberg DDL
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

### 관리 정책
항목 | 내용
-|-
변경 조건 | shift 변경, certification 갱신, 조직 이동
퇴사자 처리 | retire_date와 is_current = false 조합
PII 보안 처리 | 별도 테이블로 분리 저장 (contact_ref_id)
정규화 항목 | shift_id, certification → 코드 테이블과 연계 가능

### 정규화 항목
항목 | 정규화 여부 | 참조 테이블
-|-|-
shift_group | ✅ | dim_shift
certification | ✅ | dim_certification_level
role | ✅ | dim_role
location_id | ✅ | dim_location
organization_unit, team | ⚠️ 조직 구조 확장 시 분리 고려

### 데이터 수급 및 동기화
항목 | 내용
-|-
더미 생성 | 초기 faker 기반 가능, 100~500명 범위
시스템 연계 여부 | HR, MES 시스템 연계 고려 대상
수동 업데이트 경로 | 관리자 수기 관리 or Airflow DAG

### 연계 도메인 및 조인 흐름
참조 Fact 도메인 | 조인 키 | 설명
-|-|-
equipment_metrics | operator_id | 설비 운영자 추적
qc_result | operator_id | 검사 담당자 조회
maintenance_log | operator_id | 수리 담당자 분석

### 사용 시나리오
분석 목적 | 활용 필드
-|-
교대조별 설비 이상률 분석 | shift_id, equipment_metrics
자격 등급별 품질 불량률 비교 | certification, qc_result
이직률/경력 기반 성과 비교 | experience_year, retire_date
조직/팀별 업무 집중도 분석 | organization_unit, maintenance_log

# [Dimension] dim-location
### 개요
항목 | 설명
-|-
목적 | 설비, 품질, 유지보수, 물류 등과 연동 가능한 공장 내 위치 체계 관리
설계 유형 | Dimension Table
사용 도메인 | dim_equipment, equipment_metrics, qc_result, maintenance_log 등

### Iceberg DDL
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

### 정규화 항목
항목 | 정규화 필요 여부 | 이유
-|-|-
factory_code | ✅ | 공장 코드-명 분리, PLANT 테이블로 정규화 가능
line_id | ✅ | dim_line으로 분리 가능 (라인별 담당자, 설비 연결 시 유용)
zone_type | ✅ | ENUM화 또는 코드 테이블화 (위험구역, 품질구역 등 정책 기반 분류)

### 연계 도메인 예시
연계 도메인 | 조인 키 | 활용 목적
-|-|-
dim_equipment | location_id | 장비 설치 위치
equipment_metrics | location_id | 라인/셀 단위 이상탐지 패턴 분석
qc_result | location_id | 품질 검사 발생 지점
maintenance_log | location_id | 정비 작업 장소 기준
alarm_log | location_id | 위험 구역 알람 필터링

### 사용 예시
분석 목적 | 활용 필드
-|-
셀 단위 이상 탐지율 비교 | cell_id, location_id
위험 구역 이상 알람 비율 | is_critical_area = true
품질검사 결과 지역별 통계 | zone_type, factory_name
라인별 생산설비 집중도 분석 | line_id + dim_equipment 조인

# [Dimension] dim-thresholds
### rody
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

# [Dimension] dim-batch
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

# [Dimension] dim-certification-level
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

# [Dimension] dim-product
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

# [Dimension] dim-shift
### 개요
항목 | 설명
-|-
목적 | 근무 교대조(Shift)에 대한 정보 관리 및 시간대 기반 이상 탐지·품질·정비 분석 연계
사용 도메인 | equipment_metrics, qc_result, maintenance_log, dim_operator, dim_thresholds 등
설계 유형 | Static Dimension Table (변경 거의 없음, 고정 값 기반 조인)

### Iceberg DDL
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
