+++
title = "Dimensional Modeling: 분석을 위한 데이터 설계의 본질"
draft = false
bookHidden = true
+++

### Fact와 Dimension의 개념
> Fact : "**측정값 / 수치 중심의 이벤트 데이터**"
- 일반적으로는 **집계(Aggregation)** 가 가능한 값들
- 대부분 시간에 따라 변화하며, 특정 기준으로 분류하여 분석하는 대상
- 항상 하나 이상의 Dimension과 연결되어 있으며, 분석 쿼리에서는 집계 함수(SUM, COUNT, AVG 등)의 대상이 됨
```sh
sales_fact
├── date_id (FK)
├── product_id (FK)
├── store_id (FK)
├── quantity_sold (Fact)
├── total_revenue (Fact)
```

> Dimension : "**Fact를 설명하거나 분석 기준이 되는 범주형 데이터**"
- 일반적으로 분석자가 데이터를 "어떤 기준으로 보고 싶은가"를 정의하는 기준
- WHERE, GROUP BY, ORDER BY 절에서 자주 사용됨
- 각 Dimension은 여러 속성(attribute)를 가질 수 있고, 이 속성 간에는 종종 계층(Hierarchy)이 존재함
- 예를 들어, *시간 Dimesion*은 연도 -> 분기 -> 월 -> 일, *지역 Dimension*은 대륙 -> 국가 -> 도시 순으로 계층화할 수 있음
- e.g. 카테고리, 지역, 시간 고객, 상품 등의 범주적(categorical) 데이터
```sh
product_dim
├── product_id (PK)
├── product_name
├── category
├── brand
```

> Fact는 수치 결과, Dimension은 분석 기준

### Dimensional Modeling이란?
> 분석을 위해 데이터를 Fact + Dimension 구조로 설계하는 방법론
- RDB 기반 DW 구조 설계에 최적화됨
- Star / Snowflake / Galaxy 구조로 구현됨
- 분석 쿼리를 효율적으로 처리하기 위한 구조적 기반

#### 구성 요소
- Fact Table: 수치 중심, 여러 Dimension에 연결됨
- Dimension Table: 분석 기준 제공, 계층 포함 가능
- Grain: 하나의 Fact가 의미하는 단위 (ex. 1건의 주문? 1일 매출?)



### Multidimensional Modeing
- Multidimensional Modeling은 데이터를 다양한 분석 축(Dimension)으로 나누어 보고, 각 축의 조합에 따라 하나의 측정값(Fact)를 도출하는 방식임.  
- OLAP의 기본 모델링 방식으로, 사용자는 다양한 축을 기준으로 데이터를 Slice, Dice, Drill-down, Roll-up 등의 방식으로 분석 가능.  
- 이 모델은 특히 OLAP Cube라는 개념으로 시각화되며, X, Y, Z 축에 Dimension이 위치하고, 교차점(Cell)에 하나의 Fact 값이 존재.
- 분석 중심으로 최적화되어 있으며, 빠른 응답 성능과 사용자의 직관적인 이해를 위해 설계됨.

```perl
    시간 차원
       ^
       |
       |     ● (제품A, 2023년, 서울, 100만원)
       |    /
       |   /
       |  /
       | /
       |/
       +------------> 제품 차원
      /|
     / |
    /  |
   /   |
  /    |
 v     v
지역 차원  측정값(판매액)
```

### Multidimensional Modeling과의 관계
항목| Dimensional Modeling | Multidimensional Modeling
-|-|-
관점|구조적 설계 방법론|개념적 분석 모델링
구현|Star/Snowflake Schema|OLAP Cube 기반 축 해석
사용|RDB 기반 DW 설계|BI/OLAP 분석 툴 설계
- 둘은 목적이 다르지만 실무에서는 거의 연동되어 사용된다고 함
- Cube로 보는 시각은 Multidimensional, 테이블 설계는 Dimensional

### Star, Snowflake Schema
#### ⭐ Star Schema
- 비정규화된 Dimension 테이블 + 중심 Fact 테이블
- 쿼리 단순, JOIN 적음
- BI 도구에서 선호됨
```sh
            [product_dim]
                  ↑
[store_dim] ← [sales_fact] → [date_dim]
```

#### ❄️ Snowflake Schema
- Dimension을 정규화하여 계층 구조 표현
- 중복 적고, 정합성 높음
- JOIN이 많아져 성능 저하 가능
```sh
category_dim ← subcategory_dim ← product_dim ← sales_fact
```

#### 🌌 Galaxy Schema
- 여러 Fact 테이블 존재
- 공통 Dimension을 공유 (통합 분석용)
- 구조 복잡하고 설계 난이도 높음
```sh
        [product_dim]
          ↑       ↑
  [sales_fact]  [refund_fact]`
```
스키마 | 구조 복잡도 | 성능 | 정합성 | 특징
-|-|-|-|-
Star|낮음|빠름|중간|단순 분석에 최적화
Snowflake|중간|느릴 수 있음|높음|계층 표현에 유리
Galaxy|높음|복합|높음|통합 분석 + 확장성


### 스키마 선택 기준
- 데이터 중복을 감수하더라도 분석 편의성/속도가 우선 → ⭐ Star
- 계층 구조 표현, 정합성 유지가 중요 → ❄️ Snowflake
- 여러 이벤트 테이블(주문, 반품, 배송 등)을 함께 분석 → 🌌 Galaxy
> 💬 핵심: 구조는 도메인보다 "분석 목적 + 유지 전략" 기준으로 선택함
