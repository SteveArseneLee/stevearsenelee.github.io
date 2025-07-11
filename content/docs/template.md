+++
draft = true
+++
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