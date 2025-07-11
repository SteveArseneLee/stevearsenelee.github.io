+++
title = "Milvus Basics"
draft = false
+++
## Milvus란?
> 오픈소스 벡터 DB로, 대규모 벡터 데이터를 효율적으로 저장, 인덱싱, 검색할 수 있도록 설계된 시스템.
- 특히 Similarity Search와 Vector Search를 위해 최적화됨

### 주요 특징
1. 고성능 벡터 검색
- 수십억 개의 벡터에서 밀리초 단위 검색
- 다양한 인덱스 알고리즘 지원 (IVF, HNSW, Annoy 등)
- GPU 가속 지원
2. 확장성
- 수평적 확장 가능
- 클러스터 모드 지원
- 자동 로드 밸런싱
3. 다양한 벡터 타입 지원
- Float vectors
- Binary vectors
- Sparse vectors
- 다차원 벡터 (최대 32,768차원)

### 주요 설계 원칙
1. **Data Plane**과 **Control Plane**의 분리
2. MPP(대규모 병렬처리) 아키텍쳐
3. Shared-storage 구조

## 아키텍쳐
### 1. Access Layer(Proxy)
- Stateless 프로세스로 구성되어 LB(Nginx, K8s Ingress 등)을 통해 unified service address를 제공
- Client 요청을 검증하고, 다중 노드에서 병렬 처리된 결과를 합쳐 전달

### Coordinator
- 클러스터의 "두뇌" 역할, 각 Coordinator는 Active-Standby 구조로 고가용성 제공
- 4개의 sub-coordinator로 구성
