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
FROM 테이블
    [JOIN 다른_테이블 ON 조건]
WHERE 조건
GROUP BY 컬럼
HAVING 집계 조건
ORDER BY 정렬 기준
LIMIT / OFFSET (또는 TOP N)
```
흔히 코드는 위 순서로 작성하지만, DB 엔진은 실제와 다른 순서로 실행함.


### SQL 실제 실행 순서
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

{{% hint [info] %}}
- ```SELECT```에서 쓸 수 있는 컬럼은 대부분 GROUP BY 이후 정의된 컬럼
- ```ORDER BY```에서는 ```SELECT```에 없는 컬럼도 사용 가능하지만, DB마다 제약이 있을 수 있음
- ```LIMIT```은 속도 향상에 도움이 안 될수도 있음. 데이터 정렬 비용이 크면 여전히 느릴 수 있어서 인덱스를 활용하기
{{% /hint %}}