+++
title = "Ceph 구축하기 - 요약본"
draft = false
+++

### 1. Rook Operator 배포
```sh
# 공식 Helm 차트로 설치
helm repo add rook-release https://charts.rook.io/release
helm repo update

# 네임스페이스 생성
kubectl create ns rook-ceph

# Operator 설치
helm install rook-ceph rook-release/rook-ceph --namespace rook-ceph
```

### 2. CephCluster 리소스 배포
<details markdown="1">
  <summary>ceph-cluster.yaml</summary>

```yaml
apiVersion: ceph.rook.io/v1
kind: CephCluster
metadata:
  name: rook-ceph
  namespace: rook-ceph
spec:
  cephVersion:
    image: quay.io/ceph/ceph:v18.2.2
    allowUnsupported: false
  dataDirHostPath: /var/lib/rook

  mon:
    count: 3
    allowMultiplePerNode: false

  mgr:
    count: 1
    allowMultiplePerNode: false

  dashboard:
    enabled: true
    ssl: false

  crashCollector:
    disable: true

  logCollector:
    enabled: true
    periodicity: daily
    maxLogSize: 500M

  storage:
    useAllNodes: true
    useAllDevices: false
    deviceFilter: "vdb"
    config:
      osdsPerDevice: "1"

  disruptionManagement:
    managePodBudgets: true
    osdMaintenanceTimeout: 30

  priorityClassNames:
    mon: system-node-critical
    osd: system-node-critical
    mgr: system-cluster-critical

  healthCheck:
    daemonHealth:
      mon:
        disabled: false
        interval: 45s
      osd:
        disabled: false
        interval: 60s
      status:
        disabled: false
        interval: 60s

  resources:  # 🔧 각 데몬별 리소스 제한
    mgr:
      limits:
        cpu: "250m"
        memory: "256Mi"
      requests:
        cpu: "100m"
        memory: "128Mi"
    mon:
      limits:
        cpu: "500m"
        memory: "512Mi"
      requests:
        cpu: "250m"
        memory: "256Mi"
    osd:
      limits:
        cpu: "1000m"
        memory: "2Gi"
      requests:
        cpu: "500m"
        memory: "1Gi"

```
</details>

```k apply -f ceph-cluster.yaml```를 실행해 리소스를 배포한다.
- mon, mgr, osd 개수와 설정
- deviceFilter로 사용할 디스크 선택 (vdb 등)
- 리소스 제한
- health check, priority 설정 등

### 3. RBD를 위한 CephBlockPool & StorageClasss 구성
CephBlockPool.yaml
```yaml
apiVersion: ceph.rook.io/v1
kind: CephBlockPool
metadata:
  name: replicapool
  namespace: rook-ceph
spec:
  failureDomain: host
  replicated:
    size: 3
```

StorageClass.yaml
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: rook-ceph-block
provisioner: rook-ceph.rbd.csi.ceph.com
parameters:
  clusterID: rook-ceph
  pool: replicapool
  imageFormat: "2"
  imageFeatures: layering
  csi.storage.k8s.io/provisioner-secret-name: rook-csi-rbd-provisioner
  csi.storage.k8s.io/provisioner-secret-namespace: rook-ceph
  csi.storage.k8s.io/node-stage-secret-name: rook-csi-rbd-node
  csi.storage.k8s.io/node-stage-secret-namespace: rook-ceph
reclaimPolicy: Delete
allowVolumeExpansion: true
mountOptions:
  - discard
```
위 sc를 기준으로 pvc를 생성하면 자동으로 RBD 볼륨이 생성됨.
