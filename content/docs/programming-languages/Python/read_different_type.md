+++
title = "여러 가지 형식의 파일 입출력"
draft = false
+++
### CSV
```python
# 목표: 꽃 종류(species)별 평균 petal 길이(petal_length)를 구하고, petal 길이가 5cm 이상인 데이터만 저장

import pandas as pd
# 1. 데이터 불러오기
df = pd.read_csv('iris.csv')

# 2. 평균 petal_length를 species 기준으로 계산
mean_petal = df.groupby("species")["petal_length"].mean()
print(mean_petal)

# 3. petal_length >= 5인 데이터만 필터링 후 저장
filtered = df[df["petal_length"] >= 5]
# filtered.to_csv("filtered_iris.csv", index=False)
```