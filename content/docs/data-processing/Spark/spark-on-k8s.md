+++
title = "Spark on Kubernetes"
draft = false
weight = 0
+++

### Spark Operator 설치
```sh
# Add the Helm repo
helm repo add --force-update spark-operator https://kubeflow.github.io/spark-operator

helm repo update

k create ns spark-system
k create ns data-processing
```

spark-values.yaml
```yaml
spark:
  jobNamespaces:
    - data-processing

webhook:
  enable: true

metrics:
  enable: true
```

이후
```sh
helm install spark-operator spark-operator/spark-operator \
  --namespace spark-system \
  --create-namespace \
  --wait \
  -f spark-values.yaml

# 올바른 SparkJobNamespace를 보는지 확인
kubectl logs deploy/spark-operator-controller -n spark-system | grep -- --namespaces
```

### [Sample] SparkApplication 실행

```yaml
piVersion: sparkoperator.k8s.io/v1beta2
kind: SparkApplication
metadata:
  name: spark-pi
spec:
  type: Scala
  mode: cluster
  image: spark:3.5.5
  imagePullPolicy: IfNotPresent
  mainClass: org.apache.spark.examples.SparkPi
  mainApplicationFile: local:///opt/spark/examples/jars/spark-examples.jar
  arguments:
  - "5000"
  sparkVersion: 3.5.5
  driver:
    labels:
      version: 3.5.5
    cores: 1
    memory: 512m
    serviceAccount: spark-operator-spark
    securityContext:
      capabilities:
        drop:
        - ALL
      runAsGroup: 185
      runAsUser: 185
      runAsNonRoot: true
      allowPrivilegeEscalation: false
      seccompProfile:
        type: RuntimeDefault
  executor:
    labels:
      version: 3.5.5
    instances: 1
    cores: 1
    memory: 512m
    securityContext:
      capabilities:
        drop:
        - ALL
      runAsGroup: 185
      runAsUser: 185
      runAsNonRoot: true
      allowPrivilegeEscalation: false
      seccompProfile:
        type: RuntimeDefault
```

확인해보기
```sh
kubectl get sparkapp -n data-processing
kubectl describe sparkapp spark-pi -n data-processing
```

정상이라면 다음과 같이 나옴
```sh
spark-pi-driver       Running
spark-pi-<executor>   Running
```

위 설치를 통해 사용하는 명령어는
```sh
kubectl get sparkapplications.sparkoperator.k8s.io
kubectl get scheduledsparkapplications.sparkoperator.k8s.io
```
임