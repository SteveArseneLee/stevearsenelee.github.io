+++
title = "[Dimension] Shift"
draft = false
+++
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


