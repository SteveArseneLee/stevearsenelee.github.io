+++
title = "핵심 SQL"
draft = false
+++
### SQL 문법 순서
- ```SELECT```
- ```FROM```
- ```WHERE```
- ```GROUP BY```
- ```HAVING```
- ```ORDER BY```

```
SELECT [DISTINCT]
FROM
    [JOIN ... ON ...]
WHERE
GROUP BY
HAVING
ORDER BY
LIMIT / OFFSET (또는 TOP)
```


### SQL 실제 실행 순서
1. ```FROM``` : 데이터 소스를 먼저 읽음
2. ```ON``` : JOIN 시 결합 조건 먼저 평가
3. ```JOIN``` : 테이블 결합
4. ```WHERE``` : 결합된 결과에서 행 필터링
5. ```GROUP BY``` : 그룹화
6. ```HAVING``` : 그룹화된 결과에서 조건 필터링
7. ```SELECT``` : 필요한 컬럼, 계산식 선택
8. ```DISTINCT``` : 중복 제거
9. ```UNION``` : 여러 SELECT 쿼리 결과 결합
10. ```ORDER BY``` : 정렬
11. ```LIMIT / OFFSET / TOP``` : 결과 개수 제한


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