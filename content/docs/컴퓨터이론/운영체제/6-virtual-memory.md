+++
title = "6. 가상 메모리"
draft = false
+++
## 1. 정의

**가상 메모리(Virtual Memory)** 는 프로세스가 실제 물리 메모리보다 더 큰 주소 공간을 사용할 수 있도록 지원하는 메커니즘
> 논리 주소 ↔ 물리 주소 변환을 통해, 프로세스는 독립된 메모리 공간을 가진 것처럼 동작할 수 있음.

### 목적
- 프로세스 간 메모리 격리 및 보호
- 실제 메모리보다 큰 공간 지원 (주소 추상화)
- 프로그램의 효율적 로딩 및 실행 (부분 적재, Demand Paging)

## 2. 주소 변환 흐름 (Page 기반)
주소 구조
```text
[논리 주소] = [페이지 번호] + [페이지 오프셋]
→ MMU가 페이지 번호를 Page Table 통해 물리 메모리의 Frame으로 변환
→ 최종 물리 주소 = Frame 시작 주소 + Offset
```
e.g.
- 가상 주소 : 0x1234 (4KB 페이지 크기)
- -> 페이지 번호 : 0x1, 오프셋 : 0x234
- -> Page Table에서 Page 1이 Frame 5에 매핑되어 있으면
- -> 물리 주소 = 5 * 4KB + 0x234

## 3. TLB(Translation Lookaside Buffer)
- Page Table을 매번 조회하면 성능 저하 → TLB는 MMU 내부에 있는 캐시
- 최근 사용된 페이지 번호와 프레임 매핑 정보를 저장

상황 | 설명
-|-
TLB Hit | TLB에서 바로 프레임 주소 조회
TLB Miss | Page Table 조회 필요 → TLB 갱신

=> TLB는 매우 빠르지만 용량 제한 있음 -> LRU 기반 캐시 정책 적용

## 4. Demand Paging
실제 필요한 페이지만 메모리에 로드하는 방식 (→ 전체 프로그램을 처음부터 메모리에 올리지 않음)
### 흐름
1.	프로세스가 아직 로드되지 않은 페이지 접근
2.	Page Fault 발생 (해당 페이지 없음)
3.	디스크에서 해당 페이지 로드
4.	Page Table 및 TLB 갱신 후 재시도

장점 : 메모리 절약, 빠른 프로세스 시작
단점 : Page Fault 시 디스크 접근 -> 심각한 성능 저하

## 5. 페이지 교체 알고리즘
1. FIFO (First-In First-Out)
- 가장 오래된 페이지를 제거
- 구현은 쉽지만, Belady's anomaly 발생 가능 (페이지 수 ↑ → 오히려 Miss ↑)
2. LRU (Least Recently Used)
- 가장 오랫동안 사용되지 않은 페이지 제거
- 현실적인 성능 우수 → 구현은 상대적으로 복잡
3. Optimal (OPT)
- 앞으로 가장 오랫동안 사용되지 않을 페이지 제거
- 이상적인 알고리즘 (실제로 구현 불가 → 벤치마크용)
4. Clock 알고리즘 (Second Chance)
- LRU 근사 방식. 각 페이지에 reference bit 사용
- 원형 큐 순회하며 bit=0인 페이지 제거

알고리즘 | 특징 | 성능 | 구현 난이도
-|-|-|-
FIFO | 단순 | 낮음 | 쉬움
LRU | 실제 상황에 적합 | 좋음 | 어려움 (stack/counter 필요)
OPT | 최적 | 최고 | 불가능
Clock | LRU 근사 | 중상 | 중간

## 6. Working Set & Thrashing
### Working Set
- 지역성을 기반으로 가장 많이 사용하는 페이지를 미리 저장해둔 것
- 일정 시간 동안 참조되는 페이지 집합

### Thrashing
- Working Set보다 할당된 메모리 프레임이 적을 때 발생
- 페이지 교체가 빈번히 일어나면서 시스템 전체 성능 저하

### 해결
- 프로세스 별 Working Set 기반 프레임 동적 할당
- 페이지 교체 알고리즘 개선
- 프로세스 수 조절

## 7. 실무 예시
시스템 | 가상 메모리 동작
-|-
Linux | Demand Paging + Clock-based replacement (Clock-Pro)
Windows | Working Set 기반 프레임 관리 + Aging 정책
Docker/Container | Namespace 및 CGroup 기반 메모리 격리, 가상 주소 사용
JVM | Heap 영역이 논리 주소 → 실제 물리 할당은 GC와 OS가 결정

## 8. 자주 묻는 면접 질문
> Q1. 페이지 교체 알고리즘 중 가장 좋은 건?

A.
- 이론적으로는 OPT가 가장 우수하나 실제 구현 불가. LRU가 현실적으로 가장 균형 잡힘. Clock 알고리즘은 구현과 성능의 트레이드오프를 잘 반영한 방식.

> Q2. TLB Miss가 자주 발생하는 이유와 해결 방법은?

A.
- 프로세스 전환 시 TLB 내용이 무효화되기 때문 → Context Switch + Address Space Identifier(ASID) 사용으로 완화 가능.

> Q3. Thrashing이 발생하는 이유는?

A.
Working Set보다 작은 수의 프레임 할당 → 계속 페이지 교체 발생 → CPU보다 I/O가 바빠짐 → 시스템 정체

> Q4. Page Fault가 발생했을 때 처리 과정은?
1.	MMU가 Page Table 확인 → 없는 페이지
2.	OS가 디스크에서 페이지 로딩
3.	Page Table 갱신
4.	TLB 갱신
5.	프로세스 재시도