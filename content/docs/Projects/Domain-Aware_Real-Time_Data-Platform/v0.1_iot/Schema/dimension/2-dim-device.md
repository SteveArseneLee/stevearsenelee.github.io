+++
title = "[Dimension] Device"
draft = false
+++
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



