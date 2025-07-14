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


Spark SQL로 이 두 함수 중 하나를 실행 가능
```
// In Scala/Python
// Query the cubed UDF
spark.sql("SELECT id, cubed(id) AS id_cubed FROM udf_test").show()

+---+--------+
| id|id_cubed|
+---+--------+
|  1|       1|
|  2|       8|
|  3|      27|
|  4|      64|
|  5|     125|
|  6|     216|
|  7|     343|
|  8|     512|
+---+--------+
```

### 평가 순서 및 Null 처리
Spark SQL은 하위 표현식의 평가 순서를 보장하지 않음.
```sql
spark.sql("SELECT s FROM test1 WHERE s IS NOT NULL AND strlen(s) > 1")
```

안전한 Null 처리 전략
1. UDF 내부 Null 처리
  ```py
  def safe_strlen(s):
    if s is None:
        return 0
    return len(s)
  ```
2. 조건부 분기 사용
  ```sql
  SELECT s FROM table 
  WHERE CASE 
      WHEN s IS NOT NULL THEN strlen(s) > 1 
      ELSE FALSE 
  END
  ```

## Pandas UDF
### 성능 문제의 근본 원인
기존 PySpark UDF의 성능 문제
1. JVM-Python 간 데이터 이동: 매우 비싼 직렬화/역직렬화 과정
2. 행 단위 처리: 개별 행을 하나씩 처리하는 비효율성
3. 피클링 오버헤드: Python 객체의 직렬화 비용
### Pandas UDF의 혁신적 해결책
Apache Spark 2.3의 도입:
- Apache Arrow 활용: 효율적인 컬럼형 데이터 전송
- 벡터화된 실행: Pandas Series/DataFrame 단위로 처리
- 직렬화 제거: Arrow 형식으로 직접 처리 가능

성능 개선 효과:
- 기존 PySpark UDF 대비 5-100배 성능 향상 사례 다수
- 메모리 사용량 최적화
- CPU 효율성 대폭 개선

## Spark 3.0의 Scala Pandas UDF
### 1. Pandas UDF 개선 사항
```py
# Python 타입 힌트를 사용한 자동 타입 추론
import pandas as pd
from pyspark.sql.functions import pandas_udf

@pandas_udf(returnType="long")
def cubed(s: pd.Series) -> pd.Series:
    return s * s * s
```
지원되는 타입 힌트 패턴:
1. Series to Series
2. Iterator of Series to Iterator of Series
3. Iterator of Multiple Series to Iterator of Series
4. Series to Scalar (단일 값)

### 2. Pandas Function API
```py
# 로컬 Python 함수를 직접 적용
def pandas_plus_one(iterator):
    for pdf in iterator:
        yield pdf + 1

df.mapInPandas(pandas_plus_one, schema="id long, value long").show()
```
지원되는 Function API:
- Grouped Map: 그룹별 데이터 처리
- Map: 전체 DataFrame 변환
- Co-grouped Map: 두 DataFrame 조인 후 처리

### 성능 벤치마크 예제
```py
# 성능 비교 예제
import pandas as pd
import time
from pyspark.sql.functions import pandas_udf, udf
from pyspark.sql.types import LongType

# 기존 UDF
def traditional_cubed(x):
    return x * x * x

traditional_udf = udf(traditional_cubed, LongType())

# Pandas UDF
@pandas_udf(returnType=LongType())
def pandas_cubed(s: pd.Series) -> pd.Series:
    return s * s * s

# 대용량 데이터로 성능 테스트
large_df = spark.range(1, 10000000)

# 기존 UDF 실행 시간 측정
start_time = time.time()
large_df.select(traditional_udf("id")).count()
traditional_time = time.time() - start_time

# Pandas UDF 실행 시간 측정  
start_time = time.time()
large_df.select(pandas_cubed("id")).count()
pandas_time = time.time() - start_time

print(f"성능 개선: {traditional_time / pandas_time:.2f}배")
```

# 외부 연동
## Spark SQL Shell 활용
기본 설정 및 시작
```sh
# Spark SQL Shell 시작
$SPARK_HOME/bin/spark-sql

# 또는 특정 설정과 함께 시작
$SPARK_HOME/bin/spark-sql \
  --conf spark.sql.warehouse.dir=/path/to/warehouse \
  --conf spark.sql.catalogImplementation=hive
```

테이블 생성 및 관리
```sql
-- 영구 테이블 생성
CREATE TABLE employees (
    id BIGINT,
    name STRING,
    department STRING,
    salary DOUBLE,
    hire_date DATE
) USING DELTA
LOCATION '/data/employees';

-- 파티션된 테이블 생성
CREATE TABLE sales (
    transaction_id STRING,
    product_id STRING,
    amount DOUBLE,
    sale_date DATE
) USING DELTA
PARTITIONED BY (sale_date)
LOCATION '/data/sales';
```

데이터 조작 및 쿼리
```sql
-- 배치 데이터 삽입
INSERT INTO employees VALUES 
    (1, 'Alice', 'Engineering', 95000, '2023-01-15'),
    (2, 'Bob', 'Marketing', 75000, '2023-02-01'),
    (3, 'Charlie', 'Engineering', 105000, '2023-01-20');

-- 복잡한 분석 쿼리
SELECT 
    department,
    COUNT(*) as employee_count,
    AVG(salary) as avg_salary,
    MAX(salary) as max_salary,
    MIN(hire_date) as earliest_hire
FROM employees 
GROUP BY department
HAVING COUNT(*) > 1
ORDER BY avg_salary DESC;
```

## JDBC 연결
```sh
# JDBC 드라이버와 함께 Spark 시작
$SPARK_HOME/bin/spark-shell \
  --driver-class-path /path/to/postgresql-42.3.1.jar \
  --jars /path/to/postgresql-42.3.1.jar
```

핵심 연결 속성
속성명 | 설명 | 예제
-|-|-
url | JDBC 연결 URL | jdbc:postgresql://localhost:5432/mydb
dbtable | 대상 테이블 또는 서브쿼리 | employees 또는 (SELECT * FROM emp WHERE active=1) as t
user, password | 인증 정보 | username, secretpassword
driver | JDBC 드라이버 클래스 | org.postgresql.Driver
fetchsize | 한 번에 가져올 행 수 | 10000
queryTimeout | 쿼리 타임아웃 (초) | 300

### 파티셔닝 전략 - 성능 최적화의 핵심
> 파티셔닝이 중요한 이유  
> 대용량 데이터 전송 시 단일 드라이버 연결을 통한 데이터 이동은 다음과 같은 문제를 야기함:

1. 병목 현상: 모든 데이터가 하나의 연결을 통과
2. 소스 시스템 부하: 데이터베이스 서버에 과도한 부하
3. 메모리 부족: 대용량 데이터의 단일 파티션 처리 시 OOM 발생 가능

핵심 파티셔닝 속성
속성명 | 설명 | 권장사항
-|-|-
numPartitions | 생성할 파티션 수 | Spark 워커 수의 2-4배
partitionColumn | 파티션 기준 컬럼 | 균등 분포된 숫자/날짜 컬럼
lowerBound | 파티션 컬럼 최솟값 | 실제 데이터의 최솟값
upperBound | 파티션 컬럼 최댓값 | 실제 데이터의 최댓값

### 파티셔닝 예제
Scenario : 1억 건의 주문 데이터 (order_id : 1 ~ 100,000,000)
```py
# 잘못된 파티셔닝 설정
df_bad = spark.read \
    .format("jdbc") \
    .option("url", "jdbc:postgresql://localhost:5432/ecommerce") \
    .option("dbtable", "orders") \
    .option("user", "username") \
    .option("password", "password") \
    .option("numPartitions", "10") \
    .option("partitionColumn", "order_id") \
    .option("lowerBound", "1") \
    .option("upperBound", "1000")  # 잘못됨: 실제 최댓값과 다름
    .load()

# 올바른 파티셔닝 설정
df_good = spark.read \
    .format("jdbc") \
    .option("url", "jdbc:postgresql://localhost:5432/ecommerce") \
    .option("dbtable", "orders") \
    .option("user", "username") \
    .option("password", "password") \
    .option("numPartitions", "20") \
    .option("partitionColumn", "order_id") \
    .option("lowerBound", "1") \
    .option("upperBound", "100000000") \
    .option("fetchsize", "50000") \
    .load()
```
결과적 쿼리 분석
```sql
-- 파티션 1
SELECT * FROM orders WHERE order_id >= 1 AND order_id < 5000001

-- 파티션 2  
SELECT * FROM orders WHERE order_id >= 5000001 AND order_id < 10000001

-- ... (총 20개 파티션)

-- 파티션 20
SELECT * FROM orders WHERE order_id >= 95000001 AND order_id <= 100000000
```

### 고급 파티셔닝 전략
1. 날짜 기반 파티셔닝
```py
# 날짜 컬럼을 숫자로 변환하여 파티셔닝
df = spark.read \
    .format("jdbc") \
    .option("url", jdbc_url) \
    .option("dbtable", """
        (SELECT *, 
         EXTRACT(EPOCH FROM order_date)::bigint as date_epoch 
         FROM orders 
         WHERE order_date >= '2023-01-01') as t
    """) \
    .option("partitionColumn", "date_epoch") \
    .option("lowerBound", "1672531200")  # 2023-01-01 epoch
    .option("upperBound", "1704067200")  # 2024-01-01 epoch  
    .option("numPartitions", "12") \
    .load()
```
2. 해시 기반 파티셔닝
```py
# 문자열 컬럼을 해시값으로 변환하여 균등 분산
df = spark.read \
    .format("jdbc") \
    .option("url", jdbc_url) \
    .option("dbtable", """
        (SELECT *, 
         ABS(HASHTEXT(customer_id)) % 1000000 as customer_hash
         FROM customer_orders) as t
    """) \
    .option("partitionColumn", "customer_hash") \
    .option("lowerBound", "0") \
    .option("upperBound", "999999") \
    .option("numPartitions", "50") \
    .load()
```