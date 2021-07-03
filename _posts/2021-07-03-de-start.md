---
title:  "[Data Engineering] 시작하기."
excerpt: "WHOHO"

categories:
  - Data Engineering
tags:
  - [Blog, jekyll, Github, Git]

toc: true
toc_sticky: true
 
date: 2021-07-03
last_modified_at: 2021-07-03
---
# 데이터 아키텍쳐시 고려사항
### 비즈니스 모델 상 가장 중요한 데이터는 무엇?
- 비용 대비 비즈니스 임팩트가 가장 높은 데이터 확보

### 데이터 거버넌스(Data Governance)
- 원칙(Principle)
    - 데이터를 유지 관리하기 위한 가이드
    - 보안, 품질, 변경관리
- 조직(Organization)
    - 데이터를 관리할 조직의 역할과 책임
    - 데이터 관리자, 데이터 아키텍트
- 프로세스(Process)
    - 데이터 관리를 위한 시스템
    - 작업 절차, 모니터 및 측정

### 유연하고 변화 가능한 환경 구축
- 특정 기술 및 솔루션에 얽매이지 않고 새로운 테크를 빠르게 적용할 수 있는 아키텍쳐를 만드는 것
- 생성되는 데이터의 형식이 변화할 수 있는 것처럼 그에 맞는 툴들과 솔루션들도 빠르게 변화할 수 있는 시스템을 구축하는 것

### Real Time(실시간) 데이터 핸들링이 가능한 시스템
- 밀리세컨 단위의 스트리밍 데이터가 됐건 하루에 한번 업데이트 되는 데이터든 데이터 아키텍쳐는 모든 스프트의 데이터를 핸들링
    - Real Time Streaming Data Processing
    - Cronjob
    - Serverless Triggered Data Processing

### 시큐리티
- 내부와 외부 모든 곳에서부터 발생할 수 있는 위험 요소들을 파악하여 어떻게 데이터를 안전하게 관리할 수 있는지 아키텍쳐 안에 포함

### 셀프 서비스 환경 구축
- 데이터 엔지니어 한명만 엑세스가 가능한 데이터 시스템은 확장성이 없는 데이터 분석 환경
    - Bl Tools
    - Query System for Analysis
    - Front-end data applications

# 데이터 시스템의 옵션들
### API
- 마케팅, CRM, ERP 등 다양한 플랫폼 및 소프트웨어들은 API를 통해 데이터를 주고 받을 수 있는 환경을 구축해 생태계를 생성

### Relational Databases
- 데이터의 관계도를 기반으로 한 디지털 데이터베이스로 데이터의 저장을 목적으로 생겨남.
- SQL이라고 하는 스탠다드 방식을 통해 자료를 열람하고 유지
- 현재 대부분의 서비스들이 가장 많이 쓰고 있는 데이터 시스템

### NoSQL Databse
- Not Only SQL
- Unstructured, Schema Less Data
- Scale horizontally
- Highly scalable / Less expensive to maintain

### Hadoop / Spark / Presto 등 빅데이터 처리
- Distributed Storage System / MapReduce를 통한 병렬 처리
- Spark :
    - Hadoop의 진화된 버전으로 빅데이터 분석 환경에서 Real Time 데이터를 프로세싱하기에 더 최적화
    - Java, Python, Scala를 통한 API를 제공해 애플리케이션 생성
    - SQL Query 환경을 서포트해 분석가들에게 더 각광

### 서버시르 프레임워크
- Triggered by http requests, database events, queuing services
- Pay as you use
- Form of functions
- 3rd party 앱들 및 다양한 API를 통해 데이터를 수집 정제하는데 유용

# 데이터 파이프라인
- 데이터를 한 장소에서 다른 장소로 옮기는 것
- API -> Database
- Database -> Database
- Database -> Bl Tool
### 데이터 파이프라인이 필요한 경우
- 다양한 데이터 소스들로부터 많은 데이터를 생성하고 저장하는 서비스
- 데이터 사일로 : 마케팅, 어카운팅, 세일즈, 오퍼레이션 등 각 영역의 데이터가 서로 고립되어 있는 경우
- 실시간 혹은 높은 수준의 데이터 분석이 필요한 비즈니스 모델
- 클라우드 환경으로 데이터 저장

## 데이터 프로세싱 자동화
- 필요한 데이터를 추출, 수집, 정제하는 프로세싱을 최소한의 사람 인풋으로 머신이 운영하는 것

### 자동화를 위한 고려사항
- 데이터 프로세싱 스텝들
- 에러 핸들링 및 모니터링
- 트리거 / 스케쥴링

### Ad hoc vs. Automated
- Ad hoc 분석 환경 구축은 서비스를 지속적으로 빠르게 변화시키기 위해 필수적인 요소
- 이니셜 데이터 삽입, 데이터 Backfill 등을 위해 Ad hoc 데이터 프로세싱 시스템 구축 필요
- Automated : 이벤트, 스케쥴 등 트리거를 통해 자동화 시스템 구축