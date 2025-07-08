+++
title = 'DataFrame 실습'
draft = false
+++
### 1. 구조 및 정보 확인
메서드 | 설명 | 예제
-|-|-
df.head(n) | 상위 n개 행 확인 | df.head(5)
df.tail(n) | 하위 n개 행 확인 | df.tail(3)
df.shape | 행과 열의 수 반환(tuple) | (row, col) = df.shape
df.info() | 데이터 타입, null 여부 등 요약 | df.info()
df.describe() | 수치형 데이터의 요약 통계 | df.describe()
df.columns | 컬럼명 확인 | df.columns.tolist()
df.index | 인덱스 확인 | df.index
df.dtypes | 각 컬럼의 자료형 | df.dtypes
df.memory_usage() | 메모리 사용량 확인 | df.memory_usage(deep=True)

### 2. 결측치 및 이상치 처리
메서드 | 설명 | 예제
-|-|-
df.isnull() | 결측치 여부(True/False) | df.isnull().sum()
df.notnull() | 결측치 아님 여부 | df[df['col'].notnull()]
df.dropna() | 결측치 포함 행 제거 | df.dropna()
df.fillna(value) | 결측치 대체 | df.fillna(0)
df.replace(a,b) | 값 대체 | df.replace('N/A', None)

### 3. 데이터 선택 및 필터링
메서드/문법 | 설명 | 예제
-|-|-
df['col'] | 단일 컬럼 선택 | df['age']
