+++
title = "What is VectorDB?"
draft = false
+++
## VectorDB란?
VectorDB(Vector Database) 는 고차원 수치 벡터(embedding)를 효율적으로 저장하고, 검색하며, 관리할 수 있도록 설계된 특수한 데이터베이스.  
텍스트, 이미지, 오디오, 사용자 행동 등 비정형 데이터를 임베딩 벡터로 변환한 후, 해당 벡터를 기반으로 유사도 검색을 수행할 수 있는 시스템입니다.

### 정의와 개념
VectorDB는 **벡터 임베딩(Vector Embeddings)**을 기본 데이터 타입으로 하는 데이터베이스로, 전통적인 관계형 데이터베이스의 행과 열 구조 대신 고차원 벡터 공간에서 데이터를 표현하고 관리합니다.
```python
# 벡터 표현 예시
text_vector = [0.1, -0.3, 0.7, 0.2, ...]  # 384차원
image_vector = [0.8, 0.1, -0.5, 0.9, ...]  # 2048차원
audio_vector = [0.4, -0.2, 0.6, 0.1, ...]  # 512차원
```

### 핵심 구성 요소
- 벡터 저장소 : 고차원 벡터의 효율적 저장
- 인덱스 엔진 : 빠른 유사도 검색을 위한 인덱싱
- 유사도 계산 : 벡터 간 거리/유사도 측정
- 메타데이터 관리 : 벡터와 연관된 부가 정보 저장


## 왜 VectorDB가 필요한가?
### 전통적 데이터베이스의 한계
- 전통적인 RDB/NoSQL은 정확 일치 기반 검색에 최적화됨
- 반면 비정형 데이터는 의미적 유사도(semenatic similarity)가 핵심이며, 단순 SQL 질의로는 처리 불가
- 유사 문서 검색, 추천 시스템, RAG 등에선 수백만~수십억 벡터에서 빠른 유사도 검색이 필수
- ANN(근사 최근접 이웃) 구조를 통해 속도&확장성을 확보할 수 있음

키워드 기반 검색의 문제점
```sql
-- 전통적 SQL 검색
SELECT * FROM documents 
WHERE content LIKE '%머신러닝%' OR content LIKE '%AI%';
```
한계점
- 의미적 이해 부족: "인공지능"과 "AI"의 동일성 인식 불가
- 동의어 처리 한계: "자동차"와 "차량"의 관련성 파악 어려움
- 문맥 이해 부족: "사과"(과일 vs 사과하다)의 구분 불가

데이터 타입 | 전통 DB | VectorDB
-|-|-
텍스트 | 키워드 매칭 | 의미적 유사도
이미지 | 메타데이터만 | 시각적 특성
오디오 | 파일 경로만 | 음향적 특성
동영상 | 제목/태그만 | 내용 기반

### AI 시대의 요구사항
대규모 언어 모델(LLM)의 등장
- GPT-3/4: 1750억~1조 개 파라미터
- BERT: 문맥적 임베딩 생성
- T5: 텍스트-투-텍스트 변환

RAG(Retrieval-Augmented Generation)의 필요성
```python
# RAG 파이프라인
def rag_pipeline(query):
    # 1. 쿼리 벡터화
    query_vector = embedding_model.encode(query)
    
    # 2. 관련 문서 검색 (VectorDB 필수)
    relevant_docs = vector_db.search(query_vector, top_k=5)
    
    # 3. 컨텍스트 구성
    context = "\n".join([doc.content for doc in relevant_docs])
    
    # 4. LLM 생성
    response = llm.generate(f"Context: {context}\nQuery: {query}")
    return response
```


## 벡터와 유사도 검색의 기초
- 임베딩 벡터는 딥러닝 모델(e.g. BERT, CLIP, Word2Vec)로 생성된 고차원 실수형 벡터
### 유사도 측정 방법
거리 메트릭 비교
메트릭 | 공식 | 특징 | 사용 사례
-|-|-|-

코사인 유사도
유클리드 거리
맨하탄 거리
내적


{{< katex display=true >}}
f(x) = \int_{-\infty}^\infty\hat f(\xi)\,e^{2 \pi i \xi x}\,d\xi
{{< /katex >}}

## VectorDB의 핵심 기능 및 특징
기능 | 설명
-|-
고차원 벡터 저장 | 수백~수천 차원의 벡터 지원
인덱싱 구조(AI용) | HNSW, IVF, PQ 등의 ANN 인덱스 시스템
메타데이터 필터링 | 벡터 + 필터 조합 질의 지원
확장성 | 수백만~수십억 벡터 저장, 분산·샤딩 가능
실시간/저지연 응답 | 밀리초 단위 검색
ML 워크플로우 통합 | HuggingFace, OpenAI, TensorFlow 등과 연동 용이
CRUD 지원 | 생성, 검색, 업데이트, 삭제 가능


## 주요 인덱싱 알고리즘
### IVF(Inverted File)
- [IVF_FLAT](https://milvus.io/docs/ivf-flat.md)
- K-means 클러스터링 기반 인덱싱
- 클러스터 중심(centroid)과 쿼리 유사도 기반 검색 속도 향상

### HNSW(Hierachical Navigable Small WOrld)
- [HNSW](https://milvus.io/docs/hnsw.md)
- 다계층 그래프 기반 ANN 구조
- $log(N)$ 시간 복잡도, 높은 정확동와 빠른 응답

### PQ(Product Qunaitzation)
- 벡터를 sub-quantize하여 메모리와 계산량 절감
- [IVF-PQ](https://milvus.io/docs/ivf-pq.md) 조합 시 효율 극대화

## 대표 VectorDB 비교
제품 | 유형 | 언어 | 인덱스 | 특징
-|-|-|-|-
Milvus | 오픈소스 | C++/Go | IVF, HNSW, PQ | 분산·GPU 지원, 엔터프라이즈 
Qdrant | 오픈소스 | Rust | HNSW | 고속 RPS, 메타필터 기능
Weaviate | 오픈소스 | Go | HNSW | GraphQL, 자동 임베딩
Chroma | 오픈소스 | Rust/Python | HNSW | LLM 연결 중심, 경량
FAISS | 라이브러리 | C++/Python | IVF, PQ, HNSW | 현업·연구용, GPU 지원
Pinecone, Zilliz Cloud | SaaS | – | 내부 ANN | 완전관리형, 서버리스


## RAG 및 주요 응용 사례
- RAG : 벡터 검색 결과를 LLM 입력으로 응용
- 추천 시스템 : 사용자&상품 임베딩 기반 추천
- 이미지/비디오 검색 : CLIP 임베딩 기반 유사 컨텐츠 검색
- NLP/의미 검색 : 문서 클러스터링, 이상 탐지, 의미 검색

## 내부 아키텍쳐 구조
```
Embedding Generator (BERT/CLIP 등)
       ↓
     VectorDB Core
     - Vector Store
     - ANN 인덱스
     - Metadata 체인
       ↓
     Query API (REST/gRPC/SDK)
```
- 인덱는는 FAISS, HNSW, IVF-PQ 등 ANN 구조 활용

## 성능 최적화와 분산 설계
- Index 튜닝 : HNSW, IVF(n_probes)
- 벡터 압축 : PQ, Scalar Quantization, PCA
- 하드웨어 활용 : GPU 가속(cuVS)
- 분산 처리 : 샤딩 구조로 수평 확장
