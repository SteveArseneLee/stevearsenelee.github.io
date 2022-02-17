---
title:  "[이코테] Greedy Algorithm"
excerpt: "그리디 알고리즘"

categories:
  - 이코테
tags:
  - [이코테, python]

toc: true
toc_sticky: true
 
date: 2022-02-17
last_modified_at: 2022-02-17
---
[그리디 알고리즘](https://github.com/SteveArseneLee/Algorithm-Summary/tree/main/Greedy)
# 그리디 알고리즘(탐욕법)
- 현재 상황에서 지금 당장 좋은 것만 고르는 방법


### 예제) 거스름돈
500원, 100원, 50원, 10원짜리 동전이 무한히 존재한다고 가정.  
손님에게 거슬러 줘야 할 돈이 N원일 때 거슬러줘야 할 동전의 최소 개수?  
단, N은 항상 10의 배수
ex) 1260원 거슬러 줘야함
```python
n = 1260
count = 0

# 큰 단위 화폐부터 차례대로 확인
coin_types = [500, 100, 50, 10]

for coin in coin_types:
  count += n // coin # 해당 화폐로 거슬러 줄 수 있는 동전의 개수 세기
  n %= coin

print(coin)
```


### 실전 문제) 큰 수의 법칙
다양한 수로 이루어진 배열이 있을 때 주어진 수들을 M번 더해 가장 큰 수를 만드는 법칙  
단, 