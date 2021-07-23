---
title:  "[Data Science] Kaggle Titanic"
excerpt: "Kaggle Titanic"

categories:
  - Data Science
tags:
  - [Data Science, Python]

toc: true
toc_sticky: true
 
date: 2021-07-22
last_modified_at: 2021-07-22
---
## 데이터 사이언티스트란?
데이터에서 인사이트를 얻어서 유용한 스토리를 만드는 사람
시각화 -> 분석 -> 인사이트 -> 스토리

> EDA -> Feature Engineering -> Algorithm -> train 데이터 훈련 -> test 데이터 테스트

> 캐글 가입 -> 대회 내용 복사해서 내 계정으로 옮기기 -> 대회 참가 동의 -> 복사 완료 -> 구글 코랩 가입 -> 캐글의 대회 내용 다운로드 -> 코랩에 내용 업로드 -> 깃 허브 가입 -> 깃허브에 코랩 사본 저장 -> 깃 등록

```python
# 기본 데이터 정리 및 처리
import numpy as np
import pandas as pd

# 시각화
import matplotlib.pyplot as plt
%matplotlib inline
import seaborn as sns
plt.style.use('seaborn-whitegrid')
import missingno

# 전처리 및 머신 러닝 알고리즘
from sklearn.preprocessing import LabelEncoder, OneHotEncoder
from sklearn.preprocessing import StandardScaler
from sklearn.neighbors import KNeighborsClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from sklearn.svm import SVC
from xgboost import XGBClassifier
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.ensemble import ExtraTreesClassifier
from sklearn.ensemble import AdaBoostClassifier
from sklearn.gaussian_process import GaussianProcessClassifier
from sklearn.naive_bayes import GaussianNB
from sklearn.ensemble import BaggingClassifier
from sklearn.ensemble import VotingClassifier

# 모델 튜닝 및 평가
from sklearn.model_selection import cross_val_score
from sklearn.model_selection import GridSearchCV
from sklearn.model_selection import cross_val_predict
from sklearn import model_selection

# 경고 제거 (판다스가 에러 메세지를 자주 만들어 내기 때문에 이를 일단 무시하도록 설정합니다.)
import sys
import warnings

import warnings
warnings.filterwarnings('ignore')
```
Exploratory Data Analysis
- 데이터에 대한 초기 조사를 수행하는 중요한 프로세스
1. 훈련용 데이터를 분석하여 (EDA)
2. 머신러닝 모델을 만들어
3. 전체 데이터에 대한 Feature Engineering을 하고
4. 테스트 데이터에 대한 예측 결과를 내어 이에 대한 판정을 받음

- head() : 첫 5행을 보기
    - head(5) : 첫 5행
    - head(n=5) : 첫 5행
- tail() : 마지막 5행
- describe() : 각 열의 통계적인 면
    - 기본은 연속된 값을 가진 열만 보여주지만 'include=all'로 세팅하면 전체 볼수 있음
- dtypes : 모든 열의 데이터 종류
- info() : dtypes의 좀 더 발전된 개념으로 데이터 타입 뿐만 아니라 빈칸이 아닌 개수까지 보여줌
- columns : 데이터 프레임의 모든 열의 제목들
- shape : 행의 갯수와 열의 갯수

<br>

### Titanic Column 내용 파악
- passenger ID : 승객 연번
    - 승객들을 순서대로 번호를 준것
- Survived : 생존 여부
    - 0 = No, 1 = Yes
    - 0이면 사망 1이면 생존
    - Train파일에는 답이 주어져 있고 Test 파일은 빈 값
- Pclass : 선실 등급
    - 1,2,3등실
- Sex : 성별
- Age : 나이
    - 빈 값이 많아서 처리가 중요
- Sibsp : 형제 자매의 수/배우자 등이 승선한 경우 수
    - 같이 탄 형제의 수 또는 배우자 또는 배우자+형제의 수
- Parch : 부모나 자식과 같이 탄 경우 수
    - 부모+아이의 가족 탑승자 수
- Ticket : 표 번호
- Fare : 요금
- Cabin : 선실 번호
- embarked : 승선한 항구
    - C = Cherbourg, Q = Queenstown, S = Southampton



```python
# 병합 준비
ntrain = train.shape[0]
ntest = test.shape[0]

# 아래는 따로 잘 모셔 둡니다.
y_train = train['Survived'].values
passId = test['PassengerId']

# 병함 파일 만들기
data = pd.concat((train, test))

# 데이터 행과 열의 크기는
print("data size is: {}".format(data.shape))
```
shape[0]은 행의 길이를 알수 있음

```python
train['Survived'].value_counts()
```
> 0    549
    1    342
    Name: Survived, dtype: int64

342명은 살아남고 549명은 사망

matrix()는 형렬 형식으로 빈값 데이터를 시각화하는 명령

<br>

### Feature 항목
- 범주형 항목(Categorical Features):
    범주형 변수로 된 항목으로 범주형 변수는 둘 이상의 결과 요소가 있는 변수이며 해당 기능의 각 값을 범주별로 분류가능.
    discrete variable(이산형 변수) = categorical variable(범주형 변수)의 하나로 norminal variable(명목 변수)이라고도 함
    - Dataset에서 명목 항목 : Sex, Embark이며 Name, Ticket등을 이로 변환
- Ordinal Variable:
    순위 변수는 범주형의 하나지만 그 차이점은 값 사이의 상대 순서(=서열) 또는 정렬이 가능
    - Dataset에서 순위 항목 : PClass이며 Cabin을 이 범주로 변환해서 사용
- Continuous Features:
    서로 연속된 값을 가진 변수를 가진 항목이며 여기에서 연령을 대표적인 것으로 볼 수 있음
    - Dataset에서 연속 항목 : Age, SipSp, Parch, Fare는 interval variable로 만들어 적용


파일의 각 열의 상관관계
- Co-relation 매트릭스는 seaborn에서 변수 간 상관 계수를 보여주는 표. 표의 각 셀은 두 변수 간의 상관 관계를 보여줌. 상관 매트릭스는 고급 분석에 대한 입력 및 고급 분석에 대한 진단으로 데이터를 요약하는데 사용됨.
```python
# Co-relation 매트릭스
corr = data.corr()
# 마스크 셋업
mask = np.zeros_like(corr, dtype=np.bool)
mask[np.triu_indices_from(mask)] = True
# 그래프 셋업
plt.figure(figsize=(14, 8))
# 그래프 타이틀
plt.title('Overall Correlation of Titanic Features', fontsize=18)
#  Co-relation 매트릭스 런칭
sns.heatmap(corr, mask=mask, annot=False,cmap='RdYlGn', linewidths=0.2, annot_kws={'size':20})
plt.show()
```

#### Survived 분석
- Survived : Key(0 - Not Survived, 1- Survived)
- Survived는 숫자로 값을 주지만 Categorical Variable
- 죽던지 살던지 둘 중 하나의 값만 줌
```python
fig = plt.figure(figsize=(10,2))
sns.countplot(y='Survived', data=train)
print(train.Survived.value_counts())
```
<img src= ".. /images/da/kagglestart1.png">

```python
f,ax=plt.subplots(1, 2, figsize=(15, 6))
train['Survived'].value_counts().plot.pie(explode=[0, 0.1], autopct='%1.1f%%', ax=ax[0], shadow=True)
ax[0].set_title('Survived')
ax[0].set_ylabel('')
sns.countplot('Survived',data=train, ax=ax[1])
ax[1].set_title('Survived')
plt.show()
```

```python

```

```python

```

```python

```

```python

```

```python

```

