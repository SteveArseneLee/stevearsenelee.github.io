+++
title = '데이터 파일 읽기 + 구조화 시나리오'
draft = false
+++
## CSV / Excel / Parquet -> Pandas
### 파일 불러오기
```python
# csv
import pandas as pd

# 기본
df = pd.read_csv("data.csv")

# 컬럼명 지정 / 인덱스 지정 / 데이터 타입 강제
df = pd.read_csv("data.csv", names=["a", "b"], header=None, index_col=0, dtype={"b": int})

# 인코딩 문제 대응
df = pd.read_csv("data.csv", encoding="utf-8")  # or "cp949", "ISO-8859-1"

# ====================
# Excel
df = pd.read_excel("data.xlsx", sheet_name=0)  # 여러 시트가 있을 경우 인덱스로 지정

# ====================
# Parquet
df = pd.read_parquet("data.parquet", engine="pyarrow")
```

### 자주 나오는 옵션들
옵션 | 설명
-|-
index_col = 0 | 첫 번째 컬럼을 인덱스로 사용
usecols = ['A', 'B'] | 특정 컬럼만 불러오기
dtype = {'A' : str} | 컬럼 타입 강제
na_values =['-'] | 특정 문자열을 NaN으로 처리
parse_dates = ['date_col'] | 날짜 컬럼 자동 변환
encoding = 'utf-8-sig' | 엑셀에서 저장한 csv가 깨질 때

### 여러 파일 불러와 concat
```python
dfs = []
for year in [2022, 2023]:
    df = pd.read_csv(f"sales_{year}.csv")
    df["year"] = year
    dfs.append(df)

df_all = pd.concat(dfs, ignore_index=True)
```

### 특정 시트만 읽기 + 병합
```py
sheets = pd.read_excel("multi_sheet.xlsx", sheet_name=None)  # dict로 반환
df_all = pd.concat(sheets.values(), ignore_index=True)
```

## 연습문제
### 1. CSV 파일 병합 및 전처리
{{% hint warning %}}
sales_2022.csv 와 sales_2023.csv가 있음
- 두 파일을 읽고 병합 (연도 구분용 year 컬럼 추가)
- amount 컬럼은 정수형으로 변환하되, 변환 불가능한 값은 NaN
- amount 컬럼의 평균값을 출력하라 (NaN은 무시)
{{% /hint %}}
```py
dfs = []
for year in [2022, 2023]:
    df = pd.read_csv(f"sales_{year}.csv")
    df["year"] = year
    # , 포함 숫자 처리 → replace
    df["amount"] = (
        df["amount"].astype(str)
        .str.replace(",", "", regex=False)
        .str.strip()
    )
    df["amount"] = pd.to_numeric(df["amount"], errors="coerce")  # 변환 실패 → NaN
    dfs.append(df)

df_all = pd.concat(dfs, ignore_index=True)

print("평균 금액:", df_all["amount"].mean())
```
- .replace(",", "") : "2,000" 같은 숫자를 파싱하려면 콤마 제거 필요
- .to_numeric(errors='coerce') : 변환 실패(invalid, -)를 NaN으로 처리
- .concat([...], ignore_index=True) : 인덱스를 다시 붙여 하나의 데이터프레임으로 병합
- .mean() : NaN은 자동 무시됨(skipna=True 기본)

### 2. Excel + Parquet 통합
{{% hint warning %}}
- employees.xlsx는 Sheet1에 직원 정보(emp_id, name, dept)가 들어있음
- salaries.parquet는 emp_id, salary, bonus 컬럼이 있음
- 둘을 병합해 df_merged를 만들고, 다음 컬럼 추가
    1. total_comp = salary + bonus
    2. bonus_ratio = bonus / total_comp
- 단, bonus가 없는 직원은 0으로 간주
{{% /hint %}}

```py
df_emp = pd.read_excel("employees.xlsx", sheet_name="Sheet1")
df_sal = pd.read_parquet("salaries.parquet")

# 결측치 보완
df_sal["bonus"] = df_sal["bonus"].fillna(0)

df_merged = pd.merge(df_emp, df_sal, on="emp_id", how="left")
df_merged["total_comp"] = df_merged["salary"] + df_merged["bonus"]
df_merged["bonus_ratio"] = df_merged["bonus"] / df_merged["total_comp"]
```
- pd.merge(..., how='left') : 직원 전체 유지하며 급여 정보 붙이기
- .fillna(0) : 보너스 없는 직원 처리
- 파생 컬럼 : 일반 산술 연산으로 쉽게 가능 (+, /)

