<!-- ---
title:  "[Data Structure] Queue"
excerpt: "Queue with python"

categories:
  - Data Structure
tags:
  - [Data Structure, Python]

toc: true
toc_sticky: true
 
date: 2021-07-20
last_modified_at: 2021-07-20
---
## Queue
- 가장 먼저 넣은 데이터를 가장 먼저 꺼낼 수 있는 구조
    - FIFO(First-In, First-Out) 또는 LILO(Last-In, Last-Out)방식으로 스택과 꺼내는 순서가 반대

알아둘 용어
- Enqueue : 큐에 데이터를 넣는 기능
- Dequeue : 큐에서 데이터를 꺼내는 기능
> queue 라이브러리
    - Queue() : 가장 일반적인 큐 구조
    - LifoQueue() : 나중에 입력된 데이터가 먼저 출력되는 구조
    - PriorityQueue() : 데이터마다 우선순위를 넣어서, 우선순위가 높은 순으로 데이터 출력
### Queue()로 큐 만들기(가장 일반적인 큐, FIFO(First-In, First-Out))
```python
import queue
data_queue = queue.Queue()

data_queue.put("unicoding")
data_queue.put(1)
data_queue.qsize()
data_queue.get()
data_queue.qsize()
data_queue.get()
data_queue.qsize()
```
### LifoQueue()로 큐 만들기(LIFO(Last-In, First-Out))
```python
import queue
data_queue = queue.LifoQueue()

data_queue.put("funcoding")
data_queue.put(1)
data_queue.qsize()
data_queue.get()
```
### PriorityQueue()로 큐 만들기
```python
import queue
data_queue = queue.PriorityQueue()

data_queue.put((10, "Korea"))
data_queue.put((5,1))
data_queue.put((15, "China"))
data_queue.qsize()
data_queue.get()
```
> 큐가 많이 쓰이는 곳...
    - 멀티 태스킹을 위한 프로세스 스케쥴링 방식을 구현하기 위해 많이 사용됨
연습) 리스트 변수로 큐를 다루는 enqueue,dequeue기능 구현
```python
queue_list = list()

def enqueue(data)
    queue_list.append(data)

def dequeue()
    data = queue_list[0]
    del queue_list[0]
    return data

for index in range(10):
    enqueue(index)

len(queue_list)
dequeue()
``` -->