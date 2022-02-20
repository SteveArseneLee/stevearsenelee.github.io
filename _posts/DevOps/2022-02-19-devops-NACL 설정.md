---
title:  "[DevOps] VPC NACL 설정하기"
excerpt: "NACL"

categories:
  - DevOps
tags:
  - [DevOps]

toc: true
toc_sticky: true
 
date: 2022-02-19
last_modified_at: 2022-02-19
---
## NACL 설정하기
- NACL - stateless
- Security Group - stateful

Request  
&nbsp; | &nbsp; |&nbsp; 
:------: | :-----: | :-----:
source|175.34.136.133|1025
destination|13.120.100.100|80

Response  
&nbsp; | &nbsp; |&nbsp; 
:------: | :-----: | :-----:
source|13.120.100.100|80
destination|175.34.136.133|1025

80번 포트는 서버 입장에서 들어오는 것으로 Inbound
1025번 포트는 서버 입장에서 나가는 것으로 Outbound - 임시포트(1024 ~ 65535)

**stateful하다는것은 상태를 기억한다는 뜻**

즉, Security Group에 원래 쏴주면 Inbound : 80 / Outbound : None으로 가는데 stateful함으로써 1025포트도 허용해주는 것  

반대로 NACL처럼 **stateless**는 있는 그대로만 한다는 것으로, Inbound : 80 / Outbound : None을 지킨다.

### AWS에서 NACL 설정하기
기존에 만든 VPC와 서브넷에 연결되어 있는 NACL이 하나 존재할 것이다. 이를 먼저 **private_NACL**로 바꿔준다.  
그 뒤에 **네트워크 ACL 생성**을 누르고 **public_NACL**이란 이름으로 기존 VPC를 선택해 생성해주고 작업에서 서브넷 연결로 public 서브넷에 연결해준다.

#### public NACL 인,아웃바운드 규칙 편집
인바운드는 포트 범위를 22, 80, 443을 추가해주고, 아웃바운드는 1024-65535까지 해준다.  
NACL같은 경우 stateless이기 때문에 규칙을 정확하게 써줘야한다.