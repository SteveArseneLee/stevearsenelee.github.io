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



하지만 아직 IGW와 Router가 연결되어 있지 않으므로...!!!!

### 라우팅 테이블 생성
라우팅 테이블 생성 후 public-rtb를 작업에서 __서브넷 연결 편집__ 을 누르고 public subnet에 연결해준다.  
public같은 경우는 외부와도 연결이 되어야 해서 __라우팅 편집__ 을 해줘야한다.  
__라우팅 편집__ 에 들어가서 0.0.0.0/0에 대상을 기존에 만들었던 igw로 추가해주는데 이는 기존의 subnet인 10.0.0.0/16(local)이외의 모든 트래픽을 외부로 보내는 것이다.  
private같은 경우는 외부와 연결하지 않기 때문에 수정하지 않아도 된다.