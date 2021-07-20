---
title:  "[Data Structure] Stack"
excerpt: "Stack with python"

categories:
  - Data Structure
tags:
  - [Data Structure, Python]

toc: true
toc_sticky: true
 
date: 2021-07-20
last_modified_at: 2021-07-20
---
## Stack
- 데이터를 제한적으로 접근할 수 있는 구조
    - 한쪽 끝에서만 자료를 넣거나 뺄 수 있는 구조
- 가장 나중에 쌓은 데이터를 가장 먼저 빼낼 수 있는 데이터 구조

### 스택 구조
- 스택은 LIFO(Last In, First Out) 또는 FILO(First In, Last Out) 데이터 관리 방식을 따름
    - LIFO : 마지막에 넣은 데이터를 가장 먼저 추출하는 데이터 관리 정책
    - FILO : 처음에 넣은 데이터를 가장 마지막에 추출하는 데이터 관리 정책
- 대표적인 스택의 활용
    - 컴퓨터 내부의 프로세스 구조의 함수 동작 방식
- 주요 기능
    - push() : 데이터를 스택에 넣기
    - pop() : 데이터를 스택에서 꺼내기
```python
# 재귀함수
def recursive(data):
    if data < 0:
        print("ended")
    else:
        print(data)
        recursive(data-1)
        print("returned", data)
```
스택의 장점
- 구조가 단순해서, 구현이 쉽다.
- 데이터 저장/읽기 속도가 빠르다.
스택의 단점
- 데이터 최대 갯수를 미리 정해야함
- 저장 공간의 낭비가 발생할 수 있음

파이썬 리스트 기능에서 제공하는 메소드로 스택 사용
- append(push), pop 메소드
```python
data_stack = list()
data_stack.append(1)
data_stack.append(2)
data_stack
data_stack.pop()
```

연습) 리스트 변수로 스택을 다루는 pop,push 기능 구현(pop,push함수 없이)
```python
stack_list = list()
def push(data):
    stack_list.append(data)
def pop():
    data = stack_list[-1]
    del stack_list[-1]
    return
for index in range(10):
    push(index)
pop()
```