+++
title = "Learning Spark Ch.4"
draft = false
weight = 4
+++
## Spark SQL 개요
- Spark SQL은 Apache Spark의 핵심 구성 요소로, 구조화된 데이터 처리를 위한 통합 엔진 제공
- DataFrame과 Dataset API의 기반이 되며, 다양한 데이터 소스와의 상호 운용성 제공

### Spark SQL의 주요 기능
1. 고수준 Structured API 지원: DataFrame과 Dataset API의 기반 엔진
2. 다양한 데이터 형식 지원: JSON, Hive 테이블, Parquet, Avro, ORC, CSV 등
3. 외부 시스템 연동: JDBC/ODBC를 통한 BI 도구 및 RDBMS 연결
4. 프로그래밍 인터페이스: 데이터베이스의 테이블/뷰와 상호작용
5. 대화형 SQL 셸: 구조화된 데이터에 대한 SQL 쿼리 실행
6. 표준 SQL 지원: ANSI SQL:2003 호환 명령 및 HiveQL 지원

![alt text](data-processing/spark/spark-sql-connectors-and-data-sources.png)

## SparkSession을 통한 Spark SQL 활용
### SparkSession 생성 및 기본 사용법
- ```SparkSession```을 사용해 Spark 기능에 액세스 할 수 있음. class를 가져오고 인스턴스를 만들기
- SQL 쿼리를 실행하려면 SparkSession 인스턴스의 spark 메서드를 사용하면 됨
- 실행된 spark.sql 쿼리는 DataFrame을 반환하며, 이를 사용해 추가적인 작업 수행 가능

```scala
// Scala
import org.apache.spark.sql.SparkSession

val spark = SparkSession
  .builder
  .appName("SparkSQLExampleApp")
  .getOrCreate()
```

```python
# Python
from pyspark.sql import SparkSession

spark = (SparkSession
  .builder
  .appName("SparkSQLExampleApp")
  .getOrCreate())
```

### Schema 명시적 정의 (DDL 형식)
```scala
// Scala - DDL 형식
val schema = "date STRING, delay INT, distance INT, origin STRING, destination STRING"
```

```python
# Python - DDL 형식
schema = "`date` STRING, `delay` INT, `distance` INT, `origin` STRING, `destination` STRING"
```