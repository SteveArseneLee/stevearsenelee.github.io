---
title:  "[DevOps] DevOps' start"
excerpt: "준비과정"

categories:
  - DevOps
tags:
  - [DevOps]

toc: true
toc_sticky: true
 
date: 2021-12-25
last_modified_at: 2021-12-29
---
# DevOps 정의
제품의 변경사항을 품질을 보장함과 동시에 프로덕션에 반영하는데 걸리는 시간을 단축하기 위한 실천 방법의 모음

> 개발(Dev)와 운영(Ops)의 합성어

### 데브옵스 실천방법 : AWS
- 지속적 통합(Continuous Integration)
- 지속적 배포(Continuous Delivery)
- 마이크로서비스(Micro-services)
- IaC(Infrastructure as Code)
- 모니터링과 로깅(Monitoring & Logging)
- 소통 및 협업(Communication & Collaboration)


### 데브옵스 팀의 업무 도메인
- 네트워크 (Network)
- 오케스트레이션 플랫폼 (Orchestration Platform)
- 관측 플랫폼 (Observability Platform)
- 개발 및 배포 플랫폼 (Development & Deployment Platform)
- 클라우드 플랫폼 (Cloud Platform)
- 보안 플랫폼 (Security Platform)
- 데이터 플랫폼 (Data Platform)
- 서비스 운영 (Service Operations)


### 데브옵스 팀의 핵심 지표
- 장애복구 시간, MTTR (Mean Time to Recovery)
- 변경으로 인한 결함률 (Change Failure Rate)
- 배포 빈도 (Deployment Frequency)
- 변경 적용 소요 시간 (Lead Time for Changes)



# AWS 실습 환경 구성
## Mac - Homebrew 설치
[homebrew](https://brew.sh)

패키지 검색
> brew search TEXT \| /REGEX

패키지 상세 정보 확인
> brew info [FORMULA\|CASK...]

패키지 설치
> brew install FORMULA\|CASK...
 
패키지 업그레이드
> brew upgrade [FORMULA\|CASK...]

Homebrew 업데이트