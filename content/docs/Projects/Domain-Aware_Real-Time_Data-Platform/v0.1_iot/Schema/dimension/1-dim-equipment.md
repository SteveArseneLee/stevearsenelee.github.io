+++
title = "[Dimension] Equipment"
draft = false
+++

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



