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

### DataFrame의 열과 표현식
Column 객체의 특성
- DataFrame의 명명된 열은 pandas, R DataFrame, RDBMS 테이블의 열과 개념적으로 유사
- Column 타입으로 표현되는 공용 메서드를 가진 객체
- 논리적 또는 수학적 표현식 사용 가능

기본 Column 접근
```scala
// Scala에서 Column 접근
import org.apache.spark.sql.functions._

// 모든 컬럼명 조회
blogsDF.columns
// Array[String] = Array(Campaigns, First, Hits, Id, Last, Published, Url)

// 특정 컬럼 접근 - Column 타입 반환
blogsDF.col("Id")
// org.apache.spark.sql.Column = id
```

표현식을 사용한 계산
```scala
// expr() 함수를 사용한 표현식
blogsDF.select(expr("Hits * 2")).show(2)

// col() 함수를 사용한 동일한 계산
blogsDF.select(col("Hits") * 2).show(2)

+----------+
|(Hits * 2)|
+----------+
|      9070|
|     17816|
+----------+
```

조건부 표현식으로 새 컬럼 생성
```scala
// Big Hitters 컬럼 추가 - 조건부 표현식 사용
blogsDF.withColumn("Big Hitters", (expr("Hits > 10000"))).show()

+---+---------+-------+---+---------+-----+--------------------+-----------+
| Id|    First|   Last|Url|Published| Hits|           Campaigns|Big Hitters|
+---+---------+-------+---+---------+-----+--------------------+-----------+
|  1|    Jules|  Damji|...|1/4/2016 | 4535|[twitter, LinkedIn] |      false|
|  2|   Brooke|  Wenig|...|5/5/2018 | 8908|[twitter, LinkedIn] |      false|
|  3|    Denny|    Lee|...|6/7/2019 | 7659|[web, twitter, FB...|      false|
|  4|Tathagata|    Das|...|5/12/2018|10568|     [twitter, FB]  |       true|
|  5|    Matei|Zaharia|...|5/14/2014|40578|[web, twitter, FB...|       true|
|  6|  Reynold|    Xin|...|3/2/2015 |25568|[twitter, LinkedIn] |       true|
+---+---------+-------+---+---------+-----+--------------------+-----------+
```

Concatenation
```scala
// 여러 컬럼을 연결하여 새 컬럼 생성
blogsDF
  .withColumn("AuthorsId", (concat(expr("First"), expr("Last"), expr("Id"))))
  .select(col("AuthorsId"))
  .show(4)

+-------------+
|    AuthorsId|
+-------------+
|  JulesDamji1|
| BrookeWenig2|
|    DennyLee3|
|TathagataDas4|
+-------------+
```

동일한 결과를 얻는 다양한 방법
```scala
// 다음 세 방법은 모두 동일한 결과 반환
blogsDF.select(expr("Hits")).show(2)
blogsDF.select(col("Hits")).show(2)
blogsDF.select("Hits").show(2)

+-----+
| Hits|
+-----+
| 4535|
| 8908|
+-----+
```

정렬
```scala
// Id 컬럼 기준 내림차순 정렬 - 두 방법 모두 동일
blogsDF.sort(col("Id").desc).show()
blogsDF.sort($"Id".desc).show()  // $ 표기법 사용

+--------------------+---------+-----+---+-------+---------+-----------------+
|           Campaigns|    First| Hits| Id|   Last|Published|              Url|
+--------------------+---------+-----+---+-------+---------+-----------------+
|[twitter, LinkedIn] |  Reynold|25568|  6|    Xin|3/2/2015 |https://tinyurl.6|
|[web, twitter, FB...|    Matei|40578|  5|Zaharia|5/14/2014|https://tinyurl.5|
|     [twitter, FB]  |Tathagata|10568|  4|    Das|5/12/2018|https://tinyurl.4|
|[web, twitter, FB...|    Denny| 7659|  3|    Lee|6/7/2019 |https://tinyurl.3|
|[twitter, LinkedIn] |   Brooke| 8908|  2|  Wenig|5/5/2018 |https://tinyurl.2|
|[twitter, LinkedIn] |    Jules| 4535|  1|  Damji|1/4/2016 |https://tinyurl.1|
+--------------------+---------+-----+---+-------+---------+-----------------+
```



Row 객체틔 특성
- Spark의 일반적인 Row 객체로 하나 이상의 column 포함
- 각 컬럼은 동일한 데이터 타입이거나 서로 다른 타입 가능
- 인덱스 0부터 시작하는 순서가 있는 field collection

Scala에서 Row 사용
```scala
import org.apache.spark.sql.Row

// Row 생성
val blogRow = Row(6, "Reynold", "Xin", "https://tinyurl.6", 255568, "3/2/2015", 
  Array("twitter", "LinkedIn"))

// 인덱스를 사용한 개별 항목 접근
blogRow(1)
// res62: Any = Reynold
```

Python에서 Row 사용
```python
from pyspark.sql import Row

# Row 생성
blog_row = Row(6, "Reynold", "Xin", "https://tinyurl.6", 255568, "3/2/2015", 
  ["twitter", "LinkedIn"])

# 인덱스를 사용한 개별 항목 접근
blog_row[1]
# 'Reynold'
```

#### Row를 사용한 DataFrame 생성
빠른 탐색 및 상호작용을 위한 DataFrame 생성  
Python
```python
# Python에서 Row로 DataFrame 생성
rows = [Row("Matei Zaharia", "CA"), Row("Reynold Xin", "CA")]
authors_df = spark.createDataFrame(rows, ["Authors", "State"])
authors_df.show()
```

Scala
```scala
// Scala에서 Row로 DataFrame 생성
val rows = Seq(("Matei Zaharia", "CA"), ("Reynold Xin", "CA"))
val authorsDF = rows.toDF("Author", "State")
authorsDF.show()
```

결과
```diff
+-------------+-----+
|       Author|State|
+-------------+-----+
|Matei Zaharia|   CA|
|  Reynold Xin|   CA|
+-------------+-----+
```

{{% hint info %}}
실제 사용에서의 권장사항
- 실제로는 파일에서 DataFrame을 읽는 것이 일반적
- 대용량 파일의 경우 스키마를 정의하고 사용하는 것이 더 빠르고 효율적
{{% /hint %}}


---

## 일반적인 DataFrame 연산
DataFrameReader 특성
- 다양한 데이터 소스에서 DataFrame으로 데이터 읽기
- 지원 형식 : JSON, CSV, Parquet, Text, Avro, ORC 등
- 고수준 추상화로 읽기 작업 단순화

DataFrameWriter 특성
- DataFrame을 특정 형식으로 데이터 소스에 쓰원
- NoSQL 저장소, RDBMS, Kafka, Kinesis 등 지원

### DataFrame을 Parquet 파일 또는 SQL 테이블로 저장하기
Parquet 파일로 저장
```scala
// Scala - Parquet 파일로 저장
val parquetPath = ...
fireDF.write.format("parquet").save(parquetPath)
```

```python
# Python - Parquet 파일로 저장
parquet_path = ...
fire_df.write.format("parquet").save(parquet_path)
```

SQL 테이블로 저장
```scala
// Scala - 테이블로 저장 (Hive 메타스토어에 메타데이터 등록)
val parquetTable = ... // 테이블 이름
fireDF.write.format("parquet").saveAsTable(parquetTable)
```

```python
# Python - 테이블로 저장
parquet_table = ... # 테이블 이름
fire_df.write.format("parquet").saveAsTable(parquet_table)
```

{{% hint info %}}
Parquet 형식의 장점
- 기본 형식으로 snappy 압축 사용
- 스키마가 Parquet 메타데이터의 일부로 보존됨
- 후속 읽기 시 수동으로 스키마 제공할 필요 없음
{{% /hint %}}

### Transformation과 Action
#### Projection과 Filter
기본 개념
- Projection : 특정 관계 조건과 일치하는 행만 반환
- Spark에서 ```select()``` method로 projection 수행
- ```filter()``` 또는 ```where()``` method로 filter 표현

ex) 특정 호출 유형 제외하고 조회
```python
# Python - Medical Incident 제외한 데이터 조회
few_fire_df = (fire_df
  .select("IncidentNumber", "AvailableDtTm", "CallType")
  .where(col("CallType") != "Medical Incident"))
few_fire_df.show(5, truncate=False)
```

```scala
// Scala - 동일한 작업
val fewFireDF = fireDF
  .select("IncidentNumber", "AvailableDtTm", "CallType")
  .where($"CallType" =!= "Medical Incident")
fewFireDF.show(5, false)
```
결과
```vbnet
+--------------+----------------------+--------------+
|IncidentNumber|AvailableDtTm         |CallType      |
+--------------+----------------------+--------------+
|2003235       |01/11/2002 01:47:00 AM|Structure Fire|
|2003235       |01/11/2002 01:51:54 AM|Structure Fire|
|2003235       |01/11/2002 01:47:00 AM|Structure Fire|
|2003235       |01/11/2002 01:47:00 AM|Structure Fire|
|2003235       |01/11/2002 01:51:17 AM|Structure Fire|
+--------------+----------------------+--------------+
```

ex) 고유한 ```CallType``` 개수 조회
```python
# Python - countDistinct() 사용
from pyspark.sql.functions import *
(fire_df
  .select("CallType")
  .where(col("CallType").isNotNull())
  .agg(countDistinct("CallType").alias("DistinctCallTypes"))
  .show())
```

```scala
// Scala - 동일한 작업
import org.apache.spark.sql.functions._
fireDF.select("CallType")
  .where(col("CallType").isNotNull)
  .agg(countDistinct('CallType) as 'DistinctCallTypes)
  .show()
```

결과
```diff
+-----------------+
|DistinctCallTypes|
+-----------------+
|               32|
+-----------------+
```

고유한 유형 목록 조회
```python
# Python - distinct() 사용
(fire_df
  .select("CallType")
  .where(col("CallType").isNotNull())
  .distinct()
  .show(10, False))
```
```scala
fireDF
  .select("CallType")
  .where($"CallType".isNotNull())
  .distinct()
  .show(10, false)
```
결과
```sql
+-----------------------------------+
|CallType                           |
+-----------------------------------+
|Elevator / Escalator Rescue        |
|Marine Fire                        |
|Aircraft Emergency                 |
|Confined Space / Structure Collapse|
|Administrative                     |
|Alarms                            |
|Odor (Strange / Unknown)          |
|Lightning Strike (Investigation)   |
|Citizen Assist / Service Call     |
|HazMat                            |
+-----------------------------------+
```

### Column 이름 바꾸기, 추가, 삭제
컬럼 이름 변경의 필요성
- 스타일이나 규칙상의 이유
- 가독성이나 간결성을 위해
- 원본 데이터의 column name에 공백이 있는 경우 (Parquet 파일 저장 시 문제 발생)

#### WithColumnRenamed()
컬럼 이름 변경 및 조건 필터링
```python
# Python - Delay 컬럼을 ResponseDelayedinMins로 변경
new_fire_df = fire_df.withColumnRenamed("Delay", "ResponseDelayedinMins")
(new_fire_df
  .select("ResponseDelayedinMins")
  .where(col("ResponseDelayedinMins") > 5)
  .show(5, False))
```
```scala
// Scala - 동일한 작업
val newFireDF = fireDF.withColumnRenamed("Delay", "ResponseDelayedinMins")
newFireDF.select("ResponseDelayedinMins")
  .where($"ResponseDelayedinMins" > 5)
  .show(5, false)
```
결과
```diff
+---------------------+
|ResponseDelayedinMins|
+---------------------+
|5.233333             |
|6.9333334            |
|6.116667             |
|7.85                 |
|77.333336            |
+---------------------+
```

{{% hint info %}}
불변성 주의사항
- DataFrame 변환은 불변이므로 ```WithColumnRenamed()``` 사용 시 새로운 DataFrame이 생성되며, 원본은 기존 컬럼명을 유지함
{{% /hint %}}

---
## Dataset API
### Structured APIs
- DataFrame과 Dataset을 구조화된 API로 통합
- 단일 API 세트만 사용하면 됨
- typed API와 untyped API 특성 보유

언어별 지원 현황
언어 | 유형화된/비유형화된 주요 추상화 | 유형 여부
-|-|-
Scala | Dataset[T] 및 DataFrame (Dataset[Row]의 별칭) | 유형화 및 비유형화 모두
Java | Dataset<T> | 유형화
Python | DataFrame | 일반 Row 비유형화
R | DataFrame | 일반 Row 비유형화

#### 개념적 이해
- DataFrame (Scala): Dataset[Row]의 별칭, 여러 유형의 필드를 보유할 수 있는 일반적인 비유형화된 JVM 객체
- Dataset: 강력하게 유형화된 JVM 객체의 컬렉션 (Scala) 또는 Java의 클래스
- Row: Spark의 일반적인 객체 유형으로 인덱스를 사용하여 접근할 수 있는 혼합 유형의 컬렉션

{{% hint danger %}}
Dataset 정의 (공식 문서)

"함수형 또는 관계형 연산을 사용하여 병렬로 변환할 수 있는 도메인별 객체의 강력하게 유형화된 컬렉션. 각 Dataset[Scala]에는 DataFrame이라고 하는 비유형화된 뷰도 있으며, 이는 Row의 Dataset입니다."
{{% /hint %}}

### Dataset 생성
스키마 정의의 필요성
- DataFrame 생성과 마찬가지로 스키마를 알아야 함
- 데이터 유형을 미리 알고 있어야 함
- JSON, CSV 데이터에서 스키마 추론 가능하지만 대용량 데이터셋에서는 리소스 집약적