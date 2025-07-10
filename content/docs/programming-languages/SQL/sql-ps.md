+++
title = 'SQL 코딩테스트 전략'
draft = false
+++
{{% hint info %}}
문제 파악 -> 쿼리 전략 구성 -> 쿼리 작성
{{% /hint %}}

## SQL 문제 해결 프로세스(3단계)
### 1단계. 문제 파악(정확한 요구사항 읽기)
질문을 보면 항상 **무엇을 원하는가?**를 묻고 있음. 아래 3가지로 쪼개서 보면 좋음
질문 요소 | 파악할 것
-|-
무엇을 출력해야 하나? | SELECT 대상: 컬럼, 집계 결과, 파생 컬럼
어떤 조건인가? | WHERE/HAVING/JOIN/필터링
어떤 그룹/순위/변화인가? | GROUP BY, 윈도우 함수, 누적합, 차이 계산 등

e.g. "고객별로 가장 최근 주문의 금액을 출력하라"

- 무엇을 출력? -> 고객 ID, 최근 주문 금액
- 조건? -> "가장 최근 주문"(날짜 기준 정렬 필요)
- 기술? -> ROW_NUMBER() 또는 RANK() + WHERE rnk = 1

### 2단계. 전략 수립(쿼리 구성을 글로 써보기)
말로 쿼리 구성해보기  
- 고객별로 ```order_date```로 정렬한 후
- 가장 최근 주문 한 건만 남기고
- 그 고객 ID와 amount를 출력
```sql
WITH ranked AS (
  SELECT customer_id, amount,
         ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) AS rnk
  FROM orders
)
SELECT customer_id, amount
FROM ranked
WHERE rnk = 1;
```

### 3단계. 실제 쿼리 작성
- CTE가 필요하면 ```WITH```
- 파생 컬럼이 있으면 ```CASE WHEN```
- 그룹이 필요하면 ```GROUP BY```
- 변화/차이 계산이면 ```LAG, LEAD```

---
## 문제 유형별 사고 흐름 예시
### 1. "상위 N개" 문제
> “카테고리별 판매금액이 가장 높은 제품 1개씩 출력하라”

- 출력 : ```category, product, sales```
- 그룹기준 : ```category```
- 정렬기준 : ```sales DESC```
- 전략 : ```RANK() + WHERE rank = 1```

### 2. "전월 대비 변화"
> “고객별로 최근 주문과 그 이전 주문의 금액 차이 출력”

- 출력 : ```customer, amount, prev_amount, 차이```
- 정렬 : ```order_date ASC```
- 전략 : ```LAG(amount) + amount - LAG(amount)```

### 3. "누적 통계"
> “일자별 누적 매출 출력”

- 정렬 기준 : ```order_date ASC```
- 전략 : ```SUM(amount) OVER (ORDER BY order_date)```

### 4. "최근 30일 주문"
> “현재 날짜 기준 최근 30일간 주문만 집계”

- 조건 : ```order_date >= CURRENT_DATE - INTERVAL '30 days'```
- 전략 : 단순 필터 후 집계

---
## 실전 연습 문제에서 적용
> "고객별로 최근 1건의 주문을 조회하고, 해당 금액이 100 이상이면 ‘High’, 그렇지 않으면 ‘Low’를 출력하라”

- 파악:
    - 최신 주문 1건 -> ```ROW_NUMBER()```
    - 조건부 컬럼 -> ```CASE WHEN```
- 전략:
```sql
WITH latest AS (
  SELECT customer_id, amount,
         ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) AS rnk
  FROM orders
)
SELECT customer_id, amount,
       CASE WHEN amount >= 100 THEN 'High' ELSE 'Low' END AS level
FROM latest
WHERE rnk = 1;
```