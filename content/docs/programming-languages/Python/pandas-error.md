+++
title = 'Pandas기반 에러/예외 대응 전략'
draft = false
+++
## 형 변환 에러 대응
### 문자열 -> 숫자 (to_numeric)
```py
df['amount'] = pd.to_numeric(df['raw_amount'], errors='coerce')
```
- 문제 : "12.5", "100원", "abc", "" -> 숫자로 안 바뀜
- 해결 : errors='coerce'로 문제값을 NaN 처리 후 dropna() 또는 fillna()

### 문자열 -> 날짜 (to_datetime)
```py
df['date'] = pd.to_datetime(df['raw_date'], errors='coerce')
```
- 문제 : "2023/10/15", "15-10-2023", "bad date" 등 포맷 불일치
- 해결 : 강제 변환 + NaT로 처리

### 타입 변환 실패 (astype)
```py
try:
    df['age'] = df['age'].astype(int)
except ValueError:
    df['age'] = pd.to_numeric(df['age'], errors='coerce')
```
- astype은 실패 시 에러 발생 -> to_numeric 사용으로 대체

## 결측치 대응
1. 결측치 탐지 및 제거
```py
df.isnull().sum() # 컬럼별 null 개수 확인
df.dropna(subset=['score']) # 특정 컬럼에 null이 있으면 제거
```
2. 결측치 채우기
```py
df.fillna(0) # 일괄 0으로
df['score'].fillna(df['score'].mean()) # 평균으로
df.fillna(method='ffill') # 앞의 값으로 채우기
```
3. 결측치가 많은 컬럼 삭제
```py
df.dropna(axis=1, thresh=0.5 * len(df)) # 50% 이상 NaN이면 열 삭제
```

## 이상값(outlier) 또는 비정상 포맷 처리
1. 범위 조건 필터링
```py
df = df[(df['score'] >= 0) & (df['score'] <= 100)]
```
2. 숫자가 아닌 문자 제거
```py
df['income'] = df['income'].replace('[\$,]', '', regex=True)
df['income'] = pd.to_numeric(df['income'], errors='coerce')
```
3. 정규표현식 기반 추출
```py
df['number'] = df['mixed'].str.extract(r'(\d+)')  # 문자열 중 숫자만 추출
```

## 중복 및 유일성 오류 대응
1. 중복 제거
```py
df.drop_duplicates(subset=['id'], keep='first')
```
2. 유일성 검사
```py
if df['user_id'].nunique() < len(df):
    print("⚠ 중복된 ID 존재")
```

## KeyError / Column Not Found 대응
1. 컬럼 존재 여부 체크
```py
if 'name' in df.columns:
    df['name'] = df['name'].str.lower()
else:
    df['name'] = 'unknown'
```
2. .get() 사용 (dict처럼 접근)
```py
df.get('name', pd.Series(['unknown'] * len(df)))
```

## 파일 입출력 에러 대응
1. 파일 없을 때
```py
import os

if os.path.exists('data.csv'):
    df = pd.read_csv('data.csv')
else:
    print("파일이 존재하지 않음")
```
2. JSON 파싱 실패
```py
import json

try:
    json_data = json.loads(bad_json)
except json.JSONDecodeError:
    print("잘못된 JSON 형식")
```

## 인덱스 오류 대응
잘못된 인덱싱(iloc/loc)
```py
if 5 < len(df):
    row = df.iloc[5]
else:
    print("해당 행 없음")
```

## 비어있는 DataFrame 처리
```py
if df.empty:
    print("데이터 없음")
```

## Division by Zero, 연산 실패 대응
```py
import numpy as np

df['ratio'] = np.where(df['denominator'] == 0, np.nan,
                       df['numerator'] / df['denominator'])
```

## 전처리 전체 흐름에서 자주 쓰는 방어 코드 패턴
```py
# 종합 방어 처리 예시
def clean_income(col):
    if pd.api.types.is_string_dtype(col):
        col = col.str.replace(',', '', regex=False)
    return pd.to_numeric(col, errors='coerce')

df['income'] = clean_income(df['income_raw'])
df['income'] = df['income'].fillna(0)
```

---
## errors='coerce'
- 에러가 발생하는 값을 강제로 NaN(결측치)로 바꿔서 처리하게 만드는 옵션


### pd.to_numeric()
```py
import pandas as pd

s = pd.Series(['100', '200', 'abc', '300'])

pd.to_numeric(s, errors='coerce')
```

결과
```
0    100.0
1    200.0
2      NaN   ← 'abc'는 숫자가 아니므로 NaN 처리됨
3    300.0
dtype: float64
```
- 'abc'는 숫자로 변환할 수 없어서 NaN으로 강제 변환됨
- 이후 집계(mean(), sum() 등)에서도 안전하게 처리 가능

### errors='coerce'가 필요한 상황
상황 | 예시 | 대응 방식
-|-|-
문자열 숫자에 쉼표가 섞인 경우 | "1,000" | 변환 실패 -> errors='coerce'
문자열 중간에 알파벳이 섞인 경우 | "123abc" | NaN으로 처리하고 나중에 drop 또는 fill
수치형이어야 하는데 공간/Null이 있는 경우 | "", " " | NaN으로 처리

### 실무적 대응 방식 패턴
```py
df['price'] = pd.to_numeric(df['price_raw'], errors='coerce')
df = df.dropna(subset=['price'])  # 결측치 제거
```
or
```py
df['date'] = pd.to_datetime(df['date_raw'], errors='coerce')
df['date'].fillna(method='ffill', inplace=True)  # 이전 값으로 채움
```