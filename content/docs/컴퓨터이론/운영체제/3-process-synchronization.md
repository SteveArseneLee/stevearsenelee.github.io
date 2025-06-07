+++
title = "3. 프로세스 동기화(Process Synchronization)"
draft = false
+++
## 1. 정의
- 프로세스 동기화란 둘 이상의 프로세스(또는 스레드)가 공유 자원에 접근할 때 충돌 없이 안전하게 작업할 수 있도록 보장하는 방법.
- 주로 임계 구역(Critical Section) 문제를 해결하기 위한 동기화 메커니즘을 의미.

### 🔹 임계 구역 (Critical Section)
- 동시에 하나의 프로세스만 접근해야 하는 공유 자원 처리 구간.
- 예: 전역 변수, 공유된 파일, 네트워크 소켓 등

### 🔹 동기화의 목적
- Race Condition 방지: 둘 이상의 프로세스가 데이터를 동시에 읽고 쓰면 비정상적인 결과 발생
- 일관성 유지: 데이터 무결성 보장

## 2. 동기화의 3가지 요구 조건(임계 구역 문제 해결 조건)
1. 상호 배제 (Mutual Exclusion): 하나의 프로세스만 임계 구역 실행 가능
2. 진행 (Progress): 임계 구역에 진입하지 않은 프로세스는 진입 여부 결정에 관여 X
3. 한정 대기 (Bounded Waiting): 무한정 대기 없이 순차적으로 기회 부여

## 3. 동기화 주요 기법
1. 뮤텍스(Mutex, Mutual Exclusion Lock)
- 한 번에 하나의 스레드만 락을 획득 가능
- 획득한 스레드만 임계 구역 진입 → 완료 후 unlock
- 소유 개념 있음: 락을 걸고 해제할 수 있는 주체는 동일해야 함
- 사용 예시: pthread_mutex, Java synchronized, C++ std::mutex
```c
pthread_mutex_t lock;

pthread_mutex_lock(&lock);
// 임계 구역
pthread_mutex_unlock(&lock);
```

2. 세마포어(Semaphore)
- 카운팅 가능한 동기화 도구
- 두 가지 연산:
    - P() 또는 wait() → 자원 요청 (count–)
	- V() 또는 signal() → 자원 반납 (count++)
- 음수가 되면 대기 큐에 블록됨
- 소유 개념 없음 → 다른 스레드가 해제 가능
종류 | 설명
-|-
Binary Semaphore | 0 or 1 (뮤텍스와 유사)
Counting Semaphore | 특정 수 이상의 동시 접근 허용 가능

3. 스핀락(Spinlock)
- 락을 획득할 때까지 CPU를 점유한 채 무한 루프(바쁜 대기).
- 컨텍스트 스위치가 비싼 커널 공간이나 짧은 락 소유 시 유리
- 주의: 멀티코어 환경에서만 유효하며, 싱글코어에서 사용하면 CPU 낭비

4. 모니터(Monitor)
- 언어 수준의 동기화 추상화
- 내부에 Lock + Condition Variable 포함
- Java, C#, Go 등에서 사용 (synchronized, wait/notify, etc.)

5. 조건 변수 (Condition Variable)
- 어떤 조건이 만족될 때까지 기다리는 데 사용
- 주로 뮤텍스와 함께 사용
- 예시:
    - pthread_cond_wait()
	- Java Object.wait() / Object.notify()

## 4. Race COndition 예제와 해결 방법
```c
int counter = 0;

void* increment(void* arg) {
    for (int i = 0; i < 1000000; i++) {
        counter++;
    }
}
```
- 위 코드에서 두 개의 스레드가 동시에 counter++를 수행하면 Race Condition 발생
- 해결책: mutex 사용

## 5. 실무 예시
분야 | 동기화 방식
-|-
다중 요청 처리 서버 (ex. Tomcat) | Thread Pool + 뮤텍스 / 세마포어
생산자-소비자 패턴 | Circular Buffer + 조건 변수
DB connection pool | Counting Semaphore
커널 영역 (락 없는 프로그래밍 포함) | Spinlock, 원자 연산, CAS(Compare-And-Swap)

## 6. 자주 묻는 면접 질문
> Q1. 세마포어와 뮤텍스의 차이는?
A.
- 뮤텍스는 1개의 자원을 보호하며 소유 개념이 있다. 세마포어는 개수(count)를 가질 수 있고, 소유 개념이 없다. 또한 세마포어는 하나의 스레드가 wait, 다른 스레드가 signal 가능.

> Q2. 스핀락은 언제 사용하나요?
A.
- 락 소유 시간이 매우 짧고, 컨텍스트 스위칭 비용이 큰 커널 공간 또는 멀티코어 환경에서 사용. 싱글코어에서는 오히려 성능 저하.

> Q3. 뮤텍스를 사용하는데도 데드락이 발생하는 이유는?
A.
- 락의 획득 순서가 꼬이면 데드락 발생 가능. 다중 자원 요청 시 락 획득 순서 통일이 중요. 해결책: 타임아웃, 정렬된 순서로 요청, 락 순서 정책 등