---
title:  "[Data Structure] Binary Search Algorithm"
excerpt: "이진탐색 알고리즘 with C"

categories:
  - Data Structure
tags:
  - [Data Structure, C]

toc: true
toc_sticky: true
 
date: 2021-07-05
last_modified_at: 2021-07-05
---
## Binary Search Algorithm
인덱스의 시작과 마지막을 가지고 중앙값을 찾은 뒤 검색
``` cpp
#include <stdio.h>
int BSearch(int ar[], int len, int target){
    int first = 0; // 탐색 대상의 시작 인덱스 값
    int last = len-1; // 탐색 대상의 마지막 인덱스 값
    int mid;

    while (first <= last){
        mid = (first+last)/2; // 탐색 대상의 중앙을 찾음

        if (target == ar[mid]) // 중앙에 저장된 것이 타겟이라면
        {
            return mid; // 탐색 완료!
        }
        else // 타겟이 아니라면 탐색 대상을 반으로 줄임.
        {
            if(target < ar[mid])
                last = mid - 1; // 왜 -1을 하였을까?
            else
                first = mid+1; // 왜 +1을 하였을까?
        }
    }
    return -1; // 찾지 못했을 떄 반환되는 값 -1
}

int main(){
    int arr[] = {1,3,5,7,9};
    int idx;

    idx = BSearch(arr, sizeof(arr)/sizeof(int),7);
    if (idx == -1)
        printf("탐색 실패\n");
    else
        printf("타겟 저장 인덱스 : %d\n", idx);
    
    idx = BSearch(arr, sizeof(arr)/sizeof(int), 4);
    if (idx == -1)
        printf("탐색 실패\n");
    else
        printf("타겟 저장 인덱스 :%d\n",idx);
}
```

재귀
``` cpp
void Recursive(void){
    Recursive(); // 로 다시 돌아감
}
```
이런 형식으로 이루어짐
``` cpp
#include <stdio.h>
void Recursive(int num){
    if(num <= 0) // 재귀의 탈출조건
        return; // 재귀의 탈출!
    printf("Recursive call! %d\n", num);
    Recursive(num-1);
}
int main(){
    Recursive(3);
    return 0;
}
```
RecursiveFactorial.c
``` cpp
#include <stdio.h>

int Factorial(int n){
    if(n == 0)
        return 1;
    else
        return n * Factorial(n-1);
}

int main(){
    printf("1! = %d\n", Factorial(1));
    printf("2! = %d\n", Factorial(2));
    printf("3! = %d\n", Factorial(3));
    printf("4! = %d\n", Factorial(4));
    printf("9! = %d\n", Factorial(9));
}
```
FibonacciFunc.c
``` cpp
#include <stdio.h>
int Fibo(int n){
    if (n==1)
        return 0;
    else if(n==2)
        return 1;
    else
        return Fibo(n-1) + Fibo(n-2);
}
int main(){
    int i;
    for(i=1;i<15;i++)
        printf("%d",Fibo(i));
    return 0;
}
```
``` cpp
#include <stdio.h>
int Fibo(int n){
    printf("func call param%d\n",n);

    if(n==1)
        return 0;
    else if(n==2)
        return 1;
    else
        return Fibo(n-1) + Fibo(n-2);
}

int main(){
    Fibo(7);
    return 0;
}
```