+++
title = "하나의 operator와 여러 namespace의 여러 kafka cluster"
draft = false
+++

### 상황
> Strimzi Kafka Operator를 하나만 설치한 뒤, 여러 namespace에 Kafka 클러스터를 각각 배포하려는 구조로 운영하고자 했음.
> - Operator는 kafka 네임스페이스에 설치됨
> - 새 Kafka 클러스터는 kafka2 네임스페이스에 배포됨
> - KafkaNodePool + Kafka CR (KRaft 모드) 사용
> - Kafka UI도 네임스페이스별로 함께 배포

### 문제 원인
KafkaNodePool 기반 배포를 시도했을 때 다음과 같은 오류가 발생:
1. KafkaNodePool이 Kafka 리소스와 연결되지 않음
2. strimzipodsets 리소스 접근 실패 (list/create 권한 없음)
3. Kafka 및 KafkaNodePool의 status 필드 업데이트 실패 (403 Forbidden)

이유는 다음과 같음:
1. ClusterRole ```strimzi-cluster-operator-namespaced```가 기본적으로 kafka2의 리소스에 대한 권한을 가지지 않음
2. kafka2 네임스페이스에는 RoleBinding만 생성되어 있고, ClusterRole에는 필요한 리소스 권한이 빠져 있음
3. Kafka와 KafkaNodePool의 이름 불일치로 연결 실패

### 해결 방법
다음과 같은 조치를 통해 문제를 해결함:
1. ```KafkaNodePool.labels.strimzi.io/cluster``` 값과 ```Kafka.metadata.name``` 값을 일치시킴
2. ```ClusterRole(strimzi-cluster-operator-namespaced)```에 다음 권한을 추가:

```json
- apiGroups: ["kafka.strimzi.io"]
  resources: ["kafkas/status"]
  verbs: ["update"]

- apiGroups: ["kafka.strimzi.io"]
  resources: ["kafkanodepools/status"]
  verbs: ["update"]

- apiGroups: ["core.strimzi.io"]
  resources: ["strimzipodsets"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
```

```sh
kubectl patch clusterrole strimzi-cluster-operator-namespaced --type='json' -p='[
  {
    "op": "add",
    "path": "/rules/-",
    "value": {
      "apiGroups": ["kafka.strimzi.io"],
      "resources": ["kafkas/status"],
      "verbs": ["update"]
    }
  },
  {
    "op": "add",
    "path": "/rules/-",
    "value": {
      "apiGroups": ["kafka.strimzi.io"],
      "resources": ["kafkanodepools/status"],
      "verbs": ["update"]
    }
  },
  {
    "op": "add",
    "path": "/rules/-",
    "value": {
      "apiGroups": ["core.strimzi.io"],
      "resources": ["strimzipodsets"],
      "verbs": ["get", "list", "watch", "create", "update", "patch", "delete"]
    }
  }
]
```
3. kafka 네임스페이스의 strimzi-cluster-operator 서비스 계정이 kafka2 네임스페이스 리소스에 접근할 수 있도록 RoleBinding 구성:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: strimzi-cluster-operator-binding
  namespace: kafka2
subjects:
  - kind: ServiceAccount
    name: strimzi-cluster-operator
    namespace: kafka
roleRef:
  kind: ClusterRole
  name: strimzi-cluster-operator-namespaced
  apiGroup: rbac.authorization.k8s.io
```

4. STRIMZI_NAMESPACE 환경변수에 kafka2 추가
```sh
kubectl set env deployment/strimzi-cluster-operator -n kafka STRIMZI_NAMESPACE="kafka,kafka2"
```


---
### 요약된 스크립트
<details markdown="1">
  <summary>install-kafka-on-new-ns.sh</summary>

```yaml
#!/bin/bash

set -e

# 기존 Operator 네임스페이스
OPERATOR_NS="kafka"
# 새로 배포할 네임스페이스
TARGET_NS="$1"
# Kafka 클러스터 이름
KAFKA_CLUSTER="$2"
# Kafka UI 정보
KAFKA_UI_DEPLOYMENT="kafka-ui-${KAFKA_CLUSTER}"
KAFKA_UI_SERVICE="kafka-ui-${KAFKA_CLUSTER}"
KAFKA_UI_PORT=30640
KAFKA_TIMEOUT=300s
UI_TIMEOUT=60s

if [[ -z "$TARGET_NS" || -z "$KAFKA_CLUSTER" ]]; then
  echo "[ERROR] Usage: $0 <target-namespace> <kafka-cluster-name>"
  exit 1
fi

echo "🚀 Deploying Kafka cluster '${KAFKA_CLUSTER}' in namespace '${TARGET_NS}'..."

### [1] 네임스페이스 생성 ###
kubectl get namespace ${TARGET_NS} > /dev/null 2>&1 || kubectl create namespace ${TARGET_NS}

### [2] 기존 STRIMZI_NAMESPACE 환경변수에 target NS 추가 ###
CURRENT_NAMESPACES=$(kubectl get deployment strimzi-cluster-operator -n ${OPERATOR_NS} -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="STRIMZI_NAMESPACE")].value}')
if [[ "$CURRENT_NAMESPACES" != *"$TARGET_NS"* ]]; then
  echo "🔧 Adding ${TARGET_NS} to STRIMZI_NAMESPACE"
  kubectl set env deployment/strimzi-cluster-operator -n ${OPERATOR_NS} STRIMZI_NAMESPACE="${CURRENT_NAMESPACES},${TARGET_NS}"
else
  echo "✅ STRIMZI_NAMESPACE already includes ${TARGET_NS}"
fi

### [3] 기존 ClusterRoleBinding 규칙 확인 및 복사 적용 ###
echo "🔑 Creating RoleBindings from existing ones in ${OPERATOR_NS}"
for role in strimzi-cluster-operator-namespaced strimzi-entity-operator strimzi-kafka-broker; do
  kubectl create rolebinding strimzi-${role}-binding \
    --namespace ${TARGET_NS} \
    --clusterrole ${role} \
    --serviceaccount ${OPERATOR_NS}:strimzi-cluster-operator \
    --dry-run=client -o yaml | kubectl apply -f -
done

### [4] Kafka 클러스터 배포 ###
cat <<EOF | kubectl apply -f -
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaNodePool
metadata:
  name: dual-role
  namespace: ${TARGET_NS}
  labels:
    strimzi.io/cluster: ${KAFKA_CLUSTER}
spec:
  replicas: 3
  roles:
    - controller
    - broker
  storage:
    type: jbod
    volumes:
      - id: 0
        type: persistent-claim
        size: 100Gi
        deleteClaim: false
        class: nfs-client
---
apiVersion: kafka.strimzi.io/v1beta2
kind: Kafka
metadata:
  name: ${KAFKA_CLUSTER}
  namespace: ${TARGET_NS}
  annotations:
    strimzi.io/node-pools: enabled
    strimzi.io/kraft: enabled
spec:
  kafka:
    version: 3.7.0
    metadataVersion: 3.7-IV4
    replicas: 3
    listeners:
      - name: plain
        port: 9092
        type: internal
        tls: false
      - name: tls
        port: 9093
        type: internal
        tls: true
      - name: external
        port: 9094
        type: nodeport
        tls: false
        configuration:
          bootstrap:
            nodePort: 31000
          brokers:
          - broker: 0
            nodePort: 31001
          - broker: 1
            nodePort: 31002
          - broker: 2
            nodePort: 31003
    config:
      offsets.topic.replication.factor: 3
      transaction.state.log.replication.factor: 3
      transaction.state.log.min.isr: 2
      default.replication.factor: 3
      min.insync.replicas: 2
  entityOperator:
    topicOperator: {}
    userOperator: {}
  kafkaExporter:
    groupRegex: ".*"
    topicRegex: ".*"
EOF

### [5] Kafka 준비 대기 ###
echo "⏳ Waiting for Kafka cluster to be ready..."
kubectl wait --for=condition=ready kafka/${KAFKA_CLUSTER} -n ${TARGET_NS} --timeout=${KAFKA_TIMEOUT} || echo "⚠️ Kafka cluster wait timed out."

### [6] Kafka UI 배포 ###
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${KAFKA_UI_DEPLOYMENT}
  namespace: ${TARGET_NS}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${KAFKA_UI_DEPLOYMENT}
  template:
    metadata:
      labels:
        app: ${KAFKA_UI_DEPLOYMENT}
    spec:
      containers:
      - name: kafka-ui
        image: provectuslabs/kafka-ui:latest
        ports:
        - containerPort: 8080
        env:
        - name: KAFKA_CLUSTERS_0_NAME
          value: "${KAFKA_CLUSTER}"
        - name: KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS
          value: "${KAFKA_CLUSTER}-kafka-bootstrap.${TARGET_NS}:9092"
---
apiVersion: v1
kind: Service
metadata:
  name: ${KAFKA_UI_SERVICE}
  namespace: ${TARGET_NS}
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 8080
    nodePort: ${KAFKA_UI_PORT}
  selector:
    app: ${KAFKA_UI_DEPLOYMENT}
EOF

### [7] Kafka UI 준비 대기 및 접속 정보 출력 ###
kubectl wait --for=condition=ready pod -l app=${KAFKA_UI_DEPLOYMENT} -n ${TARGET_NS} --timeout=${UI_TIMEOUT} || echo "⚠️ Kafka UI wait timed out."
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
echo "============================================================"
echo "✅ Kafka cluster '${KAFKA_CLUSTER}' deployed in '${TARGET_NS}'"
echo "🌐 Kafka UI URL: http://$NODE_IP:$KAFKA_UI_PORT"
echo "============================================================"

```
</details>

위 스크립트는 ```./install-kafka-on-new-ns.sh kafka-new-ns new-kafka-cluster-name```처럼 사용하면 된다.
