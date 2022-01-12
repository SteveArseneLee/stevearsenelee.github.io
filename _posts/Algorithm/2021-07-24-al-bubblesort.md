---
title:  "[Algorithm] Sorting Algorithm(Bubble Sort)"
excerpt: "정렬 알고리즘 개요 & Bubble Sort"

categories:
  - Algorithm
tags:
  - [Algorithm]

toc: true
toc_sticky: true
 
date: 2021-07-20
last_modified_at: 2021-07-23
---

## 정렬 (Sorting)
- sorting : 어떤 데이터들이 주어졌을 때 이를 정해진 순서대로 나열하는 것
- 정렬은 프로그램 작성시 빈번하게 필요로 함
- 다양한 알고리즘이 고안되었으며, 알고리즘 학습의 필수

### Bubble Sort
- 두 인접한 데이터를 비교해서, 앞에 있는 데이터가 뒤에 있는 데이터보다 크면, 자리를 바꾸는 정렬 알고리즘

데이터 길이가 2일때, 생각을 해보자. 조건체크는 1번만 하면되고, 턴도 1번뿐이다.
데이터 길이가 3일때는 어떨까? 먼저 0과1을 비교해보고 1과 2를 비교해본다. 즉 조건체크는 2번한다. 그리고나서 또다시 0과1, 1과2를 비교한다. 즉 턴은 2회다.
데이터 길이가 4일때는? 0과1, 1과2, 2와3을 체크해서 조건체크는 3번, 턴 역시 3번이 된다.
```python
# Turn
for index in range(데이터길이 -1):
    # 조건 처리횟수
    for index2 in range(데이터길이-1):
        if 앞데이터 > 뒤데이터:
            swap(앞데이터, 뒤데이터)

## 하지만 이때 조건체크가 나중에 갈수록 줄어드니 좀더 최적화해서
# Turn
for index in range(데이터길이 - 1):
    # 조건 처리횟수
    for index2 in range(데이터길이 - index - 1):
        if 앞데이터 > 뒤데이터:
            swap(앞데이터, 뒤데이터)
```

### 알고리즘 구현
- 특이점 찾아보기
    - n개의 리스트가 있는 경우 최대 n-1번의 로직을 적용
    - 로직을 1번 적용할 때마다 가장 큰 숫자가 뒤에서부터 1개씩 결정됨.
    - 로직이 경우에 따라 일찍 끝날 수도 있다. 따라서 로직을 적용할 때 한 번도 데이터가 교환된 적이 없다면 이미 정렬된 상태이므로 더 이상 로직을 반복 적용할 필요가 없다.
1. for num in range(len(data_list)) 반복
2. swap = 0 (교환이 되었는지를 확인하는 변수를 두자)
3. 반복문 안에서 for index in range(len(data_list) - num - 1) 번 반복해야 하므로
4. 반복문 안의 반복문 안에서, if data_list[index] > data_list[index + 1]이면
5. data_list[index], data_list[index + 1] = data_list[index + 1], data_list[index]
6. swap += 1
7. 반복문 안에서, if swap == 0 이면, break 끝
```python
for index in range(데이터길이 - 1):
    for index2 in range(데이터길이 - index - 1):
        if data[index2] > data[index2 + 1]:
            data[index2], data[index2 + 1] = data[index2 + 1], data[index]
```

### Bubble Sort
```python
def bubblesort(data):
    for index in range(len(data) - 1):
        swap = False
        for index2 in range(len(data) - index - 1):
            if data[index2] > data[index2 + 1]:
                data[index2], data[index2 + 1] = data[index2 + 1], data[index2]
                swap = True
        
        if swap == False:
            break
    return data
```

```python
import random

# 테스트용도로 50번 루프
# for index in range(50):
#     data_list = random.sample(range(100), 50)

data_list = random.sample(range(100), 50)
bubblesort(data_list)
```
#### 알고리즘 분석
- 반복문이 두개 O(n^2)
    - 최악의 경우 n*(n-1) / 2
- 완전 정렬이 되어 있는 상태라면 최선은 O(n)