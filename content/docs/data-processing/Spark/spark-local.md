+++
title = "Local에 Spark 설치하기"
draft = false
weight = 0
+++
## 1. Spark 다운로드
로컬에 spark를 설치한다.

그전에 다음과 같은 전제 조건을 확인해본다.
> Spark runs on Java 17/21, Scala 2.13, Python 3.9+, and R 3.5+ (Deprecated). When using the Scala API, it is necessary for applications to use the same version of Scala that Spark was compiled for. Since Spark 4.0.0, it’s Scala 2.13.

Python 3.9+와 Java 17 or 21을 설치해야함.

```sh
wget https://dlcdn.apache.org/spark/spark-4.0.0/spark-4.0.0-bin-hadoop3.tgz

# 압축 해제 및 이동
tar -xzf spark-4.0.0-bin-hadoop3.tgz
sudo mv spark-4.0.0-bin-hadoop3 /opt/spark

# 환경변수 설정
export SPARK_HOME=/opt/spark
export PATH=$SPARK_HOME/bin:$PATH
export PYSPARK_PYTHON=python3  # PySpark가 사용할 Python

source ~/.zshrc
```

## 2. Python 환경(PySpark + Jupyter) 구성
### 패키지 설치
```sh
# Python 가상환경 만들기
python3 -m venv ~/venvs/spark-env
source ~/venvs/spark-env/bin/activate

# 패키지 설치
pip install jupyter pandas numpy matplotlib seaborn
```
> Pyspark는 Spark 4.0 압축 파일 내부에 이미 포함되어 있어서 따로 설치할 필요가 없다고 함


### Jupyter 실행 및 PySpark 실행
jupyter 실행
```sh
juypter lab
```

PySpark 실행 (example)
```python
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("TestSpark4") \
    .master("local[*]") \
    .getOrCreate()

df = spark.range(10)
df.show()
spark.stop()
```

## 3. Java 설치
```sh
brew install openjdk@21

echo 'export JAVA_HOME="/opt/homebrew/opt/openjdk@21"' >> ~/.zshrc
echo 'export PATH="$JAVA_HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

java --version
```