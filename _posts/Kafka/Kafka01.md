---
title:  "[Kafka] 모니터링의 이유"
excerpt: "기본 개념"

categories:
  - Kafka
tags:
  - [Kafka]

toc: true
toc_sticky: true
 
date: 2022-05-04
last_modified_at: 2022-05-04
---
**데이터 유실없이 안정적으로 처리하는지 확인하는 것이 주 목적**

### 모니터링 대상
**Producer**
- 초당 요청 건수/사이즈
- 초당 전송 사이즈
- I/O 사용률

**Broker**
- Active Controller 개수
- 초당 유입/유출 건수 및 사이즈
- 평균 처리 시간
- Topic 상태 (ISR)
- Log Flush 비율
- 비정상 복제본 개수

**Consumer**
- 초당 읽어온 거수/사이즈
- 가장 높은 Offset Lag
- 초당 Commit한 개수
- Consumer Group 정보


### Producer별 모니터링 항목
**Buffer 구간**
- 데이터 압축률
- I/O 대기 시간(CPU 대기)
- 가용 BUffer 사이즈
- Buffer 할당 대기 시간
- Buffer 할당 대기 thread 수

**Sender 구간**
- 연결된 connection 관련 정보
- 인증 실패한 connection 정보
- Buffer의 데이터 체크 건수
- 전송 Queue 대기 시간
- 전송 부하로 인한 대기 시간(throttling time)
- 전송 실패 건수
- 재전송 비율

**전송 구간**
- [Producer/Broker/Topic 별]
- 초당 평균 전송 요청 건수
- 초당 전송 데이터 사이즈