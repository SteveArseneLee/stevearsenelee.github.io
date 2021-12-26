<!-- ---
title:  "[Data Structure] Linked List"
excerpt: "연결리스트 with C"

categories:
  - Data Structure
tags:
  - [Data Structure, C]

toc: true
toc_sticky: true
 
date: 2021-07-14
last_modified_at: 2021-07-14
---


### 리스트의 ADT
- void ListInit(List *plist);
    - 초기화할 리스트의 주소 값을 인자로 전달
    - 리스트 생성 후 제일 먼저 호출되어야 하는 함수
- void LInsert(List *plist, LData data);
    - 리스트에 데이터 저장. 매개변수 data에 전달된 값을 저장
- int LFirst(List *plist, LData *pdata);
    - 첫 번째 데이터가 pdata가 가리키는 메모리에 저장
    - 데이터의 참조를 위한 초기화가 진행됨
    - 참조 성공 시 TRUE(1), 실패시 FALSE(0) 반환
- int LNext(List *plist, LData *pdata);
    - 참조된 데이터의 다음 데이터가 pdata가 가리키는 메모리에 저장됨
    - 순차적인 참조를 위해서 반복 호출 가능
    - 참조를 새로 시작하려면 먼저 LFirst 함수를 호출
    - 참조 성공 시 TRUE(1), 실패 시 FALSE(0) 반환
- LData LRemove(List *plist);
    - LFirst 또는 LNext 함수의 마지막 반환 데이터를 삭제
    - 삭제된 데이터는 반환됨
    - 마지막 반환 데이터를 삭제하므로 연이은 반복 호출을 허용하지 않음
- int LCount(List *plist);
    - 리스트에 저장되어 있는 데이터의 수를 반환


## 연결리스트
### 배열 기반 리스트의 특징
1. 배열로 만들었으므로 특정한 위치의 원소에 즉시 접근할 수 있다는 장점이 있음
2. 데이터가 들어갈 공간을 미리 메모리에 할당해야 한다는 단점이 있음
3. 원하는 위치로의 삽입이나 삭제가 비효율적

> 호출순서
    LFirst -> LNext -> LNext -> LNext -> LNext ...

### 배열기반 연결리스트
```cpp
#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#define INF 10000

int arr[INF];
int count = 0;

void addBack(int data){
    arr[count] = data;
    count++;
}


void addFirst(int data){
    for(int i = count; i>= 1; i--){ // 한칸씩 원소를 당김
        arr[i] = arr[i-1];
    }
    arr[0] = data;
    count++;
}

void removeAt(int index){
    for(int i=index;i<count-1;i++){
        arr[i] = arr[i+1];
    }
    count--;
}

void show(){
    for(int i = 0; i<count;i++){
        printf("%d", arr[i]);
    }
}
int main(){
    addBack(5);
    addBack(3);
    addBack(7);
    addFirst(2);
    addFirst(8);
    removeAt(2);
    show();
}
```

---

### 포인터 기반 연결리스트
1. 일반적으로 연결리스트는 구조체와 포인터를 함께 사용해 구현
2. 연결 리스트는 리스트의 중간 지점에 노드를 추가하거나 삭제할 수 있어야 함
3. 필요할 때마다 메모리 공간을 할당 받음
4. (주의) 삽입 및 삭제 기능에서의 예외 사항을 처리할 필요가 있음.
5. (주의) 삭제할 원소가 없는데 삭제하는 경우, Head 노드 자체를 잘못 넣는 경우 등을 체크
6. 삽입 및 삭제가 배열에 비해 간단함
7. 배열과 다르게 특정 인덱스로 즉시 접근하지 못하며, 원소를 차례대로 검색해야 함
8. 추가적인 포인터 변수가 사용되므로 메모리 공간의 낭비
<br>

구성
1. 포인터를 이용해 단방향적으로 다음 노드를 가리킴
2. 일반적으로 연결 리스트의 시작 노드를 헤드(Head)라고 하며 별도로 관리
3. 다음 노드가 없는 끝 노드의 다음 위치 값으로는 NULL을 넣음



```cpp
#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <stdlib.h>

typedef struct {
    int data;
    struct Node *next;
} Node;

Node *head;

void addFront(Node *root, int data){
    Node *node = (Node*)malloc(sizeof(Node));
    node->data = data;
    node->next = root->next;
    root->next = node;
}

void removeFront(Node *root){
    Node *front = root->next;
    root->next = front->next;
    free(front);
}

// 메모리 해제 함수
void freeAll(Node *root){
    Node *cur = head->next;
    while (cur != NULL){
        Node *next = cur->next;
        free(cur);
        cur = next;
    }
}

void showAll(Node *root){
    Node *cur = head->next;
    while(cur != NULL){
        printf("%d ", cur->data);
        cur = cur->next;
    }
}

int main(){
    head = (Node*)malloc(sizeof(Node));
    head->next = NULL;
    addFront(head,2);
    addFront(head,1);
    addFront(head,7);
    addFront(head,9);
    addFront(head,8);
    removeFront(head);
    showAll(head);
    freeAll(head);

    // Node *node1 = (Node*) malloc(sizeof(Node));
    // node1->data = 1;
    // Node *node2 = (Node*) malloc(sizeof(Node));
    // node2->data = 2;
    // head->next = node1;
    // node1->next = node2;
    // node2->next = NULL;
    // Node *cur = head->next;
    // while(cur != NULL){
    //     printf("%d ", cur->data);
    //     cur = cur->next;
    // }
}
``` -->