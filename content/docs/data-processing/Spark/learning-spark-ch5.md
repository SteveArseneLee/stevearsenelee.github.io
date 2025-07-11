+++
title = "Learning Spark Ch.5"
draft = false
weight = 5
+++
# Apache Spark SQL 및 DataFrames: 외부 데이터 소스와의 상호 작용
## 개요 및 배경
### Spark SQL의 역사적 배경
Apache Spark SQL은 관계형 처리를 Spark의 함수형 프로그래밍 API와 통합하는 핵심 구성 요소이며 그 기원은 *Shark 프로젝트*에서 시작되었습니다:
- Shark의 역할: Apache Spark 위에 Hive 코드베이스를 구축하여 Hadoop 시스템에서 최초의 대화형 SQL 쿼리 엔진 중 하나가 됨
- 성과: 기업 데이터 웨어하우스만큼 빠르면서도 Hive/MapReduce만큼 확장 가능한 "최고의 양쪽" 세계를 실현
- 현재: Apache Spark 2.x부터 SparkSession이 Spark에서 데이터를 조작하는 단일 통합 진입점 제공

### Spark SQL의 핵심 장점
- 성능 향상: 더 빠른 성능과 관계형 프로그래밍 지원
- 선언적 쿼리: 최적화된 스토리지와 선언적 쿼리 작성 가능
- 복합 분석: 복잡한 분석 라이브러리(머신러닝 등) 호출 가능
- 통합성: DataFrame API와 완벽한 상호 운용성

## Spark SQL UDF
### 기본 개념
Apache Spark의 풍부한 내장 함수에도 불구하고, 사용자 정의 함수(UDF)는 다음과 같은 독특한 가치를 제공함
- 도메인 특화 로직: 비즈니스 로직을 캡슐화하여 재사용 가능
- ML 모델 통합: 데이터 과학자가 ML 모델을 UDF로 래핑하면, 데이터 분석가가 모델 내부를 이해하지 않고도 예측 결과 쿼리 가능
- 세션 기반: UDF는 세션별로 작동하며 기본 메타스토어에 지속되지 않음

### 생성 예제
{{< tabs "id" >}}
{{% tab "Scala" %}}
```scala
// In Scala
// Create cubed function
val cubed = (s: Long) => {
  s * s * s
}

// Register UDF
spark.udf.register("cubed", cubed)

// Create temporary view
spark.range(1, 9).createOrReplaceTempView("udf_test")
```
{{% /tab %}}
{{% tab "Python" %}}
```py
# In Python
from pyspark.sql.types import LongType

# Create cubed function
def cubed(s):
  return s * s * s

# Register UDF
spark.udf.register("cubed", cubed, LongType())

# Generate temporary view
spark.range(1, 9).createOrReplaceTempView("udf_test")
```
{{% /tab %}}
{{< /tabs >}}