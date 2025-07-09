+++
title = "데이터 구조 변형 & 통계 집계 시나리오"
draft = false
weight = 10
+++
## 기본 개념 정리
### groupby() : 그룹별 집계 핵심
```py
df.groupby("col")["target"].sum()
df.groupby(["col1", "col2"]).agg({"val": "mean", "cnt": "sum"})
```
- 1개의 그룹키 또는 다중 그룹키 사용 가능
- .agg()를 쓰면 여러 통계 가능

e.g.
```py
df.groupby("region")["sales"].mean()
df.groupby(["region", "category"]).agg({"sales": "sum", "qty": "mean"})
```

### pivot_table()
```py
pd.pivot_table(df, index="row", columns="col", values="val", aggfunc="sum")
```
- 행/열 기준 집계된 통계 테이블을 생성
- fill_value=0 추가하면 NaN 대신 0으로 채움

e.g.
```py
pd.pivot_table(df, index="region", columns="product", values="sales", aggfunc="sum", fill_value=0)
```

### melt() : wide -> long(열을 행으로)
```py
df.melt(id_vars=["id"], value_vars=["Q1", "Q2", "Q3"])
```
- 데이터 컬럼들을 행 형태로 변환
- id_vars: 고정할 컬럼
- value_vars : 펼칠 컬럼

### merge() : SQL의 JOIN처럼 병합
```py
pd.merge(df1, df2, on="key", how="left")
```
- how : inner, left, right, outer
- on : 병합 기준 컬럼

### resample() : 시계열 데이터 집계
```py
df.set_index("date").resample("M").sum()
```
- 월별(M), 일별(D), 주별(W) 등으로 집계
- 반드시 datetime 컬럼을 index로 설정해야 함

### value_counts() / crosstab()
```py
df["col"].value_counts()
pd.crosstab(df["gender"], df["purchased"])
```
- 범주형 데이터의 빈도 분석
---
## 연습문제
### 1. groupby().agg() 다중 통계 집계
orders.csv
```
order_id,customer,amount
1001,Alice,120
1002,Bob,80
1003,Alice,150
1004,Bob,70
1005,Charlie,200
```
{{% hint warning %}}
1. 고객별 amount의 합계(sum)와 평균(mean)을 동시에 계산
2. 결과의 인덱스는 초기화되어 있어야함
{{% /hint %}}

```py
df = pd.read_csv("orders.csv")
result = df.groupby("customer").agg({"amount": ["sum", "mean"]}).reset_index()
```
- agg()에 dict 형식으로 여러 통계 가능
- 결과는 멀티 컬럼 -> ```.columns = ['customer', 'amount_sum', 'amount_mean']```로 rename 가능

### 2. pivot_table()을 이용한 행/열 통계
sales.csv
```
region,product,sales
North,A,100
North,B,200
South,A,150
South,B,250
```
{{% hint warning %}}
지역(region)별 제품(product)의 총 판매량 sales을 피벗 테이블로 만들기
{{% /hint %}}

```py
df = pd.read_csv("sales.csv")

pivot = pd.pivot_table(df, index="region", columns="product", values="sales", aggfunc="sum", fill_value=0)
```
- index : 행 기준
- columns : 열 기준
- values : 집계 대상
- aggfunc : 집계 함수
- fill_value : NaN 대신 채울 값

### 3. melt()로 열을 행으로 변환
sales_by_quarter.csv
```
store,Q1,Q2,Q3
S1,100,120,130
S2,80,90,95
```
{{% hint warning %}}
- store를 고정
- Q1, Q2, Q3는 quarter, sales로 변환
{{% /hint %}}

```py
df = pd.read_csv("sales_by_quarter.csv")
df_melted = df.melt(id_vars="store", var_name="quarter", value_name="sales")
```
- wide -> long 변환
- var_name : 열 이름 지정
- value_name : 값 이름 지정

### 4. merge()를 이용한 병합
customers.csv
```
customer_id,name
1,Alice
2,Bob
3,Charlie
```
orders.csv
```
order_id,customer_id,amount
1001,1,120
1002,2,80
1003,1,150
1004,4,300
```

{{% hint warning %}}
두 파일을 병합해 customer_id가 일치하지 않는 주문도 포함시키고(orders 중심), 주문자 이름(name)이 없을 경우 "Unknown"으로 처리
{{% /hint %}}
```py
df_cust = pd.read_csv("customers.csv")
df_ord = pd.read_csv("orders.csv")

df_merged = pd.merge(df_ord, df_cust, on="customer_id", how="left")
df_merged["name"] = df_merged["name"].fillna("Unknown")
```
- how='left' : 주문을 기준으로 고객 붙이기
- 결측 이름은 fillna()로 "Unknown" 처리

### 5. 시계열 리샘플링
logins.csv
```
user_id,login_time
1,2024-01-01 10:00
2,2024-01-01 11:30
1,2024-01-02 08:00
3,2024-01-05 09:00
```
{{% hint warning %}}
로그인 데이터를 날짜별(일 단위)로 집계하고, 로그인 수를 구하라
{{% /hint %}}

```py
df = pd.read_csv("logins.csv")
df["login_time"] = pd.to_datetime(df["login_time"])

df_daily = df.set_index("login_time").resample("D").count()
```
or
```py
df["date"] = df["login_time"].dt.date
df_daily = df.groupby("date")["user_id"].count()
```