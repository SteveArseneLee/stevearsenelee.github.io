---
title:  "[DevOps] VPC Bastion Host"
excerpt: "Bastion Host"

categories:
  - DevOps
tags:
  - [DevOps]

toc: true
toc_sticky: true
 
date: 2022-02-20
last_modified_at: 2022-02-20
---
# Bastion Host
인터넷 내의 유저가 **private subnet**에 접근하기 위해 취하는 방법  
**public subnet**에서 대리인 역할을 함

EC2에서 인스턴스 생성을 하고, public-vpc와 public 서브넷을 선택해주고, 마그네틱 볼륨으로 지정해준다.   
보안 그룹도 새롭게 public-sg로 설정해주고 모든 ICMP-IPv4로 규칙을 추가해준다.  
private 인스턴스도 동일하게 생성해준다. 이때 보안 그룹의 소스는 public-sg에서 오는것만 허용해준다.  
