---
title:  "[Vision] Data Preprocessing with R"
excerpt: "Data Preprocessing"

categories:
  - Vision
tags:
  - [Vision, Machine Learning, R]

toc: true
toc_sticky: true
 
date: 2021-08-30
last_modified_at: 2021-08-30
---
## Simple Linear Regression
> y = b0 + b1 * x1
- y : Dependent Variable(DV)
- x1 : Independent Variable(IV)
- b0 : Constant
- b1 : Coefficient


# Importing the libraries
```python
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
```

# Importing the dataset
```python
dataset = pd.read_csv('Salary_Data.csv')
X = dataset.iloc[:, :-1].values
y = dataset.iloc[:, -1].values
```

# Splitting the dataset into the Training set and Test set
```python
from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 1/3, random_state = 0)
```

# Training the Simple Linear Regression model on the Training set
```python
from sklearn.linear_model import LinearRegression
regressor = LinearRegression()
regressor.fit(X_train, y_train)
```

# Predicting the Test set results
```python
y_pred = regressor.predict(X_test)
```

# Visualising the Training set results
```python
plt.scatter(X_train, y_train, color = 'red')
plt.plot(X_train, regressor.predict(X_train), color = 'blue')
plt.title('Salary vs Experience (Training set)')
plt.xlabel('Years of Experience')
plt.ylabel('Salary')
plt.show()
```

# Visualising the Test set results
```python
plt.scatter(X_test, y_test, color = 'red')
plt.plot(X_train, regressor.predict(X_train), color = 'blue')
plt.title('Salary vs Experience (Test set)')
plt.xlabel('Years of Experience')
plt.ylabel('Salary')
plt.show()
```