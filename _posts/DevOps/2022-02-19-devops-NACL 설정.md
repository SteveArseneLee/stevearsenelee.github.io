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
------ | -----  | -----
source|175.34.136.133|1025
|destination|13.120.100.100|80

Response  
|source|13.120.100.100|80|
|destination|175.34.136.133|1025|

80번 포트는 서버 입장에서 들어오는 것으로 Inbound
1025번 포트는 서버 입장에서 나가는 것으로 Outbound - 임시포트(1024 ~ 65535)

**stateful하다는것은 상태를 기억한다는 뜻**

즉, Security Group에 원래 쏴주면 Inbound : 80 / Outbound : None으로 가는데 stateful함으로써 1025포트도 허용해주는 것  

반대로 NACL처럼 **stateless**는 있는 그대로만 한다는 것으로, Inbound : 80 / Outbound : None을 지킨다.