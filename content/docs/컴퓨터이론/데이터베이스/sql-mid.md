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

## 3. UNION / UNION ALL
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


## 4. Filtering + Aggregation
데이터를 그룹핑하고 집계하는 경우, 조건을 어디서 거느냐에 따라 결과가 달라지거나 성능에 큰 차이가 남
```sql
SELECT user_id, COUNT(*) AS click_count
FROM events
WHERE event_type = 'click'
GROUP BY user_id
HAVING COUNT(*) > 5;
```
절 | 시점 | 대상 | 설명
-|-|-|-
WHERE | GROUP 전 | 개별 행 | 행 단위 필터링
HAVING | GROUP 후 | 집계된 그룹 | 집계 후 필터링

흐름 설명
1. ```WHERE```로 클릭 이벤트만 필터링 -> 집계 대상이 줄어듦 (성능 개선)
2. ```GROUP BY user_id``` -> 사용자별로 클릭 수를 셈
3. ```HAVING COUNT(*) > 5``` -> 5회 초과한 사용자만 남김

{{% hint warning %}}
- ```WHERE```로 최대한 먼저 필터링해서 불필요한 데이터 계산을 줄이기
- ```HAVING```은 집계 결과를 기준으로 조건 걸 때만 사용하기
- 집계 없이 ```HAVING```만 쓰는 것도 가능하지만, 이럴 땐 ```WHERE```이 더 적절한 경우가 많음
{{% /hint %}}

> HAVING은 반드시 집계 함수와 함께 쓰일 필요는 없지만, 그렇게 쓰는 경우가 일반적

## 5. Window 함수
기존의 ```GROUP BY```는 집계를 하면 개별 행 정보가 사라짐. 반면, 윈도우 함수는 각 행을 유지한 채로 집계 정보를 덧붙이는 것이 가능해서 **순위 매기기, 변화 감지, 누적값 계산** 등 다양한 분석에 매우 유용

### 기본 구조
```sql
<윈도우 함수>() OVER (PARTITION BY <그룹 기준> ORDER BY <정렬 기준>)
```

### 주요 함수들
함수 | 설명
-|-
ROW_NUMBER() | 각 그룹 내에서 순차적으로 번호 매김
RANK() | 순위 매김, 동일 순위 존재 시 다음 순위는 건너뜀 (1,1,3)
DENSE_RANK() | 순위 매김, 동일 순위 존재 시 다음 순위는 바로 이어짐 (1,1,2)
SUM() OVER | 누적 합계 계산
AVG() OVER | 누적 평균 계산
LAG() | 이전 행의 값 참조
LEAD() | 다음 행의 값 참조

예시) 사용자별 최근 클릭 1건만 보기
```sql
SELECT *
FROM (
  SELECT *,
         ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY event_time DESC) AS rn
  FROM events
  WHERE event_type = 'click'
) t
WHERE rn = 1;
```

{{% hint warning %}}
- 윈도우 함수는 GROUP BY와는 달리 행이 줄지 않음. 개별 행을 유지한 채로 통계치를 부여함
- 시간 기반 분석(예: 이전 값과 비교, 최근 이벤트 찾기)에 특히 강력함
- PARTITION BY 없이 전체 기준으로도 사용 가능
{{% /hint %}}
