<!-- ---
title:  "[Data Structure] Linked List"
excerpt: "Linked List with python"

categories:
  - Data Structure
tags:
  - [Data Structure, Python]

toc: true
toc_sticky: true
 
date: 2021-07-20
last_modified_at: 2021-07-20
---
## Linked List
### Linked List 구조
- 연결 리스트라고도 함
- 배열은 순차적으로 연결된 공간에 데이터를 나열하는 데이터 구조
- 링크드 리스트는 떨어진 곳에 존재하는 데이터를 화살표로 연결해서 관리하는 데이터 구조
- 링크드 리스트 기본 구조와 용어
    - Node : 데이터 저장 단위 (데이터값, 포인터)로 구성
    - Pointer : 각 노드 안에서, 다음이나 이전의 노드와의 연결 정보를 가지고 있는 공간

Node 구현
```python
class Node:
    def __init__(self,data,next=None):
        self.data = data
        self.next = next
```
Node와 Node 연결(포인터 활용)
```python
node1 = Node(1)
node2 = Node(2)
node1.next = node2
head = node1
```
Linked List로 데이터 추가
```python
class Node:
    def __init__(self,data,next=None):
        self.data = data
        self.next = next
def add(data):
    node = head
    while node.next:
        node = node.next
    node.next = Node(data)

node1 = Node(1)
node2 = Node(2)
node1.next = node2
head = node1
for index in range(1,10):
    add(index)
```
Linked List 데이터 출력
```python
node = head
while node.next:
    print(node.data)
    node = node.next
```
Linked List의 장단점
- 장점
    - 미리 데이터 공간을 할당하지 않아도 됨
- 단점
    - 연결을 위한 별도 데이터 공간이 필요하므로, 저장공간 효율이 높지 않음
    - 연결 정보를 찾는 시간이 필요하므로 접근 속도가 느림
    - 중간 데이터 삭제시, 앞뒤 데이터의 연결을 재구성해야하는 부가적인 작업 필요

### Linked List 데이터 사이에 데이터를 추가
node1~10까지 있다고 가정
```python
node3 = Node(1.5)
node = head
search = True
while search:
    if node.data == 1:
        search = False
    else:
        node = node.next
node_next = node.next
node.next = node3
node3.next = node_next
```
파이썬 OOP로 Linked List 구현
```python
class Node:
    def __init__(self, data, next=None):
        self.data = data
        self.next = next

class NodeMgmt:
    def __init__(self, data):
        self.head = Node(data)
    def add(self, data):
        if self.head == ":
            self.head = Node(data)
        else:
            node = self.head
            while node.next:
                node = node.next
            node.next = Node(data)
    def desc(self):
        node = self.head
        while node:
            print(node.data)
            node = node.next

linkedlist1 = NodeMgmt(0)
linkedlist1.desc()

for data in range(1,10):
    linkedlist1.add(data)
```

### Linked List의 특정 노드 삭제
```python
class Node:
    def __init__(self, data, next=None):
        self.data = data
        self.next = next

class NodeMgmt:
    def __init__(self, data):
        self.head = Node(data)
    def add(self, data):
        if self.head == ":
            self.head = Node(data)
        else:
            node = self.head
            while node.next:
                node = node.next
            node.next = Node(data)
    def desc(self):
        node = self.head
        while node:
            print(node.data)
            node = node.next
    def delete(self,data):
        if self.head == ":
            print("해당 값을 가진 노드가 없음")
            return
        # head 삭제
        if self.head.data == data:
            temp = self.head
            self.head = self.head.next
            del temp
        # 마지막 or 중간 노드 삭제
        else:
            node = self.head
            while node.next:
                if node.next.data == data:
                    temp = node.next
                    node.next = node.next.next
                    del temp
                else:
                    node = node.next
```
테스트(노드 1개)
```python
linkedlist1 = NodeMgmt(0)
linkedlist1.desc()
linkedlist1.head

linkedlist1.delete(0)
linkedlist1.head
```
테스트(여러 노드)
```python
for data in range(1,10):
    linkedlist1.add(data)
linkedlist1.desc()

linkedlist1.delete(4)
linkedlist1.desc()

linkedlist1.delete(9)
linkedlist1.desc()
``` -->