---
title:  "[Algorithm] Selection Sort"
excerpt: "선택 정렬"

categories:
  - Algorithm
tags:
  - [Algorithm]

toc: true
toc_sticky: true
 
date: 2021-07-24
last_modified_at: 2021-07-24
---
## Selection Sort
- 다음과 같은 순서를 반복해 정렬하는 알고리즘
    1. 주어진 데이터 중, 최소값을 찾음
    2. 해당 최소값을 데이터 맨 앞에 위치한 값과 교체
    3. 맨 앞의 위치를 뺀 나머지 데이터를 동일한 방법으로 반복

### 데이터가 두개 일때
data_list = [9,1]
data_list[0] > data_list[1] 이므로 data_list[0]값과 data_list[1]값을 교환

### 데이터가 세개 일때
data_list = [9,1,7]
- 처음 실행하면 1, 9, 7이 됨
- 두번째 실행히면 1, 7, 9가 됨

### 데이터가 네개 일때
data_list = [9,3,2,1]
- 처음 실행하면 1,3,2,9가 됨
- 두번째 실행하면 1,2,3,9가 됨
- 세번째 실행하면 변화없음


#### 데이터가 네개 일때의 흐름
비교 데이터 인덱스가 0이면 비교는 1~3의 인덱스까지 비교.
그 다음 비교 데이터 인덱스를 1로 옮기면 2~3의 인덱스까지 비교.
그 다음 넘어가서 비교 인덱스를 2로 옮기면 3~3의 인덱스까지 비교.
마지막은 딱히 비교할 게 없어서 끝.

알고리즘 구현
1. for stand in range(len(data_list) - 1)로 반복
2. lowest=stand로 놓고,
3. for num in range(stand, len(data_list))를 stand 이후부터 반복
    - 내부 반복문 안에서 data_list[lowest] > data_list[num]이면,
        - lowest = num
4. data_list[num], data_list[lowest] = data_list[lowest], data_list[num]
```python
def selection_sort(data):
    # 비교 데이터 인덱스 = 기준점
    for stand in range(len(data) - 1):
        lowest = stand
        # 비교 인덱스
        for index in range(stand + 1, len(data)):
            if data[lowest] > data[index]:
                lowest = index
        data[lowest],data[stand] = data[stand],data[lowest]
    return data
### 테스트
import random
data_list = random.sample(range(100),10)
selection_sort(data_list)
```