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


### 거스름돈
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


### 큰 수의 법칙
다양한 수로 이루어진 배열이 있을 때 주어진 수들을 M번 더해 가장 큰 수를 만드는 법칙  
단, 배열의 특정한 인덱스에 해당하는 수가 연속해서 K번을 초과해 더해질 수 없음.  
ex) 순서대로 2,4,5,4,6으로 이루어진 배열이 있을 때 M이 8이고, K가 3이라 가정
이 경우 특정한 인덱스의 수가 연속해서 세번까지만 더해질 수 있으므로 큰 수의 법칙에 따른 결과는  
6 + 6 + 6 + 5 + 6 + 6 + 6 + 5 인 46  
하지만 서로 다른 인덱스에 있을 경우 같은 수면 서로 다른 것으로 간주함.  
따라서, 3,4,3,4,3이 주어지고 M이 7, K가 2이면  
4 + 4 + 4 + 4 + 4 + 4 + 4인 28이 도출됨.  
```python
N,M,K = map(int, input().rstrip().split())
lst = list(map(int, input().split()))
lst.sort()
first = lst[-1]
second = lst[-2]
result = 0
while True:
    for i in range(K):
        if M == 0:
            break
        result += first
        M -= 1
    if M == 0:
        break
    result += second
    M -= 1
print(result)
```
하지만, M의 크기가 100억 이상처럼 커진다면 시간 초과 판정을 받는다.  
따라서 이를 반복되는 수열을 잘 생각해보면 M을 (K+1)로 나눈 몫이 수열이 반복되는 횟수가 된다.  
| int(M / (K+1)) * K + M % (K+1)  
가장 큰 수가 더해지는 횟수를 구한 다음, 이를 이용해 두 번째로 큰 수가 더해지는 횟수까지 구한다.
```python
N,M,K = map(int, input().rstrip().split())
lst = list(map(int, input().split()))
lst.sort()
first = lst[-1]
second = lst[-2]

count = int(M / (K+1)) * K
count += M % (K+1)

result = 0
result += (count)*first # 가장 큰 수 더하기
result += (M-count) * second # 두 번째로 큰 수 더하기
print(result)
```


### 숫자 카드 게임