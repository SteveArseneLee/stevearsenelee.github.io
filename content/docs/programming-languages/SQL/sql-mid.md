+++
title = "SQL - 중급"
draft = false
weight = 2
+++
## JOIN의 모든 것
### INNER, LEFT, RIGHT, FULL OUTER
JOIN 종류 | 설명
-|-
INNER JOIN | 양쪽 테이블 모두 일치하는 데이터만 반환
LEFT JOIN | 왼쪽 테이블은 무조건, 오른쪽은 조건 만족 시
RIGHT JOIN | 오른쪽 테이블은 무조건, 왼쪽은 조건 만족 시
FULL OUTER | 양쪽 테이블 모두 포함
SELF JOIN | 자기 자신과 JOIN
### SELF JOIN, CROSS JOIN
- ```SELF JOIN``` : 같은 테이블을 자기 자신과 JOIN
```sql
SELECT a.name, b.name
FROM employees a
JOIN employees b ON a.manager_id = b.employee_id;
```
- ```CROSS JOIN``` : 조건없이 모든 조합 (Cartesian Product)
```sql
SELECT a.*, b.*
FROM products a
CROSS JOIN categories b;
```

### ON vs USING
- ```ON``` : 조인 조건을 명시적으로 표현
- ```USING``` : 동일한 컬럼명이 양쪽 테이블에 있을 때 축약 표현
```sql
-- ON
SELECT * FROM a JOIN b ON a.id = b.id;

-- USING
SELECT * FROM a JOIN b USING (id);
```

## SubQuery
복잡한 조건을 쿼리 안에 분리해 표현할 수 있게 해주는 도구.
- 특정 조건에 맞는 ID만 추출해서 바깥 커리에서 사용하고 싶을 때 (IN)
- 존재 여부만 판단하고 싶을 때 (EXISTS)
- 행마다 계산된 단일 값을 붙이고 싶을 때 (스칼라 쿼리)
- 복잡한 JOIN을 대체하거나 명확하게 표현하고 싶을 때
### WHERE절에서의 IN
```sql
SELECT *
FROM users
WHERE user_id IN (
  SELECT user_id
  FROM events
  WHERE event_type = 'click'
);
```
- 특정 조건을 만족하는 ID만 필터링

### EXISTS 활용법
```sql
SELECT *
FROM users u
WHERE EXISTS (
  SELECT 1
  FROM events e
  WHERE e.user_id = u.user_id
);
```
존재 여부만 확인
- users 테이블의 각 행에 대해 events에 해당 user_id가 존재하는지만 확인
- ```SELECT 1```처럼 실제로 필요한 컬럼이 없어도 상관없음
{% hint info %}
- EXISTS는 내부 쿼리가 한 번이라도 TRUE를 반환하면 성립
- 데이터량이 많을 경우 IN보다 효율적일 수 있음
{% /hint %}

### SELECT절에 scala subquery
```sql
SELECT name, (
  SELECT COUNT(*)
  FROM orders o
  WHERE o.user_id = u.user_id
) AS order_count
FROM users u;
```
각 행마다 1개의 값 계산
- 각 사용자마다 주문 수를 계산해 붙임
- 내부 쿼리는 행당 정확히 하나의 값만 반환해야 함
> 대부분의 스칼라 쿼리는 상관 서브쿼리 (바깥값 참조)

### 상관 Subquery (Correlated Subquery)
- 바깥 쿼리의 컬럼 값을 내부 쿼리에서 참조
- EXISTS, 스칼라 서브쿼리는 대부분 상관 서브쿼리임
```sql
SELECT *
FROM users u
WHERE 100 < (
  SELECT COUNT(*)
  FROM orders o
  WHERE o.user_id = u.user_id
);
```
- 사용자별로 주문 수가 100건을 초과하는 사용자 단위


## UNION / UNION ALL
### 중복 제거 여부
분리된 두 쿼리의 결과를 하나로 합쳐야 할때 사용함.
구문 | 중복 제거 | 설명
-|-|-
UNION | O | 두 결과 집합에서 중복 제거
UNION ALL | X | 중복 포함, 성능 빠름
```sql
SELECT user_id FROM app_users
UNION
SELECT user_id FROM web_users;
```

- ```UNION ALL```은 중복 제거를 하지 않아서 속도가 빠름
- 중복 제거가 필요하면 사후에 ```SELECT DISTINCT```를 사용하는 것도 고려해볼 수 있음
- 각 ```SELECT``` 구문은 컬럼 수, 타입 순서가 같아야 함. 하나라도 다르면 오류 발생
### 컬럼 수, 타입 일치 규칙
- 각 ```SELECT``` 쿼리는 컬럼 수와 타입이 같아야 함
- 이름은 달라도 상관없지만 순서가 맞아야 함

## GROUP BY + 집계함수 고급 활용
### 다중 그룹핑
```sql
SELECT department, job_title, COUNT(*) AS 인원수
FROM employees
GROUP BY department, job_title;
```
- 2개 이상 컬럼으로 그룹핑하면, 조합별 집계 가능
### GROUP BY 없이 집계
- 전체 테이블 대상 통계
```sql
SELECT COUNT(*) FROM users;
SELECT AVG(score) FROM exams;
```

## HAVING의 고급 사용법
### 필터 조건에 집계 활용
```sql
SELECT department, COUNT(*) AS cnt
FROM employees
GROUP BY department
HAVING COUNT(*) >= 10;
```
- ```HAVING```은 집계된 값에 조건을 걸 때 사용
### 그룹 필터링 전략
절 | 시점 | 대상 | 특징
-|-|-|-
WHERE | 그룹 전 | 개별 행 | 빠르고 효율적 필터링 가능
HAVING | 그룹 후 | 집계 그룹 | 통계 기반 조건에 필수적
- 집계 조건은 ```HAVING```, 행 필터링은 ```WHERE```에서

## 윈도우 함수
### OVER() 구문 구조
```sql
<윈도우 함수>() OVER (
  PARTITION BY <그룹 기준>
  ORDER BY <정렬 기준>
)
```
- ```PARTITION BY``` : 그룹 단위 나누기
- ```ORDER BY``` : 순서 기준 지정
### ROW_NUMBER, RANK, DENSE_RANK
함수 | 설명
-|-
ROW_NUMBER() | 순번 부여 (중복 없는 고유 순번)
RANK() | 동일값은 동일 순위, 건너뜀 (1,1,3)
DENSE_RANK() | 동일값 동일 순위, 건너뛰지 않음 (1,1,2)

### LAG, LEAD, FIRST_VALUE, LAST_VALUE
함수 | 설명
-|-
LAG() | 이전 행의 값 참조
LEAD() | 다음 행의 값 참조
FIRST_VALUE() | 그룹 내 첫 값
LAST_VALUE() | 그룹 내 마지막 값

### PARTITION BY, ORDER BY 차이
절 | 그룹 역할 | 예시 사용
-|-|-
PARTITION BY | 그룹 단위 분리 | 사용자별, 지역별 통계 등
ORDER BY | 순서 지정 | 시간순 정렬, 점수 순 정렬 등

예시) 사용자별 최근 클릭 1건
```sql
SELECT *
FROM (
  SELECT *,
         ROW_NUMBER() OVER(
           PARTITION BY user_id
           ORDER BY event_time DESC
         ) AS rn
  FROM events
  WHERE event_type = 'click'
) t
WHERE rn = 1;
```
> 윈도우 함수는 GROUP BY와 달리 행 수가 줄지 않음
> 분석 목적에 따라 GROUP BY보다 훨씬 유연하게 사용 가능
