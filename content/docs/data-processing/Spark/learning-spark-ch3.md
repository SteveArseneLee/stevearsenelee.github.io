+++
title = "Learning Spark Ch.3"
draft = false
weight = 3
+++

## RDD
### RDD의 3가지 특징
- 종속성
    - RDD가 어떻게 구성되는지에 대한 입력 정보 제공
    - 결과 재현이 필요할 때 Spark가 RDD를 재생성하고 연산을 복제할 수 있게 함
    - 복원력(resiliency) 제공의 핵심
- 파티션(일부 지역성 정보와 포함)
    - 실행자(Executor) 간 병렬 처리를 위해 작업 분할
    - Locality Information 포함
    - HDFS 읽기 시 데이터에 가까운 실행자에게 작업 전송으로 네트워크 전송량 최소화
- Compute 함수
    - ```Partition => Iterator[T]``` 형태
    - RDD에 저장될 데이터를 생성하는 iterator 생성

### RDD 모델의 한계점
불투명성(Opacity) 문제
```python
# RDD의 불투명한 연산 - Spark가 의도를 파악할 수 없음
rdd.map(lambda x: some_complex_function(x))
```

주요 문제점들
1. 연산 함수의 불투명성 : Join, Filter, Select, Aggregation 모두 Lambda 표현식으로만 인식
2. 데이터 타입의 불투명성 : ```Iterator[T]```에서 T가 무엇인지 알 수 없음
3. 최적화 불가능 : 표현식의 의도를 이해할 수 없어서 최적화 불가함
4. 압축 기법 미적용: : 객체를 byte series로만 직렬화함

-> 효율적인 **query plan**으로 재배열할 수 있는 능력이 저해됨

---
## Spark 구조화
### 구조화 방식
1. 공통 패턴 표현
- 데이터 분석에서 발견되는 일반적인 패턴을 고수준 연산으로 표현
- Filtering, Selecting, Counting, Aggregating, Averaging, Grouping

2. DSL 연산자 활용
```python
# 다양한 언어에서 일관된 API 제공
# Java, Python, Scala, R, SQL 모두 지원
df.select("name").groupBy("name").avg("age")
```

3. 테이블 형태 데이터 구조
- SQL 테이블이나 spreadsheet와 유사한 구조
- 지원되는 구조화된 데이터 타입 활용

### 구조화의 핵심 이점
> 표현력과 조합성 비교

**RDD 방식 (복잡하고 불투명함)**
```python
# 이름별 나이 평균 계산 - RDD 방식
# 복잡한 Lambda 함수 체인으로 의도 파악 어려움
rdd.map(lambda x: (x.name, x.age)) \
   .groupByKey() \
   .mapValues(lambda ages: sum(ages) / len(ages))

## ============================
# Create an RDD of tuples (name, age)
dataRDD = sc.parallelize([("Brooke", 20), ("Denny", 31), ("Jules", 30), 
  ("TD", 35), ("Brooke", 25)])
# Use map and reduceByKey transformations with their lambda 
# expressions to aggregate and then compute average

agesRDD = (dataRDD
  .map(lambda x: (x[0], (x[1], 1)))
  .reduceByKey(lambda x, y: (x[0] + y[0], x[1] + y[1]))
  .map(lambda x: (x[0], x[1][0]/x[1][1])))
```

**DataFrame 방식(명확하고 표현적)**
Python
```python
# 동일한 작업 - DataFrame 방식
# 의도가 명확하고 Spark가 최적화 가능
df.groupBy("name").avg("age")

## ============================
from pyspark.sql import SparkSession
from pyspark.sql.functions import avg
# Create a DataFrame using SparkSession
spark = (SparkSession
  .builder
  .appName("AuthorsAges")
  .getOrCreate())
# Create a DataFrame 
data_df = spark.createDataFrame([("Brooke", 20), ("Denny", 31), ("Jules", 30), 
  ("TD", 35), ("Brooke", 25)], ["name", "age"])
# Group the same names together, aggregate their ages, and compute an average
avg_df = data_df.groupBy("name").agg(avg("age"))
# Show the results of the final execution
avg_df.show()

+------+--------+
|  name|avg(age)|
+------+--------+
|Brooke|    22.5|
| Jules|    30.0|
|    TD|    35.0|
| Denny|    31.0|
+------+--------+

```

Scala
```scala
import org.apache.spark.sql.functions.avg
import org.apache.spark.sql.SparkSession
// Create a DataFrame using SparkSession
val spark = SparkSession
  .builder
  .appName("AuthorsAges")
  .getOrCreate()
// Create a DataFrame of names and ages
val dataDF = spark.createDataFrame(Seq(("Brooke", 20), ("Brooke", 25), 
  ("Denny", 31), ("Jules", 30), ("TD", 35))).toDF("name", "age")
// Group the same names together, aggregate their ages, and compute an average
val avgDF = dataDF.groupBy("name").agg(avg("age"))
// Show the results of the final execution
avgDF.show()

+------+--------+
|  name|avg(age)|
+------+--------+
|Brooke|    22.5|
| Jules|    30.0|
|    TD|    35.0|
| Denny|    31.0|
+------+--------+
```
위 코드를 보면 Scala 코드와 Python 코드는 동일한 작업을 수행하며 API도 거의 동일함.
---
## DataFrame API
### 기본 개념
- pandas DataFrame의 구조와 형식에서에서 영감 받음
- 명명된 column과 schema를 가진 분산 in-memory table
- 인간의 눈에는 테이블로 보임

### 예시 구조
Id (Int) | First (String) | Last (String) | Url (String) | Published (Date)
-|-|-|-|-
1 | Jules | Damji | https://tinyurl.1 | 1/4/2016
2 | Brooke | Wenig | https://tinyurl.2 | 5/5/2018

### 핵심 특성
- 불변성 : 변환 시 새로운 DataFrame 생성, 기존 버전은 보존함
- 계보 추적 : 모든 변환의 lineage 유지
- 스키마 정의 : 컬럼명과 연관된 Spark 데이터 타입 선언 가능

---
## Spark 데이터 타입 체계
### 기본 데이터 타입 (Scala)
```scala
import org.apache.spark.sql.types._

val nameTypes = StringType
val firstName = nameTypes
val lastName = nameTypes
```

데이터 타입 | Scala에 할당된 값 | API 인스턴스화
-|-|-
ByteType | Byte | DataTypes.ByteType
ShortType | Short | DataTypes.ShortType
IntegerType | Int | DataTypes.IntegerType
LongType | Long | DataTypes.LongType
FloatType | Float | DataTypes.FloatType
StringType | String | DataTypes.StringType
BooleanType | Boolean | DataTypes.BooleanType
DecimalType | java.math.BigDecimal | DecimalType

### 기본 데이터 타입 (Python)
데이터 타입 | Scala에 할당된 값 | API 인스턴스화
-|-|-
ByteType | int | DataTypes.ByteType
ShortType | int | DataTypes.ShortType
IntegerType | int | DataTypes.IntegerType
LongType | int | DataTypes.LongType
FloatType | float | DataTypes.FloatType
DoubleType | float | DataTypes.DoubleType
StringType | str | DataTypes.StringType
BooleanType | bool | DataTypes.BooleanType
DecimalType | decimal.Decimal | DecimalType

### Structured and Complex Data Types
데이터 타입 | Scala에 할당된 값 | API 인스턴스화
-|-|-
BinaryType | Array[Byte] | DataTypes.BinaryType
TimestampType | java.sql.Timestamp | DataTypes.TimestampType
DateType | java.sql.Date | DataTypes.DateType
ArrayType | scala.collection.Seq | DataTypes.createArrayType(ElementType)
MapType | scala.collection.Map | DataTypes.createMapType(keyType, valueType)
StructType | org.apache.spark.sql.Row | StructType(ArrayType[fieldTypes])
StructField | 이 필드의 유형에 해당하는 값 유형 | StructField(name, dataType, [nullable])

---
## 스키마와 DataFrame 생성
### 스키마 사전 정의의 이점
> 1. 성능 향상 : Spark가 데이터 타입을 추론하는 부담 제거  
> 2. 리소스 절약 : 대용량 파일의 스키마 추론을 위한 별도 작업 방지  
> 3. 오류 조기 발견 : 데이터가 스키마와 일치하지 않을 때 조기 감지  

### 스키마 정의 방법
1. Programming 방식
```
// In Scala
import org.apache.spark.sql.types._
val schema = StructType(Array(StructField("author", StringType, false),
  StructField("title", StringType, false),
  StructField("pages", IntegerType, false)))

# In Python
from pyspark.sql.types import *
schema = StructType([StructField("author", StringType(), False),
  StructField("title", StringType(), False),
  StructField("pages", IntegerType(), False)])
```

```python
from pyspark.sql.types import *

schema = StructType([
    StructField("Id", IntegerType(), False),
    StructField("First", StringType(), False),
    StructField("Last", StringType(), False),
    StructField("Url", StringType(), False),
    StructField("Published", StringType(), False),
    StructField("Hits", IntegerType(), False),
    StructField("Campaigns", ArrayType(StringType()), False)
])
```

2. DDL 문자열 방식 (권장)
```scala
// In Scala
val schema = "author STRING, title STRING, pages INT"
```
```python
# In Python
schema = "author STRING, title STRING, pages INT"
```