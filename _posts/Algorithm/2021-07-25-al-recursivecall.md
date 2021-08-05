---
title:  "[Algorithm] Recursive Call"
excerpt: "Recursive Call"

categories:
  - Algorithm
tags:
  - [Algorithm]

toc: true
toc_sticky: true
 
date: 2021-07-25
last_modified_at: 2021-07-25
---
## Recursive Call
- 함수 안에서 동일한 함수를 호출하는 형태

### 예제
- 팩토리얼을 구하는 알고리즘을 Recursive Call을 활용해 알고리즘 작성

#### 분석
- 간단한 경우
    - 2! = 1 x 2
    - 3! = 1 x 2 x 3
    - 4! = 1 x 2 x 3 x 4
- 규칙 : n! = n x (n-1)!
    1. 함수를 하나 만들기
    2. 함수(n)은 n>1이면 return n x 함수(n-1)
    3. 함수(n)은 n=1이면 return n
- 검증 (코드로 검증하지 않고, 직접 간단한 경우부터 대입해서 검증)
    - 2!
        - 함수(2) 이면, 2>1이므로 2 x 함수(n)
        - 함수(1)은 1이므로, return 2 x 1 = 2
    - 3!
        - 함수(3) 이면, 3>1이므로 3 x 함수(2)
        - 함수(2)는 1번에 의해 2!이므로, return 2 x 1 = 2
        - 3 x 함수(2) = 3 x 2 = 3 x 2 x 1 = 6이 맞다
    - 4!
        - 함수(4)이면, 4>1이므로 4 x 함수(3)
        - 함수(3)은 2번에 의해 3 x 2 x 1 = 6
        - 4 x 함수(3) = 4 x 6 = 24가 맞다
```python
def factorial(num):
    if num > 1:
        return num * factorial(num - 1)
    else:
        return

# 검증
for num in range(10):
    print(factorial(num))
```

### 예제 - 시간 복잡도와 공간 복잡도
- factorial(n)은 n-1번의 factorial() 함수를 호출해서, 곱셈을 함
    - 일종의 n-1번 반복문을 호출한 것과 동일
    - factorial() 함수를 호출할때마다, 지역변수 n 생성됨
- 시간 복잡도/공간 복잡도는 O(n-1)이므로 결국 둘 다 O(n)


### 재귀 호출의 일반적인 형태
```python
# 일반적인 형태 1
def function(입력):
    if 입력 > 일정값: # 입력이 일정 값 이상이면
        return function(입력 - 1) # 입력보다 작은 값
    else:
        return 일정값 # 재귀 호출 종료
```

```python
# 일반적인 형태 2
def function(입력):
    if 입력 <= 일정값: # 입력이 일정 값보다 작으면
        return 일정값 # 재귀 호출 종료
    function(입력보다 작은 값)
    return 결과값
```


실제 코드
```python
def factorial(num):
    if num <= 1:
        return num
    return_value = num * factorial(num - 1)
    return return_value
```
<br>

---

## Problems
#### 재귀 함수를 활용해 1부터 num까지의 곱 출력
```python
# 반복문만 쓰는 함수
def multiple(num):
    return_value = 1
    for index in range(1, num + 1):
        return_value = return_value * index
    return return_value
```
```python
def multiple(num):
    if num <= 1:
        return num
    return num * multiple(num-1)
```

#### 숫자가 들어있는 리스트가 주어졌을 때, 리스트의 합을 리턴하는 함수
```python
def sum_list(data):
    if len(data) == 1:
        return data[0]
    return data[0] + sum_list(data[1:])

# 테스트
import random
data = random.sample(range(100), 10)
data
sum_list(data)
```

```python
def palindrome(string):
    if len(string) <= 1:
        return True
    if string[0] == string[-1]:
        return palindrome(string[1:-1])
    else:
        return False
```


#### 프로그래밍 연습
1. 정수 n에 대해
2. n이 홀수면 3 x n + 1을 하고,
3. n이 짝수면 n을 2로 나눔
4. 이렇게 계속 진행해서 n이 결국 1이 될때까지 2와 3과정 반복
```python
def func(n):
    print(n)
    if n == 1:
        return n
    if n % 2 != 0:
        return func(3*n+1)
    else:
        return func(int(n/2))

# 테스트
func(3)  
```

#### 정수 n이 입력으로 주어졌을 때, n을 1,2,3의 합으로 나타낼 수 있는 방법의 수를 구하시오
```python
def func(data):
    if data == 1:
        return 1
    elif data == 2:
        return 2
    elif data == 3:
        return 4
    return func(data - 1) + func(data - 2) + func(data - 3)

# 테스트
func(4)
func(5)
```

