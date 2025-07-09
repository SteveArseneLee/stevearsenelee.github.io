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