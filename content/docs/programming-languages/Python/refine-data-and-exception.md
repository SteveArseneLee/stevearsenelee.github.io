+++
title = "데이터 정제 & 예외 상황 처리"
draft = false
weight = 10
+++
## 개념
### 결측치 처리
확인
```py
df.isnull().sum()   # 컬럼별 결측 개수
df["col"].isnull()  # True/False Series
```
처리
```py
df.fillna(0)  # 대체
df.dropna()   # 제거
df.interpolate()  # 선형 보간 (연속값에만 적절)
```
상황 | 추천 메서드
-|-
숫자 → 평균/중앙값 대체 | df["col"].fillna(df["col"].mean())
범주형 → 최빈값 대체 | fillna(df["col"].mode()[0])
분석 제외 | dropna()


---
## 연습문제
### 1. 결측치 처리
employees.csv
```
id,name,dept,salary,join_date
1,Alice,HR,50000,2020-01-10
2,Bob,Sales,,2021-06-05
3,Charlie,NaN,70000,not_a_date
4,David,HR,invalid,2022-03-15
```

{{% hint warning %}}
다음 조건을 만족하는 df 생성
1. salary를 숫자로 변환하고 오류는 NaN처리
2. join_date는 날짜로 변환하되 오류는 NaT 처리
3. 결측이 있는 행은 제거하고 남은 행 수를 출력
{{% /hint %}}
```py
df = pd.read_csv("employees.csv")

df["salary"] = pd.to_numeric(df["salary"], errors="coerce")
df["join_date"] = pd.to_datetime(df["join_date"], errors="coerce")

df_clean = df.dropna()
print("남은 행 수:", len(df_clean))
```
- .dropna() : NaN이나 NaT 포함 행 제거
- errors='coerce' : 파싱 실패 -> NaN/NaT 처리

### 2. 이상치 제거
temps.csv
```
city,temp
Seoul,29
Seoul,30
Seoul,32
Seoul,80
Seoul,-10
Seoul,31
```
{{% hint warning %}}
다음 조건을 만족하는 df_filtered 구하라.
1. temp 컬럼에서 이상치 제거(IQR 기준)
2. 제거 전/후 행 수 비교 출력
{{% /hint %}}

```py
df = pd.read_csv("temps.csv")
q1 = df["temp"].quantile(0.25)
q3 = df["temp"].quantile(0.75)
iqr = q3 - q1

lower = q1 - 1.5 * iqr
upper = q3 + 1.5 * iqr

df_filtered = df[df["temp"].between(lower, upper)]

print("제거 전:", len(df), "제거 후:", len(df_filtered))
```
- IQR 방식 : IQR = Q3 - Q1, 범위 밖 값은 이상치로 간주
- .between(a, b) : a <= x <= b 필터링

### 3. 문자열 처리 오류 대응
users.csv
```
id,email
1,alice@example.com
2,bob[at]example.com
3,charlie@example.com
```
{{% hint warning %}}
다음 조건을 만족하는 df 생성
1. email에서 @가 없는 행은 제거
2. email에서 도메인(example.com)만 추출해 domain 컬럼 생성
{{% /hint %}}

```py
df = pd.read_csv("users.csv")

# @ 포함한 것만 남김
df = df[df["email"].str.contains("@", na=False)]

# 도메인 추출
df["domain"] = df["email"].str.extract(r'@(.+)$')
```
- contains("@") : 유효 이메일 여부 필터
- .str.extract(r'@(.+)$') : 정규식으로 @ 뒤만 추출

### 4. try-except + assert 활용
{{% hint warning %}}
salary 컬럼이 반드시 존재하고, 100보다 작은 값이 없도록 체크.  
오류 발생 시 메시지를 출력하고 프로그램이 종료되지 않게 하라.
{{% /hint %}}
```py
try:
    # (1) salary 컬럼이 없으면 KeyError
    # (2) salary 중 100 미만이 있으면 AssertionError 발생
    ...
except KeyError:
    print("❌ salary 컬럼이 존재하지 않습니다.")
except AssertionError:
    print("❌ salary 값 중 100 미만이 존재합니다.")
```

정답
```py
try:
    assert "salary" in df.columns
    assert (df["salary"] >= 100).all()
except KeyError:
    print("❌ salary 컬럼이 존재하지 않습니다.")
except AssertionError:
    print("❌ salary 값 중 100 미만이 존재합니다.")
```
- assert 조건 : 조건 만족하지 않으면 AssertionError
- try-except : 예외 상황에서도 코드 계속 실행 가능

