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

{{< katex display=true >}}
f(x) = \int_{-\infty}^\infty\hat f(\xi)\,e^{2 \pi i \xi x}\,d\xi
{{< /katex >}}

## VectorDB의 핵심 기능 및 특징

## 주요 인덱싱 알고리즘

## 대표 VectorDB 비교

## RAG 및 주요 응용 사례

## 내부 아키텍쳐 구조

## 성능 최적화와 분산 설계

## 참고 자료
- [Qdrant Docs](https://qdrant.tech/documentation/overview/?selector=aHRtbCA%2BIGJvZHkgPiBtYWluID4gc2VjdGlvbiA%2BIGRpdiA%2BIGRpdiA%2BIGRpdjpudGgtb2YtdHlwZSgyKSA%2BIGRpdiA%2BIGRpdjpudGgtb2YtdHlwZSgxKSA%2BIGFydGljbGUgPiBoMjpudGgtb2YtdHlwZSgyKQ%3D%3D&q=vectordb)