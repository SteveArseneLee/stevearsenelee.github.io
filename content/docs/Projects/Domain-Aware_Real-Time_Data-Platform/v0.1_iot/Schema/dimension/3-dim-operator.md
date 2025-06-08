+++
title = "Flink to GCS"
draft = false
+++
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