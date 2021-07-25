---
title:  "[Algorithm] Insertion Sort"
excerpt: "삽입 정렬"

categories:
  - Algorithm
tags:
  - [Algorithm]

toc: true
toc_sticky: true
 
date: 2021-07-25
last_modified_at: 2021-07-25
---
## Insertion Sort
- 삽입 정렬은 두 번째 인덱스부터 시작
- 해당 인덱스(key 값) 앞에 있는 데이터(B)부터 비교해서 key값이 더 작으면, B값을 뒤 인덱스로 복사
- 이를 key 값이 더 큰 데이터를 만날때까지 반복, 그리고 큰 데이터를 만난 위치 바로 뒤에 key 값을 이동


```python
for index in range(데이터길이 - 1):
    # for index2 in range(데이터길이 - index - 1):
    for index2 in range(index+1, 0, -1):
        if data[index2] < data[index2 - 1]:
        # if 기준데이터 > 뒤데이터:
            swap(data[index2], data[index2-1])
        else:
            
```

```python
```

```python
```