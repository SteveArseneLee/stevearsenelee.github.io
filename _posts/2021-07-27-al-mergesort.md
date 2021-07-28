---
title:  "[Algorithm] Merge Sort"
excerpt: "병합정렬"

categories:
  - Algorithm
tags:
  - [Algorithm]

toc: true
toc_sticky: true
 
date: 2021-07-27
last_modified_at: 2021-07-27
---
## Merge Sort
- 재귀용법을 활용한 정렬 알고리즘
    1. 리스트를 절반으로 잘라 비슷한 크기의 두 부분 리스트로 나눔
    2. 각 부분 리스트를 재귀적으로 병합 정렬을 이용해 정렬
    3. 두 부분 리스트를 다시 하나의 정렬된 리스트로 합병

### 알고리즘 이해
- 데이터가 네 개 일때 (데이터 갯수에 따라 복잡도가 떨어지는 것은 아니므로, 네 개로 바로 로직을 이해)
    - ex) data_list = [1,9,3,2]
        - 먼저 [1,9], [3,2]로 나누고
        - 다시 앞 부분은 [1],[9]로 나누고
        - 다시 정렬해서 합친다. [1,9]
        - 다음 [3,2]는 [3],[2]로 나누고
        - 다시 정렬해서 합친다. [2,3]
        - 이제 [1,9]와 [2,3]을 합친다.
            - 1 < 2 이니 [1]
            - 9 > 2 이니 [1,2]
            - 9 > 3 이니 [1,2,3]
            - 9밖에 없으니 [1,2,3,9]


split 함수
```python
def split(list):
    left = list[:데이터 2등분]
    right = list[데이터 2등분:]
    return merge(left,right)
```
재귀 사용한 split 함수
```python
def split(list):
    if len(list) <= 1: return list
    left = list[:데이터 2등분]
    right = list[데이터 2등분:]
    return merge(split(left), split(right))
```
merge 함수
```python
def merge(left, right):
    # 왼쪽, 오른쪽 데이터를 하나씩 이동하면서
    if left[lp] < right[rp]:
        # 데이터가 작은 순으로 데이터 쌓기
        list.append(left[lp]) lp += 1
    else:
        list.append(right[rp]) rp += 1
    # 쌓은 데이터 리턴
    return list
```

### 알고리즘 구현
- mergesplit 함수 만들기
    - 만약 리스트 갯수가 한개이면 해당 값 리턴
    - 그렇지 않으면, 리스트를 앞뒤, 두 개로 나누기
    - left = mergesplit(앞)
    - right = mergesplit(뒤)
    - merge(left, right)
- merge 함수 만들기
    - 리스트 변수 하나 만들기(sorted)
    - left_index, right_index = 0
    - while left_index < len(left) or right_index < len(right):
        - 만약 left_index나 right_index가 이미 left 또는 right 리스트를 다 순회했다면, 그 반대쪽 데이터를 그대로 넣고, 해당 인덱스 1 증가
        - if left[left_index] < right[right_index]:
            - sorted.append(left[left_index])
            - left_index += 1
        - else:
            - sorted.append(right[right_index])
            - right_index = 1


#### 작은 부분부터 작성해서 하나씩 구현
```python
def split(data):
    medium = int(len(data / 2))
    left = data[:medium]
    right = data[medium:]
    print(left,right)

# 테스트
data_list = [3,4,1,3,2]
split(data_list)
```

merge함수는 없는 상태이며, mergesplit 함수 만들기
- 만약 리스트 갯수가 한개이면 해당 값 리턴
- 그렇지 않으면, 리스트를 앞뒤, 두 개로 나누기
- left = mergesplit(앞)
- right = mergesplit(뒤)
- merge(left, right)

```python
def mergesplit(data):
    if len(data) <= 1:
        return data
    medium = int(len(data) / 2)
    left = mergesplit(data[:medium])
    right = mergesplit(data[medium:])
    return merge(left,right)
```

#### merge함수
- 목표 : left와 right 의 리스트 데이터를 정렬해서 sorted_list 라는 이름으로 return 하기
- left와 right는 이미 정렬된 상태 또는 데이터가 하나임

1. left부터 하나씩 right와 비교
2. left > right 이면, left를 sorted_list에 넣고, 다음 left 리스트와 right 비교
    - 그렇지 않으면 반대로 하기

```python
def merge(left, right):
    meged = list()
    # 인덱스의 번호
    left_point, right_point = 0,0

    # case 1 : left/right가 아직 남아있을 때
    while len(left) > left_point and len(right) > right_point:
        if left[left_point] > right[right_point]:
            meged.append(right[right_point])
            right_point += 1
        else:
            meged.append(left[left_point])
            left_point += 1
    # case 2 : left 만 남아있을 때
    while len(left) > left_point:

    # case 3 : right 만 남아있을 때
    while len(right) > right_point:
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

```python
```

```python
```

