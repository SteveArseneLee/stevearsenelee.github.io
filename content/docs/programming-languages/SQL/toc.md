+++
title = "none"
draft = true
+++

물론입니다! 아래는 위에서 정리한 시리즈 구성에 맞춘 각 편별 상세 목차입니다. 목차 수준은 기술 블로그에 바로 사용 가능한 수준으로 구성했으며, 중단에 설명을 덧붙일 수 있도록 **계층적 헤딩 구조 (H2 / H3 / H4)**를 따랐습니다.

⸻

📘 1편: 핵심 SQL – 구조와 실행 순서

📑 목차

⸻

1. SQL 구성 순서 vs 실행 순서
	•	1.1 문법 구성 순서
	•	1.2 실제 실행 순서: FROM → WHERE → GROUP BY …

2. SELECT, FROM, AS (별칭 설정)
	•	2.1 SELECT 기본 사용
	•	2.2 AS를 통한 컬럼명 변경

3. WHERE 조건절
	•	3.1 비교 연산자
	•	3.2 AND, OR, NOT
	•	3.3 IN, BETWEEN, LIKE

4. GROUP BY와 집계 함수
	•	4.1 COUNT, AVG, SUM, MAX, MIN
	•	4.2 다중 그룹화

5. HAVING 절
	•	5.1 GROUP BY 이후 필터링
	•	5.2 HAVING vs WHERE 차이

6. ORDER BY와 LIMIT
	•	6.1 오름차순 vs 내림차순
	•	6.2 LIMIT으로 Top-N 필터링

7. 데이터 타입과 형변환
	•	7.1 CAST, :: 표현식
	•	7.2 명시적 vs 암묵적 변환

8. NULL 처리 함수
	•	8.1 IS NULL, IS NOT NULL
	•	8.2 COALESCE, NULLIF

9. 기본 내장 함수 소개
	•	9.1 문자열 함수 (LOWER, UPPER, LENGTH)
	•	9.2 숫자 함수 (ROUND, CEIL, FLOOR)
	•	9.3 조건문 함수 (CASE WHEN, IF)

⸻

📙 2편: 중급 SQL – 데이터 핸들링과 집계의 기본기

📑 목차

⸻

1. JOIN의 모든 것
	•	1.1 INNER, LEFT, RIGHT, FULL OUTER
	•	1.2 SELF JOIN, CROSS JOIN
	•	1.3 ON vs USING

2. 서브쿼리 실전
	•	2.1 WHERE절에서의 IN
	•	2.2 EXISTS 활용법
	•	2.3 SELECT절에 스칼라 서브쿼리

3. UNION / UNION ALL
	•	3.1 중복 제거 여부
	•	3.2 컬럼 수, 타입 일치 규칙

4. GROUP BY + 집계함수 고급 활용
	•	4.1 다중 그룹핑
	•	4.2 GROUP BY 없이 집계

5. HAVING의 고급 사용법
	•	5.1 필터 조건에 집계 활용
	•	5.2 그룹 필터링 전략

6. 윈도우 함수 소개
	•	6.1 OVER() 구문 구조
	•	6.2 ROW_NUMBER, RANK, DENSE_RANK
	•	6.3 LAG, LEAD, FIRST_VALUE, LAST_VALUE
	•	6.4 PARTITION BY, ORDER BY 이

⸻

📕 3편: 고급 SQL 1 – 성능 최적화와 대용량 데이터 전략

📑 목차

⸻

1. 실행 계획(EXPLAIN) 분석
	•	1.1 EXPLAIN 기본 구조
	•	1.2 실제 쿼리 예시로 계획 분석

2. 인덱스 전략
	•	2.1 B-Tree, Hash, GiST 개념
	•	2.2 복합 인덱스 / 함수 기반 인덱스

3. 쿼리 성능 저하 요인
	•	3.1 SELECT *의 문제
	•	3.2 OFFSET의 성능 문제

4. 성능 최적화 패턴
	•	4.1 셋 페이징 (Seek Method)
	•	4.2 Chunk 단위 쿼리 분할

5. CTE vs Subquery vs JOIN
	•	5.1 표현력 vs 성능
	•	5.2 실전 비교 쿼리

6. 대용량 데이터 처리 전략
	•	6.1 조건 분리 필터링
	•	6.2 인덱스와 정렬 비용
	•	6.3 메모리/디스크 병목 확인법

⸻

📗 4편: 고급 SQL 2 – 실무 분석 쿼리와 고급 함수 활용

📑 목차

⸻
	1.	WITH (CTE) 활용
• 1.1 기본 CTE
• 1.2 재귀 CTE 실전 예시
	2.	Top-N 그룹별 집계
• 2.1 ROW_NUMBER + PARTITION BY
• 2.2 사용자별 최근 3개 주문
	3.	문자열 함수 고급
• 3.1 REGEXP_REPLACE, SUBSTRING
• 3.2 SPLIT_PART, POSITION, TRIM
• 3.3 정규표현식 활용 (REGEXP_CONTAINS 등)
	4.	날짜 처리 함수
• 4.1 DATE_TRUNC, AGE, INTERVAL
• 4.2 TO_CHAR, NOW, CURRENT_DATE
	5.	조건 처리 함수 정리
• 5.1 CASE WHEN
• 5.2 COALESCE, NULLIF, IF
	6.	윈도우 함수 고급
• 6.1 ROWS BETWEEN 프레임 정의
• 6.2 누적 합계, 이동 평균
• 6.3 배열(ARRAY), 구조체(STRUCT) 데이터 처리
• 6.4 GROUPING SETS로 복합 집계하기
	7.	JSON 및 사용자 정의 함수 (UDF)
• 7.1 JSON 추출 함수 (JSON_QUERY, JSON_VALUE)
• 7.2 JSON 경로 표현식 ($.path.to.value)
• 7.3 사용자 정의 함수 생성 (CREATE FUNCTION)


⸻

📓 보너스: 실무 시나리오 모음

📑 목차

⸻

1. 사용자 행동 분석
	•	1.1 일간 재방문율
	•	1.2 세션 간격 분석

2. 주문/매출 분석
	•	2.1 월별 매출 추이
	•	2.2 카테고리별 매출 TOP 3

3. 사용자 행동 변화 분석
	•	3.1 신규 vs 기존 사용자 행동 비교
	•	3.2 사용자 레벨 별 전환율

⸻

필요하시면 각 항목에 대한 예제 코드와 실행 결과 (🧪 Result: 블록), 실전 팁(💡), 주의사항(⚠️)을 포함한 Markdown 포맷도 같이 제작해드릴 수 있습니다.
다음 단계로 어떤 편부터 본문 쓰기를 시작할지 알려주시면 이어서 작성 도와드릴게요.
