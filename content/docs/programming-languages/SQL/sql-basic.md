+++
title = "SQL - 기본"
draft = false
weight = 1
+++
## SQL 구성 순서 vs 실행 순서
### 문법 구성 순서
- ```SELECT```
- ```FROM```
- ```WHERE```
- ```GROUP BY```
- ```HAVING```
- ```ORDER BY```

```sql
SELECT [DISTINCT]
FROM 테이블
    [JOIN 다른_테이블 ON 조건]
WHERE 조건
GROUP BY 컬럼
HAVING 집계 조건
ORDER BY 정렬 기준
LIMIT / OFFSET (또는 TOP N)
```
흔히 코드는 위 순서로 작성하지만, DB 엔진은 실제와 다른 순서로 실행함.

### 실제 실행 순서
단계 | 절(Clause) | 설명
-|-|-
1️⃣ | FROM | 조회할 테이블 또는 서브쿼리부터 시작
2️⃣ | ON | JOIN 조건 평가 (필요 시)
3️⃣ | JOIN | 테이블 결합 수행
4️⃣ | WHERE | 행(Row) 필터링
5️⃣ | GROUP BY | 그룹핑
6️⃣ | HAVING | 그룹 결과 필터링
7️⃣ | SELECT | 컬럼 선택 및 계산
8️⃣ | DISTINCT | 중복 제거
9️⃣ | UNION | 여러 SELECT 결과 결합 (옵션)
🔟 | ORDER BY | 정렬 수행
🔚 | LIMIT / OFFSET / TOP | 결과 개수 제한

> WHERE은 행 기준 필터, HAVING은 그룹 기준 필터

{{% hint info %}}
- ```SELECT```에서 쓸 수 있는 컬럼은 대부분 GROUP BY 이후 정의된 컬럼
- ```ORDER BY```에서는 ```SELECT```에 없는 컬럼도 사용 가능하지만, DB마다 제약이 있을 수 있음
- ```LIMIT```은 속도 향상에 도움이 안 될수도 있음. 데이터 정렬 비용이 크면 여전히 느릴 수 있어서 인덱스를 활용하기
{{% /hint %}}

## SELECT, FROM, AS (Alias)
### SELECT 기본 사용
SELECT는 출력할 컬럼을 지정하는 절. FROM으로부터 지정된 테이블로부터 필요한 컬럼만 선택해서 가져옴
```sql
SELECT name, age
FROM users;
```
- ```SELECT * FROM users;``` ← 실무에서는 비추천 (성능 및 가독성 저하)

### AS를 통한 컬럼명 변경
```AS```를 이용해 출력 결과의 컬럼명을 변경할 수 있음
```sql
SELECT name AS 사용자명, age AS 나이
FROM users;
```
- ```AS```는 생략 가능하지만 명시하는게 가독성 측면에서 좋음
- 숫자 계산, 집계 함수 등에도 사용 가능
```sql
SELECT price * quantity AS 총액
FROM orders;
```

## WHERE 조건절
### 비교 연산자
```sql
=, !=, <>, >, <, >=, <=
```
```sql
SELECT *
FROM users
WHERE age >= 30;
```

### AND, OR, NOT
- 여러 조건을 조합해 필터링할 수 있음
```sql
SELECT *
FROM users
WHERE age > 20 AND city = 'Seoul';
```
- 괄호로 우선순위를 명확히 할 수 있음
```sql
WHERE (age > 20 AND city = 'Seoul') OR is_active = TRUE;
```

### IN, BETWEEN, LIKE
- ```IN``` : 목록 중 하나일 때
```sql
WHERE country IN ('Korea', 'Japan', 'USA')
```
- ```BETWEEN``` : 범위 포함 (시작과 끝 포함)
```sql
WHERE age BETWEEN 20 AND 29
```
- ```LIKE``` : 패턴 매칭 (%는 와일드카드)
```sql
WHERE name LIKE 'Kim%'
```

## GROUP BY와 집계 함수
### COUNT, AVG, SUM, MAX, MIN
함수 | 설명
-|-
COUNT() | 개수
AVG() | 평균
SUM() | 합계
MAX() | 최댓값
MIN() | 최솟값

```sql
SELECT department, COUNT(*) AS 인원수
FROM employees
GROUP BY department;
```

### 다중 그룹화
2개 이상의 컬럼으로 그룹화할 수 있음
```sql
SELECT department, job_title, COUNT(*) AS 인원수
FROM employees
GROUP BY department, job_title;
```

## HAVING 절
### GROUP BY 이후 필터링
- HAVING은 그룹 결과에 조건을 걸 때 사용함
```sql
SELECT department, COUNT(*) AS 인원수
FROM employees
GROUP BY department
HAVING COUNT(*) >= 5;
```

### HAVING VS WHERE 차이
항목 | WHERE | HAVING
-|-|-
사용 시점 | 그룹화 이전 | 그룹화 이후
대상 | 개별 행(Row) | 집계된 그룹(Group)
집계 사용 | 불가능 | 가능 (COUNT, SUM 등)

## ORDER BY와 LIMIT
### 오름차순 vs 내림차순
- 기본은 오름차순 (ASC)
- 내림차순은 DESC 지정
```sql
SELECT name, age
FROM users
ORDER BY age DESC;
```
- 숫자, 문자열, 날짜 모두 정렬 가능
### LIMIT으로 Top-N 필터링
- 특정 개수만 조회하고 싶을 때 사용
```sql
SELECT *
FROM products
ORDER BY price DESC
LIMIT 10;
```
- ```OFFSET```과 함께 사용해 페이지네이션 구현 가능
```sql
LIMIT 10 OFFSET 20 -- 21번째부터 10개
```

## 데이터 타입과 형변환
### CAST, :: 표현식
```sql
SELECT CAST('123' AS INTEGER);
SELECT '2024-01-01'::DATE;
```
### 명시적 vs 암묵적 변환
- 명시적 : ```CAST()``` 또는 ```::``` 사용
- 암묵적 : DB가 자동으로 타입을 맞춰줌

> 실무에선 명시적 변환을 사용하는 것이 안전함

## NULL 처리 함수
### IS NULL, IS NOT NULL
```sql
SELECT *
FROM users
WHERE deleted_at IS NULL;
```
- ```= NULL```은 작동하지 않음. 반드시 ```IS NULL``` 사용

### COALESCE, NULLIF
- ```COALESCE``` : 첫 번째 ```NOT NULL``` 값을 반환
```sql
SELECT COALESCE(nickname, name) AS 표시이름
FROM users;
```
- ```NULLIF``` : 두 값이 같으면 ```NULL``` 반환
```sql
SELECT NULLIF(score, 0) AS score_check
FROM results;
```

## 기본 내장 함수
### 문자열 함수 (LOWER, UPPER, LENGTH)
함수 | 설명
-|-
LOWER() | 소문자로 변환
UPPER() | 대문자로 변환
LENGTH() | 문자열 길이 반환
```sql
SELECT LOWER(name), LENGTH(name)
FROM users;
```

### 숫자 함수 (ROUND, CEIL, FLOOR)
함수 | 설명
-|-
ROUND() | 반올림
CEIL() | 올림
FLOOR() | 내림

```sql
SELECT ROUND(price), FLOOR(rating)
FROM products;
```

### 조건문 함수 (CASE WHEN, IF)
```sql
SELECT
  name,
  CASE
    WHEN age >= 20 THEN '성인'
    ELSE '미성년자'
  END AS 구분
FROM users;
```
- 일부 DB는 IF(조건, 참, 거짓)도 지원함(MySQL)


