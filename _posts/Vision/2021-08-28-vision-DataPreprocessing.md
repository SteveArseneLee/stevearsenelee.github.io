---
title:  "[Vision] Data Preprocessing with Python"
excerpt: "Data Preprocessing"

categories:
  - Vision
tags:
  - [Vision, Machine Learning, python]

toc: true
toc_sticky: true
 
date: 2021-08-28
last_modified_at: 2021-08-28
---
# Data Preprocessing Tools
## Python

#### 라이브러리 호출
```python
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
```

### 데이터셋 삽입
```python
dataset = pd.read_csv('Data.csv')
X = dataset.iloc[:, :-1].values
y = dataset.iloc[:, -1].values
print(X)
print(y)
```
- pandas의 read_csv로 데이터를 읽어온다.

**Data.csv**를 보면 X축에 Country, Age, Salary, Purchased라는 특징이 있는데, 여기서 Purchased를 예측하는 것이므로 이를 제외한 나머지값만 저장한다. 이때는 ```[:, :-1]```로 마지막 줄 뺴고는 모두를 저장하면 된다.
y에는 Purchased의 값만 저장할 것이기 때문에 ```[:, -1]```로 저장한다.
- iloc이란 location of indexes이다.

### 결측치 처리
결측치의 처리 방법은 다음과 같다.
1. 무시(삭제)
2. 대체(중간값 등)
```python
from sklearn.impute import SimpleImputer
imputer = SimpleImputer(missing_values=np.nan, strategy='mean')
imputer.fit(X[:, 1:3])
X[:, 1:3] = imputer.transform(X[:, 1:3])
```
missing_values를 np.nan으로 설정하면 비어있는 모든 값을 선택하고 strategy를 평균값으로 지정한다.
fit 메소드로 X의 결측값들을 선택(연결)하고 transform으로 대체한다.

### 카테고리컬 데이터 인코딩
#### 독립 변수 인코딩하기
Country에서 보면 France, Spain, Germany로 구분되어 있다. 이들을 숫자로 변환해보겠다. 이때 **OneHotEncoder**를 적용해보겠다. France는 (1,0,0), Spain은 (0,0,1), Germany는 (0,1,0)으로 변환한다.

```python
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder
ct = ColumnTransformer(transformers=[('encoder', OneHotEncoder(), [0])], remainder='passthrough')
X = np.array(ct.fit_transform(X))
```

#### 종속 변수 인코딩하기
```python
from sklearn.preprocessing import LabelEncoder
le = LabelEncoder()
y = le.fit_transform(y)
```

### 데이터셋 분리(훈련, 학습)
> 데이터셋 분리를 한 다음에 feature scaling을 해야한다
X_train : matrix of featues of the training set
X_test : matrix of features of the test set
y_train : dependent variable of the training set
y_test : dependent variable of the test set
```python
from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.2, random_state = 1)
print(X_train)
print(X_test)
print(y_train)
print(y_test)
```

### Feature Scaling
```python
from sklearn.preprocessing import StandardScaler
sc = StandardScaler()
X_train[:, 3:] = sc.fit_transform(X_train[:, 3:])
X_test[:, 3:] = sc.transform(X_test[:, 3:])
print(X_train)
print(X_test)
```