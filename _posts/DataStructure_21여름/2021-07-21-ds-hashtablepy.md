<!-- ---
title:  "[Data Structure] Hash Table"
excerpt: "Hash Table with python"

categories:
  - Data Structure
tags:
  - [Data Structure, Python]

toc: true
toc_sticky: true
 
date: 2021-07-21
last_modified_at: 2021-07-21
---
 ## 해쉬 구조
 - Hash Table : Key에 Value를 저장하는 데이터 구조
    - Key를 통해 데이터를 받아올 수 있으므로, 속도가 획기적으로 빨라짐
    - Dictionary 타입이 해쉬 테이블의 예
    - 보통 배열로 미리 Hash Table 사이즈만큼 생성 후에 사용(공간과 탐색 시간을 맞바꾸는 기법)
    - 단 파이썬에서는 해쉬를 별도 구현할 이유가 없음 - 딕셔너리 이용

### 해쉬관련 알아둘 용어
- 해쉬 : 임의 값을 고정 길이로 변환하는 것
- 해쉬 테이블 : 키 값의 연산에 의해 직접 접근이 가능한 데이터 구조
- 해싱 함수 : Key에 대해 산술 연산을 이용해 데이터 위치를 찾을 수 있는 함수
- 슬롯 : 한 개의 데이터를 저장할 수 있는 공간
- 저장할 데이터에 대해 Key를 추출할 수 있는 별도 함수도 존재가능
```python
hash_table = list([0 for i in range(10)])

def hash_func(key):
    return key%5

# 데이터 저장
data1 = 'Andy'
data2 = 'Dave'
data3 = 'Trump'
## ord() : 문자의 ASCII코드 리턴
print(ord(data1[0]), ord(data2[0]), ord(data3[0]))
print(ord(data1[0]), hash_func(ord(data[0])))
```
해쉬 테이블에 값 저장
```python
def storage_data(data, value):
    key = ord(data[0])
    hash_address = hash_func(key)
    hash_table[hash_address] = value

storage_data('Andy', '01012345678')
storage_data('Dave', '01022225678')
storage_data('Trump', '01033335678')
```
실제 데이터 저장 및 읽기
```python
def get_data(data):
    key = ord(data[0])
    hash_address = hash_func(key)
    return hash_table[hash_address]

get_data('Andy')
```

### 자료구조 해쉬 테이블의 장단점과 주요 용도
- 장점
    - 데이터 저장/읽기 속도가 빠름(검색 속도가 빠름)
    - 해쉬는 키에 대한 데이터가 있는지(중복) 확인이 쉬움
- 단점
    - 일반적으로 저장공간이 더 많이 필요
    - 여러 키에 해당하는 주소가 동일할 경우 충돌을 해결하기 위해 별도 자료구조 필요
- 주요 용도
    - 검색이 많이 필요한 경우
    - 저장, 삭제, 읽기가 빈번한 경우
    - 캐쉬 구현

리스트 변수를 활용해 해쉬 테이블 구현
```python
hash("Dave")
hash_table = list([0 for i in range(8)])
def get_key(data):
    return hash(data)

def hash_function(key):
    return key % 8

def save_data(data, value):
    hash_address = hash_function(get_key(data))
    hash_table[hash_address] = value

def read_data(data):
    hash_address = hash_function(get_key(data))
    return hash_table[hash_address]

save_data('Dave', '01023212141')
save_data('Andy', '01023111234')
read_data('Dave')
```

## Collision 해결 알고리즘
- 해쉬 테이블의 가장 큰 문제는 충돌의 경우

### Chaining 기법
- Open Hashing 기법 중 하나: 해쉬 테이블 저장곤간 외의 공간을 활용하는 기법
- 충돌이 일어나면, 링크드 리스트라는 자료 구조를 사용해 링크드 리스트로 데이터를 추가로 뒤에 연결시켜서 저장하는 기법

해쉬 테이블 코드에 Chaining 기법으로 충돌해결 코드 추가
```python
hash_table = list([0 for i in range(8)])
def get_key(data):
    return hash(data)

def hash_function(key):
    return key % 8

def save_data(data, value):
    index_key = get_key(data)
    hash_address = hash_function(index_key)
    if hash_table[hash_address] != 0:
        for index in range(len(hash_table[hash_address])):
            if hash_table[hash_address][index][0] == index_key:
                hash_table[hash_address][index][1] = value
                return
        hash_table[hash_address].append([index_key, value])
    else:
        hash_table[hash_address] = [[index_key, value]]

    # hash_table[hash_address] = value

def read_data(data):
    index_key = get_key(data)
    hash_address = hash_function(index_key)
    if hash_table[hash_address] != 0:
        for index in range(len(hash_table[hash_address])):
            if hash_table[hash_address][index][0] == index_key:
                return hash_table[hash_address][index][1]
        return None
    else:
        return None
    # return hash_table[hash_address]

save_data('Dave', '12123115')
save_data('David', '2312941')
read_data('Dave')

print(hash('Dave')%8)
print(hash('David')%8)
```

### Linear Probing 기법
- Close Hashing 기법 중 하나: 해쉬 테이블 저장공간 안에서 충돌 문제를 해결하는 기법
- 충돌이 일어나면, 해당 hash address의 다음 address부터 맨 처음 나오는 빈공간에 저장하는 기법
    - 저장공간 활용도를 높이기 위한 기법

해쉬 테이블 코드에 Linear Probing
1. 해쉬 함수 : key % 8
2. 해쉬 키 생성 : hash(data)
```python
hash_table = list([0 for i in range(8)])
def get_key(data):
    return hash(data)

def hash_function(key):
    return key % 8

def save_data(data,value):
    index_key = get_key(data)
    hash_address = hash_function(index_key)
    if hash_table[hash_address] != 0:
        for index in range(hash_address, len(hash_table)):
            if hash_table[index] == 0:
                hash_table[index] = [index_key,value]
                return
            elif hash_table[index][0] == index_key:
                hash_table[index][1] = value
                return
    else:
        hash_table[hash_address] = [index_key,value]

def read_data(data):
    index_key = get_key(data)
    hash_address = hash_function(index_key)

    if hash_table[hash_address] != 0:
        for index in range(hash_address, len(hash_table)):
            if hash_table[index] == 0:
                return None
            elif hash_table[index][0] == index_key:
                return hash_table[index][1]

print(hash('dk') % 8)
print(hash('da') % 8)
print(hash('dc') % 8)
# 위 해쉬값이 동일하면
save_data('dk','123422518234')
save_data('da','123199992932')
read_data('da')
read_data('dc')
```

### 빈번한 충돌을 개선하는 기법
- 해쉬 함수를 재정의 및 해쉬 테이브 저장공간을 확대
- ex)
    ```python
    hash_table = list([None for i in range(16)])

    def hash_function(key):
        return key % 16
    ```
### 참고 : 해쉬 함수와 키 생성 함수
- 파이썬의 hash() 함수는 실행할 때마다 값이 달라질 수 있음
- 유명한 해쉬 함수 : SHA(Secure Hash Algorithm, 안전한 해쉬 알고리즘)
    - 어떤 데이터도 유일한 고정된 크기의 고정값을 리턴해주므로, 해쉬 함수로 유용하게 활용 가능
SHA-1
```python
import hashlib

data = 'test'.encode()
hash_object = hashlib.sha1()
# hash_object.update(data)
hash_object.update(b'test')
hex_dig = hash_object.hexdigest() # 16진수로 추출
print(hex_dig)
```
SHA-256
```python
import hashlib

data = 'test'.encode()
hash_object = hashlib.sha256()
# hash_object.update(data)
hash_object.update(b'test')
hex_dig = hash_object.hexdigest() # 16진수로 추출
print(hex_dig)
```
Chaining 기법을 적용한 해쉬 테이블 코드에서 키 생성 함수를 sha256 해쉬 알고리즘을 사용하도록 변경해보기
```python
import hashlib

hash_table = list([0 for i in range(8)])
def get_key(data):
    hash_object = hashlib.sha256()
    hash_object.update(data.encode())
    hex_dig = hash_object.hexdigest()
    return int(hex_dig, 16)

def hash_function(key):
    return key % 8

def save_data(data,value):
    index_key = get_key(data)
    hash_address = hash_function(index_key)
    if hash_table[hash_address] != 0:
        for index in range(hash_address, len(hash_table)):
            if hash_table[index] == 0:
                hash_table[index] = [index_key,value]
                return
            elif hash_table[index][0] == index_key:
                hash_table[index][1] = value
                return
    else:
        hash_table[hash_address] = [index_key,value]

def read_data(data):
    index_key = get_key(data)
    hash_address = hash_function(index_key)

    if hash_table[hash_address] != 0:
        for index in range(hash_address, len(hash_table)):
            if hash_table[index] == 0:
                return None
            elif hash_table[index][0] == index_key:
                return hash_table[index][1]
print(get_key('db') % 8)
print(get_key('da') % 8)
print(get_key('dh') % 8)

save_data('da', '12345678')
save_data('dh', '33333333')
read_data('da')
```

## 시간 복잡도
- 일반적인 경우(Collision이 없는 경우)는 O(1)
- 최악의 경우(Collision이 모두 발생하는 경우)는 O(n)
    > 해쉬 테이블의 경우, 일반적인 경우를 기대하고 만들기 때문에, 시간 복잡도는 O(1)이라고 할 수 있음
### 검색에서 해쉬 테이블의 사용 예
- 16개의 배열에 데이터를 저장하고, 검색할 때 O(n)
- 16개의 데이터 저장공간을 가진 위의 해쉬 테이블에 데이터를 저장하고, 검색할 때 O(1) -->