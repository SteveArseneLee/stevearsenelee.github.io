+++
title = 'SQL 요약'
draft = true
+++
## 기본 SELECT 문법 구조
```sql
SELECT column1, column2
FROM table_name
WHERE condition
GROUP BY column1
HAVING condition
ORDER BY column1
LIMIT N
```
{{% hint info %}}
실행 순서:  
FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT
{{% /hint %}}

## 필터링 및 조건문
> WHERE / AND / OR / IN / BETWEEN / LIKE

```sql
SELECT * FROM users
WHERE age >= 20 AND gender = 'M';

SELECT * FROM users
WHERE id IN (1, 2, 3);

SELECT * FROM logs
WHERE message LIKE '%error%' AND timestamp BETWEEN '2023-01-01' AND '2023-12-31';
```

## 집계 및 그룹화
> COUNT, SUM, AVG, MIN, MAX, HAVING 등
- HAVING : 그룹 집계 후 조건
```sql
SELECT gender, COUNT(*) AS user_count, AVG(score) AS avg_score
FROM users
GROUP BY gender
HAVING COUNT(*) > 10
ORDER BY avg_score DESC
```

## JOIN
### INNER JOIN
```sql
SELECT u.name, o.order_id
FROM users u
JOIN orders o ON u.user_id = o.user_id
```
### LEFT JOIN
```sql
SELECT u.name, o.order_id
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
```

## Subquery
### WHERE절에서 사용
```sql
SELECT * FROM users
WHERE age > (
    SELECT AVG(age) FROM users
)
```
### FROM 절에서 사용 (inline table)
```sql
SELECT gender, avg_score
FROM (
  SELECT gender, AVG(score) AS avg_score
  FROM users
  GROUP BY gender
) t
```

## Window 함수
> 같은 그룹 내에서 비교, 누적, 순위 등 계산
```sql
SELECT
  user_id,
  score,
  AVG(score) OVER (PARTITION BY gender) AS avg_score_by_gender,
  RANK() OVER (PARTITION BY gender ORDER BY score DESC) AS rank_in_group
FROM users
```

함수 종류 | 설명
-|-
ROW_NUMBER() | 그룹 내 순서
RANK() | 동일값 처리 포함
DENSE_RANK() | 순위 건너뛰지 않음
LAG(), LEAD() | 이전/다음 행 가져오기
SUM() OVER(...) | 누적 합계

## 날짜 처리
```sql
SELECT
  DATE_TRUNC('month', created_at) AS month,
  COUNT(*) AS cnt
FROM orders
GROUP BY 1
```
- DATE_TRUNC('day' | 'month' | 'year', timestamp)
- EXTRACT(DOW FROM date), AGE(date1, date2)
- NOW(), CURRENT_DATE

## CASE WHEN, COALESCE, NULL 처리
```sql
SELECT
  user_id,
  CASE
    WHEN score >= 90 THEN 'A'
    WHEN score >= 80 THEN 'B'
    ELSE 'C'
  END AS grade
FROM users
```
- COALESCE(col, 0) -> null 대체
- NULLIF(a, b) -> 같으면 null

## DISTINCT, LIMIT, OFFSET
```sql
SELECT DISTINCT gender FROM users;
SELECT * FROM users LIMIT 10 OFFSET 20;  -- 페이징
```

## 키셋 페이징(Seek Method)
```sql
SELECT * FROM users
WHERE (score < 80 OR (score = 80 AND id < 100))
ORDER BY score DESC, id DESC
LIMIT 10
```

## 다중 집계
```sql
SELECT
  COUNT(*) FILTER (WHERE gender = 'M') AS male_count,
  COUNT(*) FILTER (WHERE gender = 'F') AS female_count
FROM users
```