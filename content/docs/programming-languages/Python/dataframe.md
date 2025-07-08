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
df[['col1', 'col2']] | 복수 컬럼 선택 | df[['name', 'score']]
df.loc[row, col] | 라벨 기반 인덱싱 | df.loc[0, 'name']
df.iloc[row, col] | 정수 기반 인덱싱 | df.iloc[0, 1]
df[df['age'] > 30] | 조건 필터링 | df[df['income'] > 50000]
df.query('age > 30') | 쿼리 방식 조건 | df.query('score >= 90')

### 4. 정렬 및 순위
메서드 | 설명 | 예제
-|-|-
df.sort_values(by) | 특정 컬럼 기준 정렬 | df.sort_values('score', ascending=False)
df.sort_index() | 인덱스 기준 정렬 | df.sort_index()
df.rank() | 순위 반환 | df['score'].rank(ascending=False)

### 5. 그룹화 및 집계
메서드 | 설명 | 예제
-|-|-
df.groupby('col') | 그룹 객체 생성 | df.groupby('gender')
group.sum() / mean() / count() | 그룹별 집계 | df.groupby('gender')['score'].mean()
group.agg({...}) | 다중 집계 | df.groupby('gender').agg({'score' : ['mean', 'max]})
pd.pivot_table() | 피벗테이블 생성 | pd.pivot_table(df, values='score', index='gender', aggfunc='mean')

### 6. 컬럼 생성 및 변경
메서드 | 설명 | 예제
-|-|-
df['new'] = ... | 새로운 컬럼 생성 | df['income_per_age'] = df['income'] / df['age']
df.rename() | 컬럼명 변경 | df.rename(columns={'old' : 'new'})
df.assign() | 새로운 컬럼 추가 | df.assign(adjusted_score = df['score] + 5)
df.eval() | 수식 기반 연산 | df.eval('ratio = income / age')

### 7. 문자열 및 날짜 처리
메서드 | 설명 | 예제
-|-|-
df['col'].str.lower() | 소문자 변환 | df['name'].str.lower()
df['col'].str.contains() | 특정 문자열 포함 여부 | df['name'].str.contains('Kim')
pd.to_datetime() | datetime 변환 | df['date'] = pd.to_datetime(df['date'])
df['date'].dt.year/month/day | 날짜 속성 추출 | df['date'].dt.year

### 8. 결합 및 병합
메서드 | 설명 | 예제
-|-|-
pd.concat([df1, df2]) | 행/열 단위 연결 | pd.concat([df1, df2], axis=0)
df.merge() | SQL JOIN 방식 병합 | df1.merge(df2, on='id', how='left')
df.join() | 인덱스 기준 병합 | df1.join(df2, lsuffix='_left', rsuffix='_right')

### 9. 고급 처리 및 변환
메서드 | 설명 | 예제
-|-|-
df.apply(func) | 행/열 단위 함수 적용 | df['score'].apply(lambda x: x * 1.1)
df.map() | Series 전용 매핑 | df['gender'].map({'M': '남', 'F': '여'})
df.transform() | 그룹 내 개별 값 변환 | df.groupby('gender')['score'].transform('mean')
df.melt() | wide -> long 변환 | df.melt(id_vars='id', value_vars=['math', 'english'])
df.pivot() | long -> wide 변환 | df.pivot(index='id', columns='subject', values='score')

### 10. 기타 실전 유용 메서드
메서드 | 설명 | 예제
-|-|-
df.duplicated() | 중복 행 여부 | df[df.duplicated('user_id')]
df.drop_duplicates() | 중복 제거 | df.drop_duplicates(['name'])
df.sample(n) | 샘플 추출 | df.sample(3)
df.value_counts() | 고유값 개수 | df['gender'].value_counts()
df.nunique() | 고유값 수 | df.nunique()