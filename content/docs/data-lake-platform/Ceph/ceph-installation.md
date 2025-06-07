+++
title = "Ceph 개요 및 구축하기"
draft = false
bookHidden = true
+++
## Ceph이란?
> 완전히 분산되고, 확장성과 고가용성을 지향하는 storage platform

핵심 목표
- 단일 클러스터에서 Object Storage, Block Storage, File System 모두 제공
- 분산성, Self-Healing, 무중단 확장을 기본 설계 철학으로 둠
- 하드웨어에 종속되지 않고 x86 서버 + disk 조합으로 대규모 스토리지 시스템 구축 가능

주요 특징
- CRUSH 알고리즘(Controlled Replication Under Scalable Hashing) 기반 분산 데이터 맵핑.
- 별도의 중앙 메타데이터 서버 없이 데이터 위치 결정 (Object Storage).
- 장애 발생 시 자동 복구(Self Healing).
- 수평 확장(linear scalability) 가능 (노드 추가만으로 확장).
- 다양한 인터페이스 제공: S3 호환(Object), RBD(Block), CephFS(File System).

---

### Ceph의 구성요소
|컴포넌트|설명|
|-|-|
|MON (Monitor)|Ceph 클러스터의 맵 관리와 Quorum(합의)을 담당.<br>- 모든 클러스터 상태(MAP) 저장<br>- 3개 이상 추천 (항상 홀수)|
|MGR (Manager)|Ceph의 상태 모니터링, 모듈 관리 담당.<br>- 대시보드, 모니터링 통합, Prometheus Exporter 제공<br>- 1 active + 1 standby 형태로 구성 추천|
|OSD (Object Storage Daemon)|실제 데이터 저장.<br>- 물리 디스크 하나당 1 OSD 프로세스<br>- Ceph Pool 복제(replication), 데이터 복구, 리밸런싱 담당|
|MDS (Metadata Server)|CephFS(파일시스템) 메타데이터 관리.<br>- 블록/오브젝트는 필요 없음. CephFS 쓸 때만 필요|
|RGW (Rados Gateway)|S3, Swift API를 제공하는 게이트웨이.<br>- 오브젝트 스토리지 접속용 서비스|
|CSI Driver|Kubernetes PVC를 Ceph RBD, CephFS와 연결하는 역할.<br>- Rook Operator가 자동으로 설치|

|저장 방식 | 필요한 컴포넌트|
|-|-|
|Block Storage (RBD) | MON, MGR, OSD|
|Object Storage (S3) | MON, MGR, OSD, RGW|
|File Storage (CephFS) | MON, MGR, OSD, MDS|


```sh
helm repo add {rook_repo명} https://charts.rook.io/release

helm install {rook-ceph_chart명} rook/rook-ceph --version 1.17.0
```

---
## Ceph 구축하기
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
    image: quay.io/ceph/ceph:v19.2.2
    allowUnsupported: false
  dataDirHostPath: /var/lib/rook
  skipUpgradeChecks: false
  continueUpgradeAfterChecksEvenIfNotHealthy: false
  mon:
    count: 3
    allowMultiplePerNode: false
  mgr:
    count: 2
    allowMultiplePerNode: false
  dashboard:
    enabled: true
    ssl: false
  monitoring:
    enabled: false
  network:
    connections:
      encryption:
        enabled: false
      compression:
        enabled: false
      requireMsgr2: false
  crashCollector:
    disable: false
  logCollector:
    enabled: true
    periodicity: daily
    maxLogSize: 500M
  cleanupPolicy:
    confirmation: ""
    sanitizeDisks:
      method: quick
      dataSource: zero
      iteration: 1
    allowUninstallWithVolumes: false
  removeOSDsIfOutAndSafeToRemove: false
  priorityClassNames:
    mon: system-node-critical
    osd: system-node-critical
    mgr: system-cluster-critical
  storage:
    useAllNodes: true
    useAllDevices: true
    config:
      # 필요한 경우 여기에 추가 설정 가능 (ex. databaseSizeMB)
    allowDeviceClassUpdate: false
    allowOsdCrushWeightUpdate: false
    scheduleAlways: false
    onlyApplyOSDPlacement: false
  disruptionManagement:
    managePodBudgets: true
    osdMaintenanceTimeout: 30
  csi:
    readAffinity:
      enabled: false
    cephfs:
      # fuseMountOptions, kernelMountOptions 설정 가능 (기본은 비워둠)
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
    livenessProbe:
      mon:
        disabled: false
      mgr:
        disabled: false
      osd:
        disabled: false
    startupProbe:
      mon:
        disabled: false
      mgr:
        disabled: false
      osd:
        disabled: false

```
</details>

좀 더 간단하게 하고싶다면,
<details markdown="1">
  <summary>ceph-cluster-short.yaml</summary>

```yaml
apiVersion: ceph.rook.io/v1
kind: CephCluster
metadata:
  name: rook-ceph
  namespace: rook-ceph
spec:
  cephVersion:
    image: quay.io/ceph/ceph:v19.2.2
  dataDirHostPath: /var/lib/rook
  mon:
    count: 3
    allowMultiplePerNode: false
  dashboard:
    enabled: true
    ssl: false
  storage:
    useAllNodes: true
    useAllDevices: true
    config: {}
  disruptionManagement:
    managePodBudgets: true

```
</details>

하지만 현재 상황에서 리소스가 여유롭진 않으니,
<details markdown="1">
  <summary>ceph-cluster-limit.yaml</summary>

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

  crashCollector:  # 🔻 비활성화
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


### 적용 포인트

|항목|설정 내용|
|-|-|
|Namespace|rook-ceph|
|Ceph Version|v19.2.2 (Squid 최신 안정판)|
|Mon Count|3개|
|Mgr Count|2개 (Active + Standby)|
|OSD 구성|useAllDevices: true (vdb 자동 인식)|
|Dashboard|활성화, SSL 끄기 (HTTP)|
|Disk Encryption|사용 안 함 (내부망 고려)
|Monitoring|비활성화 (Prometheus 아직 설치 안 되어 있음)|
|CrashCollector/LogCollector|활성화|
|Disruption Management|활성화 (PodDisruptionBudget 적용)|
|CleanUp Policy|기본값 (데이터 보존)|
|Future Expansion|Worker, OSD 추가 용이하게 설정|

> "If you want all nodes and all available devices to be used automatically, set useAllNodes: true and useAllDevices: true. Specifying nodes: list is only necessary when you want **fine-grained control** over device selection.""
- 현재 worker 3,4,5만 vdb가 추가되어있어서 자동으로 w3,w4,w5에만 OSD가 생성됨
- 추가로 w6, w7에 vdb 추가하면 자동으로 OSD도 확장됨

|항목 | 일반 설정 이유|
|-|-|
|skipUpgradeChecks: false | 업그레이드 시 cluster health 체크함 (안정성)|
|allowMultiplePerNode: false | 같은 노드에 MON 2개 생성 방지 (HA 보장)|
|dashboard.ssl: false | 내부망이면 SSL 불필요, 운영 편의성|
|useAllDevices: true | 자동 디바이스 인식, 디스크 추가시 확장성|
|managePodBudgets: true | PodDisruptionBudget 적용, 장애/노드Drain 시 안정성|
|logCollector: enabled: true | 장애 분석 위해 daemon 로그 파일 저장|
|crashCollector: disable: false | crash 발생 시 crash report 수집|
|healthCheck: 활성화 | MON, OSD, MGR 주기적으로 상태 점검|
