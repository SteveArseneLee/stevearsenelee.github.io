+++
title = "Window 함수"
draft = false
+++

## Window 함수
### 기본 형식
```sql
함수명() OVER (
  PARTITION BY 그룹기준
  ORDER BY 정렬기준
)
```
구성 요소 | 의미
-|-
PARTITION BY | 그룹핑 기준 (선택적)
ORDER BY | 정렬 기준 (필수)
OVER(...) | 윈도우 범위 지정

### 핵심 함수들
함수 | 설명 | 예시 결과
-|-|-
ROW_NUMBER() | 그룹 내 순번 (1, 2, 3, …) | 중복 있어도 고유
RANK() | 순위 부여 (동점 발생 시 건너뜀) | 1, 2, 2, 4
DENSE_RANK() | 순위 부여 (동점 건너뛰지 않음) | 1, 2, 2, 3
LAG(col, n) | 이전 n행 값 조회 | 전월 매출
LEAD(col, n) | 다음 n행 값 조회 | 다음 주문액


## 예시
예시 테이블 sales
```
id, customer, amount
1, Alice, 100
2, Bob, 200
3, Alice, 300
4, Bob, 150
5, Alice, 250
```

### 고객별 구매순위 (RANK)
```sql
SELECT
  customer,
  amount,
  RANK() OVER (
    PARTITION BY customer ORDER BY amount DESC
  ) AS rank
FROM sales;
```

### 고유 순번 (ROW_NUMBER)
```sql
SELECT
  customer,
  amount,
  ROW_NUMBER() OVER (
    PARTITION BY customer ORDER BY amount DESC
  ) AS rownum
FROM sales;
```
> → 결과는 RANK와 같지만, 중복 점수가 있어도 무조건 1, 2, 3…로 순번 매김

### 전 거래액과의 차이 (LAG())
```sql
SELECT
  customer,
  amount,
  LAG(amount) OVER (
    PARTITION BY customer ORDER BY id
  ) AS prev_amount
FROM sales;
```

### 전 거래와 비교해 증가 여부
```sql
SELECT *,
  CASE 
    WHEN amount > LAG(amount) OVER (PARTITION BY customer ORDER BY id)
    THEN '상승'
    ELSE '유지/하락'
  END AS 변화
FROM sales;
```

## 시나리오들
목적 | 함수
-|-
상위 N 뽑기 | ROW_NUMBER() + WHERE rownum <= N
그룹 내 순위 | RANK(), DENSE_RANK()
전월 대비 매출 증감 | LAG() + CASE
시계열 변화 감지 | LEAD(), LAG()
누적합 구하기 | SUM() OVER (...)

### 고객별 최고 구매액만 추출
sales
```
id, customer, amount
1, A, 100
2, A, 200
3, B, 150
4, B, 250
```
> 고객별 가장 큰 구매 1건만 추출
```sql
WITH ranked_sales AS (
  SELECT *,
         RANK() OVER (PARTITION BY customer ORDER BY amount DESC) AS rnk
  FROM sales
)
SELECT * FROM ranked_sales WHERE rnk = 1;
```

### 고객별 최근 주문과 이전 주문의 차이 구하기
```
id, customer, order_date, amount
1, A, 2024-01-01, 100
2, A, 2024-01-05, 200
3, A, 2024-01-10, 250
```

```sql
SELECT *,
  amount - LAG(amount) OVER (
    PARTITION BY customer ORDER BY order_date
  ) AS diff
FROM sales;
```