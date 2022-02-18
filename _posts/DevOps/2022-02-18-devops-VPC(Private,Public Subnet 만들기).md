---
title:  "[DevOps] VPC Private, Public Subnet 만들기"
excerpt: "Private, Public Subnet"

categories:
  - DevOps
tags:
  - [DevOps]

toc: true
toc_sticky: true
 
date: 2022-02-18
last_modified_at: 2022-02-18
---
### VPC 생성
먼저 VPC에 들어간다.  
그 안에서도 좌측의 VPC에 들어가면 계정 생성 시 만들어지는 VPC가 있고(옆으로 쭉 보면 기본VPC로 되있다.)  
VPC 생성을 하면 이름 적고 IPv4 CIDR에 ```10.0.0.0/16```으로 설정하고 테넌시는 기본값으로 한다.
> 테넌시를 전용으로하면 내 하드웨어 상으로 직접 돌리는거라 비용이 많이 든다고 한다.

### 서브넷 생성
서브넷 생성시엔 VPC ID에서 VPC를 선택할 수 있는데 위에서 생성한 VPC를 선택하고 서브넷 이름을 입력하고 가용 영역은 아무거나 선택한다.(선택하지 않으면 AWS에서 자동으로 선택된다)  
> 강의에서는 public-subnet과 private-subnet 이 두개를 만들어줬다.
- public-subnet에선 IPv4 CIDR를 10.0.0.0/24로 입력해준다.
- private-subnet에선 IPv4 CIDR를 10.0.1.0/24로 입력해준다.  

이때 NACL은 자동으로 만들어진다.(보안)  

-----------------
위 내용을 정리하면  
VPC를 10.0.0.0/16으로 생성하고 그 안에  
public subnet(10.0.0.0/24)와 private subnet(10.0.1.0/24)가 만들어져있고, Router에 각각의 Route Table에 NACL에 subnet이 연결되있는 구조다.