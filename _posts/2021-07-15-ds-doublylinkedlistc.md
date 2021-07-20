---
title:  "[Data Structure] 양방향 연결리스트"
excerpt: "양방향 연결리스트 with C"

categories:
  - Data Structure
tags:
  - [Data Structure, C]

toc: true
toc_sticky: true
 
date: 2021-07-15
last_modified_at: 2021-07-15
---
## 양방향 연결 리스트
1. 양방향 연결 리스트는 머리(Head)와 꼬리(Tail)을 모두 가진다는 특징이 있음
2. 양방향 연결 리스트의 각 노드는 앞 노드와 뒤 노드의 정보를 모두 저장하고 있음
3. (주의) 삽입 및 삭제 기능에서의 예외 사항을 처리할 필요가 있음
4. 더 이상 삭제할 원소가 없는데 삭제하는 경우 등을 체크
5. 양방향 연결 리스트에서는 각 노드가 앞 노드와 뒤 노드의 정보를 저장하고 있음
6. 양방향 연결 리스트를 이용하면 리스트의 앞에서부터 혹은 뒤에서부터 모두 접근가능

```cpp
#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <stdlib.h>

typedef struct {
    int data;
    struct Node *prev;
    struct Node *next;
} Node;

Node *head, *tail;

void insert(int data){
    Node *node = (Node*) malloc(sizeof(Node));
    node->data = data;
    Node *cur;
    cur = head->next;
    while(cur->data < data && cur != tail){
        cur = cur->next;
    }
    Node* prev = cur->prev;
    prev->next = node;
    node->prev = prev;
    cur->prev = node;
    node->next = cur;
}

void removeFront(){
    Node* node = head->next;
    head->next = node->next;
    Node* next = node->next;
    next->prev = head;
    free(node);
}

void show(){
    Node* cur = head->next;
    while(cur != tail){
        printf("%d ", cur->data);
        cur = cur->next;
    }
}

int main(){
    head = (Node*) malloc(sizeof(Node));
    tail = (Node*) malloc(sizeof(Node));
    head->next = tail;
    head->prev = head;
    tail->next = tail;
    tail->prev = head;
    insert(2);
    insert(1);
    insert(3);
    insert(9);
    insert(7);
    removeFront();
    show();
}
```