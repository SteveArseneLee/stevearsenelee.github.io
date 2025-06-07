+++
title = "2. CPU Scheduling"
draft = false
bookHidden = true
+++
## 1. 정의
- CPU 스케줄링은 Ready Queue에 있는 프로세스들 중 어떤 프로세스에게 CPU를 할당할지 결정하는 정책.
- 멀티태스킹 OS에서 프로세스 간 CPU를 공유하기 위한 핵심 메커니즘.
- OS의 핵심 기능 중 하나로, 스케줄러는 다양한 정책에 따라 프로세스를 선택함.

### 주요 목적
- 시스템 자원의 공정한 분배
- CPU 사용률(Throughput) 극대화
- 대기 시간, 응답 시간 최소화
- 전반적인 시스템 반응성 향상

## 2. 스케쥴링이 필요한 시점
- 프로세스가 CPU burst를 마치고 I/O 요청 → CPU 반환
- 프로세스가 종료됨
- 선점형 스케줄러의 경우, 더 높은 우선순위의 프로세스가 도착
- sleep(), wait() 호출 후 wake up될 때

## 3. 주요 스케쥴링 기준
기준 | 설명
-|-
CPU burst time | 얼마나 짧게 CPU를 점유할지
우선순위 (Priority) | 사용자/시스템 지정
도착 시간 (Arrival Time) | 먼저 온 순서
대기 시간 / 응답 시간 | 유저가 체감하는 반응 속도
Aging | 기아(Starvation) 방지 목적

## 4. 스케쥴링 알고리즘
1.  FCFS (First-Come, First-Served)
- 먼저 온 순서대로 처리 (Queue 기반)
- 단순하지만 Convoy 현상 발생 가능 (긴 작업이 짧은 작업을 막음)

2. SJF (Shortest Job First)
- CPU burst가 가장 짧은 작업 우선
- 이론상 가장 효율적 (대기시간 최소), 하지만 예측이 어렵다
- 비선점형(기본) 또는 **선점형(SRTF)**으로 구현 가능

3. Round Robin (RR)
- 각 프로세스에 Time Quantum 부여
- 시간 할당이 끝나면 선점 발생 → 공정성 ↑
- 응답성이 중요할 때 유용 (인터랙티브 시스템)

4. Priority Scheduling
- 우선순위 높은 작업부터 실행
- Starvation 발생 가능 → Aging 기법으로 완화

5. Multi-Level Queue (MLQ)
- 프로세스를 성격에 따라 여러 큐로 분류 (ex. interactive, batch)
- 큐마다 별도 알고리즘 사용
- 큐 간 우선순위 존재 (low queue는 starvation 가능)

6. Multi-Level Feedback Queue (MLFQ)
- MLQ 확장형, 프로세스가 다른 큐로 이동 가능
- 초기엔 높은 우선순위에서 시작, CPU 오래 쓰면 점점 낮은 우선순위로 이동
- 현대 OS가 채택하는 현실적인 정책

## 5. 선점형 vs 비선점형
구분 | 비선점형 | 선점형
-|-|-
설명 | CPU를 할당받으면 자발적으로 반환할 때까지 유지 | 우선순위 등 조건에 따라 중간에 선점 가능
예시 알고리즘 | FCFS, SJF | RR, Priority(선점형), SRTF
특징 |  단순, context switch 적음 | 응답성 우수, 복잡도 ↑

## 6. 성능 지표
지표 | 설명
-|-
CPU 사용률 | CPU가 놀지 않고 일하는 비율
Throughput | 단위 시간당 완료된 프로세스 수
Turnaround Time | 프로세스 시작 ~ 종료까지 걸린 시간
Waiting Time | Ready Queue에서 기다린 시간
Response Time | 요청 후 첫 반응까지 걸린 시간

## 7. 실무 예시
OS | 스케줄러
-|-
Linux (CFS) | Completely Fair Scheduler – 시간 단위를 Weight로 변환해 공정하게 분배
Windows |  Multilevel Feedback Queue 기반 선점형
RTOS | Priority-based preemptive scheduling (실시간성 강조)

=> 📌 Linux CFS는 가상 런타임(VRuntime) 기반으로, 각 태스크의 실행 시간을 추적하며 가장 “덜 사용한” 프로세스에게 CPU를 할당.

## 8. 자주 묻는 면접 질문
> Q1. SJF가 이상적으로 효율적인 이유는?

A. 
- SJF는 평균 대기 시간을 수학적으로 최소화하는 최적 알고리즘.
- 하지만 실제 CPU burst time을 정확히 예측하는 건 어렵기 때문에 실무 적용이 제한적.

> Q2. Round Robin의 타임퀀텀 크기는 어떻게 결정해야 하나요?

A.
- 너무 작으면 context switching 오버헤드 증가
- 너무 크면 FCFS처럼 변함
- 일반적으로 10~100ms 수준

> Q3. 선점형 스케줄링이 필요한 이유는?

A.
- 실시간 반응이 필요한 환경 (GUI, 인터랙티브 shell 등)
- 짧은 작업이 긴 작업에 의해 밀리는 것을 방지

> Q4. 멀티코어 환경에서 스케줄링은 어떻게 동작하나요?

- 각 CPU에 Run Queue를 두는 per-CPU 모델 사용
- 부하 분산을 위한 load balancing 또는 task migration 전략 필요
- Linux는 SMP(Symmetric Multi Processing) 스케줄러로 처리

