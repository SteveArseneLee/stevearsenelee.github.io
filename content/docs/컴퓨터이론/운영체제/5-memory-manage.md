+++
title = "5. 메모리 관리"
draft = false
+++
## 1. 메모리의 계층 구조 및 주소 체계
### 메모리 계층 구조
- CPU -> register -> cache -> main memory(RAM) -> SSD/HDD
- OS 입장에서는 **main memory(RAM)**을 관리하는 게 핵심

### 주소 체계
구분 | 설명
-|-
논리 주소(Logical Address) | CPU가 생성한 주소 (프로세스 입장에서의 주소)
물리 주소(Physical Address) | 실제 메모리 하드웨어 상의 주소
가상 주소(Virtual Address) | 논리 주소와 같으며, MMU가 물리 주소로 변환

=> MMU (Memory Management Unit): 논리 주소를 물리 주소로 변환하는 하드웨어. 페이징 기반 시스템에서 핵심 역할.

## 2. 메모리 단편화(Fragmentation)
### 내부 단편화 (Internal Fragmentation)
- 프로세스가 할당받은 메모리보다 적은 양만 사용하는 경우
- ex) 12KB 필요한데 16KB 단위로만 할당 → 4KB 낭비

### 외부 단편화 (External Fragmentation)
- 총 메모리는 충분하지만 연속된 공간이 부족해서 할당 불가
- ex) 5KB, 3KB, 4KB, … 식으로 쪼개져 있어 10KB 요청 실패

### 해결 전략
문제 | 해결 방식
-|-
내부 단편화 | 가변 크기 할당 (slab, buddy, paging 등)
외부 단편화 | 페이징, 세그멘테이션, 압축(compaction) 등

## 3. 메모리 할당 기법
### 연속 할당 (Contiguous Allocation)
- 프로세스는 하나의 연속된 메모리 블록을 할당받음
- 단순하지만 외부 단편화 발생 가능
방식 | 설명
-|-
단순 분할 (Fixed) | 동일 크기의 파티션
가변 분할 (Dynamic) | 프로세스 크기에 따라 동적 할당

할당 전략 (First Fit, Best Fit, Worst Fit)
- First Fit: 첫 번째로 맞는 공간
- Best Fit: 가장 크기가 근접한 공간 (외부 단편화 ↑)
- Worst Fit: 가장 큰 공간 (파편 방지 목적)

### 페이징 (Paging)
- 물리 메모리를 고정된 크기(Frame)로 나누고, 프로세스도 동일한 크기(Page)로 나눔
- 페이지 단위로 분산 저장 가능 -> 외부 단편화 제거
요소 | 설명
-|-
Page | 논리 주소 공간의 단위
Frame | 물리 주소 공간의 단위
Page Table | Page 번호 → Frame 번호 매핑 정보 저장
MMU | 주소 변환 시 Page Table 참조

=> 단점: Page Table 크기 증가, TLB 미스 발생 가능

### 세그멘테이션 (Segmentation)
- 프로세스를 의미 있는 논리 단위(코드, 데이터, 스택 등)로 나눔
- 각 세그먼트는 크기/시작 주소가 다름
- 주소 = (세그먼트 번호, 오프셋) 형태

장점 : 논리적 구조 반영  
단점 : 외부 단편화 발생 가능

## 4. 논리 주소 -> 물리 주소 변환 과정
방식 | 변환 방식 | 특징
-|-|-
연속 할당 | Base + offset | 구조 단순
페이징 | Page Number + Offset → Frame | 고정 크기 블록, 내부 단편화 가능
세그멘테이션 | Segment + Offset → Physical | 논리 구조 반영, 외부 단편화 발생

## 5. 실무 예시
사례 | 설명
-|-
Linux | 페이징 기반, 가상 메모리 + TLB 사용
Embedded 시스템 | 연속 할당 또는 세그멘테이션 구조
Heap Allocator | 내부 단편화 방지 위해 Slab, Buddy Allocator 사용
Docker/VM | 가상 주소 공간을 격리하기 위해 페이지 테이블 관리 필수

## 6. 자주 묻는 면접 질문
> Q1. 페이징과 세그멘테이션의 차이는?

A.
항목 | 페이징 | 세그멘테이션
-|-|-
단위 | 고정 크기 Page | 가변 크기 Segment
단편화 | 내부 단편화 | 외부 단편화
구조 | 단순, 추상도 낮음 | 논리 구조 표현 가능
주소 형식 | Page No + Offset | Segment No + Offset

> Q2. 외부 단편화와 내부 단편화는 무엇이고, 각각 어떻게 해결하나요?

A.
- 내부 단편화: 고정 크기 할당 시, 일부 미사용 공간 → 페이징, slab allocator
- 외부 단편화: 가변 할당 시, 작은 조각들 → 페이징, 압축, 세그멘테이션


> Q3. Page Table이 너무 커지면 어떻게 해결하나요?

A. 
- 다단계 페이지 테이블
- TLB (Translation Lookaside Buffer): 캐시 역할
- 페이징+세그멘테이션 혼합 구조