---
title:  "[DevOps] VPC Internet Gateway와 라우팅 테이블 생성"
excerpt: "Internet Gateway와 라우팅 테이블"

categories:
  - DevOps
tags:
  - [DevOps]

toc: true
toc_sticky: true
 
date: 2022-02-19
last_modified_at: 2022-02-19
---
### IGW 생성
좌측의 __인터넷 게이트웨이__ 를 누르고 igw를 생성한다. 그러면 상태가 __detached__ 가 나오는데, 이는 어떠한 VPC에도 연결되어 있지 않다는 뜻이다.  
해당 igw를 선택하고 작업에서 VPC에 연결을 한다. 아까 만든 VPC를 선택해준다.