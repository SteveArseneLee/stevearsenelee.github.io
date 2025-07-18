+++
title = "4. Deadlock"
draft = false
bookHidden = true
+++
## 1. 정의
데드락(교착 상태, Deadlock) 이란 여러 프로세스(또는 스레드)가 서로 자원이 풀리기를 기다리며 무한히 블로킹되어, 더 이상 진행되지 못하는 상태를 의미한다.
> A는 B의 자원을 기다리고, B는 A의 자원을 기다리는 순환적 대기 상태.

## 2. 데드락 발생 조건(Coffman's Conditions)
데드락은 다음 4가지 조건이 동시에 성립할 때 발생
조건 | 설명
-|-
상호 배제 (Mutual Exclusion) | 자원은 한 번에 하나의 프로세스만 사용 가능
점유 대기 (Hold and Wait) | 자원을 보유한 상태에서 다른 자원을 기다림
비선점 (No Preemption) | 이미 할당된 자원을 강제로 뺏을 수 없음
순환 대기 (Circular Wait) | 자원 대기 관계가 순환 구조를 이룸 (P1→P2→…→Pn→P1)
=> 데드락을 방지하려면 이 중 하나라도 깨야 함

## 3. 데드락 예시
```java
Thread A: lock(a) → lock(b)  
Thread B: lock(b) → lock(a)
```
-> A는 a를, B는 b를 먼저 얻고 서로 상대방의 자원을 기다림 → 교착 상태 발생

## 4. 해결 전략(4가지 접근법)
전략 | 설명 | 핵심 아이디어
-|-|-
예방 (Prevention) | Coffman 조건 중 하나 이상을 사전에 제거  | ex: 자원 요청 전에 모두 확보
회피 (Avoidance) | 데드락 발생 가능성을 사전에 예측하고 우회 | ex: 은행원 알고리즘
탐지 및 복구 (Detection & Recovery) | 데드락 발생을 허용하고 사후 복구 | ex: 자원 할당 그래프 순환 탐지
무시 (Ignore) | 그냥 냅둠 (“Ostrich Algorithm”) | ex: Linux 대부분 경우 무시

### 예방 전략 구체화
제거 조건 | 방법
-|-
상호 배제 | 자원을 공유 가능하게 설계 (불가능한 경우 많음)
점유 대기 | 모든 자원을 한 번에 요청하게 강제
비선점 | 자원 선점 가능하도록 설계 (중단 후 롤백)
순환 대기 | 자원에 고정된 순서를 부여하고 순서대로만 요청 허용

### 회피 전략 – 은행원 알고리즘 (Banker’s Algorithm)
- 프로세스가 자원 요청 시 최악의 시나리오를 가정하고도 시스템이 안정 상태(safe state)를 유지할 수 있으면 자원을 할당
- 자원 할당 상태를 벡터/행렬로 표현
- 실무 적용은 어려움 (자원 요구량 예측이 필요)

### 탐지 및 복구
- 자원 할당 그래프(Resource Allocation Graph)에서 순환(Cycle) 존재 여부로 데드락 감지
- 복구 방법:
    - 프로세스 강제 종료
	- 자원 선점 → 이전 상태로 롤백 (중단 가능해야 함)
	- FIFO 순으로 kill, 최소 비용 기준 kill 등

## 5. 실무 예시
분야 | 대응 방식
-|-
DB 트랜잭션 (예: MySQL, PostgreSQL) | Lock wait timeout / Deadlock detection (순환 감지)
Java Thread | synchronized 블록 교착 가능 → 타임아웃/락 순서 강제
Go / C++ | 뮤텍스 체인 락 시 교착 위험 → 락 정렬 정책 필요
커널/드라이버 | Deadlock 방지 로직 삽입, 스핀락 순서 고정

## 6. 자주 묻는 면접 질문
> Q1. 데드락이 발생하려면 어떤 조건이 필요한가요?

A.
- 상호 배제
- 점유 대기
- 비선점
- 순환 대기

→ 네 가지 조건이 모두 만족될 때만 데드락 발생


> Q2. 데드락을 방지하기 위해 어떤 전략이 있나요?

A.
- 예방: 네 가지 조건 중 하나 이상을 깨뜨림
- 회피: 안전 상태 유지 보장 (ex. Banker’s Algorithm)
- 탐지: 순환 관계 발견 후 해결
- 무시: 성능 우선 시스템에선 감수하고 방치

> Q3. 실무에서 데드락을 어떻게 예방하나요?

A.
- 자원 획득 순서 고정
- 락 획득 시 타임아웃 설정
- 락 수 제한
- 트랜잭션 구조 최소화