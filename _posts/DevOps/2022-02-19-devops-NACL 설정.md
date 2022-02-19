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

|source|175.34.136.133|1025|
|destination|13.120.100.100|80|

80번 포트는 서버 입장에서 들어오는 것으로 Inbound
1025번 포트는 서버 입장에서 나가는 것으로 Outbound - 임시포트(1024 ~ 65535)