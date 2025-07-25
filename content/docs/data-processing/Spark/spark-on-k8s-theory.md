+++
title = "Spark on K8s - 동작 원리"
draft = false
+++
{{% hint info %}}
Spark를 K8s 위에서 어떻게 "클러스터처럼" 실행하고 관리하는지에 대한 문서임. 특히 Spark Operator 기반의 동적 클러스터 생성 및 Job 수명주기에 Point
{{% /hint %}}


## Components
### Spark Operator (Control Plane)
- K8s 상에 상시 실행되는 control component
- 주요 Pod
    - spark-operator-controller : SparkApplication 리소스를 감시하고, Driver Pod 생성을 담당
    - spark-operator-webhook : SparkApplication 생성 시 validation 및 default 값 주입 수행
- 단일 복제본으로 충분하고, Job 실행 여부와는 무관하게 항상 떠있음
```sh
NAME                                         READY   STATUS    RESTARTS   AGE
spark-operator-controller-54bf455b67-d7mbm   1/1     Running   0          24d
spark-operator-webhook-7574fcdbf9-xcqpc      1/1     Running   0          24d
```

### SparkApplication (Job)
- CRD를 통해 정의되는 Spark Job
- 사용자가 제출하면, Spark Operator가 음음  다단계로 자동 처리
    1. Driver Pod 생성
    2. Driver 내부에서 Executor Pod 생성
    3. Job 종료 시 Driver 및 Executor Pod 삭제

```sh
NAME              READY   STATUS      RESTARTS   AGE
spark-pi-driver   0/1     Completed   0          24d
```

### Driver Pod
- SparkContext를 초기화하고 DAG를 스케쥴링하며 Executor를 관리
- Job이 끝나면 Completed 상태로 종료됨
```sh
NAME       STATUS      ATTEMPTS   START                  FINISH                 AGE
spark-pi   COMPLETED   1          2025-07-01T05:53:50Z   2025-07-01T05:55:25Z   24d
```

### Executor Pods
- 병렬 작업(Task)을 수행하는 실제 워커
- 수량은 executor.instances로 조절 가능
- Job 종료 시 자동 삭제(기본적으로 ```spark.kubernetes.executor.deleteOnTermination=true``` 설정)

## Spark Job (동적 클러스터)
Kubernetes에선 Spark Job 하나가 자체적으로 Driver+Executor 조합의 임시 클러스터로 동작
```sh
SparkApplication을 제출하면:
    → Driver Pod 1개 생성
    → Executor Pods N개 생성
    → Job 완료 시 모두 삭제
```
즉, 매 Job이 하나의 클러스터처럼 동작함

## 실행 흐름 요약
```sh
사용자: kubectl apply -f spark-job.yaml
       ↓
Spark Operator (Controller): SparkApplication 감지
       ↓
Driver Pod 생성 (SparkContext 초기화)
       ↓
Executor Pods 요청 및 생성
       ↓
Job 수행 → 완료 → Driver/Executors 모두 삭제
```

### SparkApplication 예시
```yaml
apiVersion: sparkoperator.k8s.io/v1beta2
kind: SparkApplication
metadata:
  name: my-job
  namespace: data-processing
spec:
  type: Python
  mode: cluster
  image: myrepo/spark:3.5.0
  mainApplicationFile: local:///opt/jobs/main.py
  sparkVersion: 3.5.0
  driver:
    cores: 1
    memory: "2g"
    serviceAccount: spark
  executor:
    cores: 2
    instances: 3
    memory: "4g"
```

## 클러스터 생성 조건 (user가 지정할 항목)
항목 | 설명
-|-
executor.instances | Executor Pod 수 조정
driver.memory, executor.memory | Pod 자원 설정
nodeSelector, tolerations | 노드 배치 제어 옵션
restartPolicy | 실패 시 재시도 여부 설정
spark.kubernetes.executor.deleteOnTermination | Job 종료 후 Executor 삭제 여부 (기본 : true)

## 결론
- Kubernetes에서 Spark는 상시 클러스터 방식이 아니라, Job 단위의 동적 클러스터 생성 방식으로 운영됨
- Spark Operator는 Control Plane으로서 항상 실행되고, 사용자가 SparkApplication을 제출하면, Driver + Executor가 클러스터처럼 자동 생성되며 Job 종료 시 자동으로 정리됨