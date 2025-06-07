---
title:  "[DevOps] AWS 기초와 VPC"
excerpt: "AWS 기초와 VPC"

categories:
  - DevOps
tags:
  - [DevOps]

toc: true
toc_sticky: true
 
date: 2021-12-29
last_modified_at: 2021-12-29
---
# 클라우드 컴퓨팅
__장점__
- 언제 어디서든, 접근 가능
- 원하면 언제든 컴퓨터 자원 늘릴수 있음
- 사용한 만큼만 지불하면 됨
- 초기비용 적게 듬
- 몇 분 만에 전 세계에 서비스 런칭 가능

__단점__
- 관리를 위해선 고급 전문 지식 필요
- 파악하기 힘든 너무나 광범위한 서비스  


---


  
# AWS 주요 서비스
## 컴퓨팅 서비스
__AWS EC2 (elastic)__
- 사양과 크기를 조절할 수 있는 컴퓨팅 서비스

__AWS Lightsail__
- 가상화 프라이빗 서버

__AWS Auto Scaling__
- 서버의 특정 조건에 따라 서버를 추가/삭제할 수 있게하는 서비스

__AWS Workspaces__
- 사내 pc를 가상화로 구성해 문서를 개인 pc에 보관하는 것이 아니라 서버에서 보관하게 하는 서비스


## 네트워킹 서비스
__AWS Route 53__
- DNS(Domain Name System) 웹서비스

__AWS VPC__
- 가상 네트워크를 클라우드 내에 생성/구성

__AWS Direct Connect__
- On-premise 인프라와 aws를 연결하는 네트워킹 서비스

__AWS ELB__
- 부하 분산(로드 밸런싱) 서비스

## 스토리지/데이터베이스 서비스
__AWS S3__
- 여러가지 파일을 형식에 구애받지 않고 저장

__AWS RDS__
- 가상 SQL 데이터베이스 서비스

__AWS DynamoDB__
- 가상 NoSQL 데이터베이스 서비스

__AWS ElastiCache__
- In-Memory 기반의 cache 서비스 (빠른 속도 필요로 하는 서비스와 연계)

## 데이터 분석 & AI
__AWS Redshift__
- 데이터 분석에 특화된 스토리지 시스템

__AWS EMR__
- 대량의 데이터를 효율적으로 가공&처리

__AWS Sagemaker__
- 머신 러닝&데이터분석을 위한 클라우드 환경 제공


---


# IP address
컴퓨터 사이에 통신을 하려면 컴퓨터의 위치값을 알아야 함
- A Class는 Network bit가 7bit, Host bit가 24bit
=> 1개의 네트워크가 2^24개의 ip를 보유 / 이런 네트워크가 2^7개만큼 있음

- B Class는 Network bit가 14bit, Host bit가 16bit
=> 1개의 네트워크가 2^16개의 ip를 보유 / 이런 네트워크가 2^14개만큼 있음

- A Class는 Network bit가 21bit, Host bit가 8bit
=> 1개의 네트워크가 2^8개의 ip를 보유 / 이런 네트워크가 2^21개만큼 있음


---


# VPC(Virtual Private Cloud)
Amazon VPC를 이용하면 사용자가 정의한 가상 네트워크로 AWS 리소스를 시작할 수 있음  
- 계정 생성 시 default로 VPC를 만들어줌
- EC2, RDS, S3 등의 서비스 활용 가능
- 서브넷 구성
- 보안 설정(IP block, inbound outbound 설정)
- VPC Peering(VPC 간의 연결)
- IP 대역 지정 가능
- VPC는 하나의 Region에만 속할 수 있음


subnet
- VPC의 하위 단위(sub + network)
- 하나의 AZ에서만 생성 가능
- 하나의 AZ에는 여러 개의 subnet 생성 가능