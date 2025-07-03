+++
title = "중급 SQL"
draft = false
weight = 2
+++

JOIN -> Subquery -> UNION -> Filtering+Aggregation -> Window

## 1. JOIN
JOIN 종류 | 설명
-|-
INNER JOIN | 양쪽 테이블 모두 일치하는 데이터만 반환
LEFT JOIN | 왼쪽 테이블은 무조건, 오른쪽은 조건 만족 시
RIGHT JOIN | 오른쪽 테이블은 무조건, 왼쪽은 조건 만족 시
FULL OUTER | 양쪽 테이블 모두 포함
SELF JOIN | 자기 자신과 JOIN

## 2. Subquery
복잡한 조건을 쿼리 안에 분리해 표현할 수 있게 해주는 도구.
- 특정 조건에 맞는 ID만 추출해서 바깥 커리에서 사용하고 싶을 때 (IN)
- 존재 여부만 판단하고 싶을 때 (EXISTS)
- 행마다 계산된 단일 값을 붙이고 싶을 때 (스칼라 쿼리)
- 복잡한 JOIN을 대체하거나 명확하게 표현하고 싶을 때

### IN Subquery
```sql
SELECT *
FROM users
WHERE user_id IN (
  SELECT user_id
  FROM events
  WHERE event_type = 'click'
);
```
어떤 값이 존재하는지를 체크
- events 테이블에서 클릭 이벤트가 있었던 사용자만 조회
- 반환 결과가 0개면 IN 조건은 거짓

### EXISTS Subquery
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

### 스칼라 Subquery
```sql
SELECT name, (
  SELECT COUNT(*) FROM orders o WHERE o.user_id = u.user_id
) AS order_count
FROM users u;
```
각 행마다 1개의 값 계산
- 각 사용자마다 주문 수를 계산해 붙임
- 내부 쿼리는 행당 정확히 하나의 값만 반환해야 함

### 상관 Subquery (Correlated Subquery)
- 바깥 쿼리의 컬럼 값을 내부 쿼리에서 참조
- EXISTS, 스칼라 서브쿼리는 대


## 1. Filtering + Aggregation
```
SELECT user_id, COUNT(*)
FROM events
WHERE event_type = 'click'
GROUP BY user_id
HAVING COUNT(*) > 5;
```
위 sql을 기반으로 함

```WHERE```과 ```HAVING```의 차이
- ```WHERE```은 데이터가 그룹화되기 전에 적용되어 개별 행을 필터링
- ```HAVING```은 그룹화 후에 적용되어 집계된 그룹을 필터링

집계에 들어가는 쿼리를 줄이려면 ```WHERE```를 써야함  
집계 결과를 기반으로 필터링하려면 ```HAVING```을 써야함  
따라서... 위 쿼리를 보면
- ```WHERE event_type = 'click'```은 클릭 이벤트가 아닌 것을 모두 필터링함
- ```GROUP BY user_id```는 나머지 데이터를 사용자별로 그룹화함
- ```HAVING COUNT(*) > 5```는 5번 이상 클릭한 사용자만 보여줌
