+++
title = "Flink to GCS"
draft = false
+++
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

