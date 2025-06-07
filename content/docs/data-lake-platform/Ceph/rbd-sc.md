+++
title = "Ceph RBD 설정하기(Block Storage)"
draft = false
+++


## Ceph RBD를 Kubernetes PVC로 연동하기
순서는 다음과 같다.
1. RBD용 Pool 생성
2. StorageClass 생성
3. PVC 생성
4. PVC를 사용하는 테스트 Pod 생성
5. 정상 Mount 여부 확인

---
### 1. RDB용 Pool 생성
```sh
kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- bash
```
로 rook-ceph-tools에 접속해서 아래 명령어를 수행한다.
```sh
ceph osd pool create {Pool명} {PG 수}
```
PG란?
- Placement Group의 약자
- Ceph에서는 데이터를 곧바로 OSD에 저장하는 게 아닌, 중간에 PG를 거쳐 저장함
- 데이터를 여러 OSD에 분산 저장할 때 "분산의 단위" 역할을 함
- 데이터가 저장될 위치를 결정할 때, "Pool -> PG -> OSD"라는 경로를 통해 결정함
- 복제도 PG 단위로 관리함

|구분 | 설명|
|-|-|
|OSD | 실제 디스크에 저장하는 단위 (Object Storage Daemon)|
|PG (Placement Group) | 여러 OSD 사이에서 데이터를 배치(placement)하고 그룹핑하는 논리 단위|
|Object | 사용자 데이터 (파일, 블록 등)를 쪼갠 실제 저장 단위|


즉, 데이터의 흐름은 다음과 같다
```txt
Client -> Pool -> Placement Group (PG) -> OSD
```

#### PG 수 정하기
PG 수는 OSD 개수와 Replication Factor(복제본 개수)를 고려해서 정해야한다.
기본적인 공식은 다음과 같다.  

$PG 수≈(OSD 개수)×100÷복제본 수 (replica)$  

현재 내 서버의 상황은 다음과 같다.
- OSD 3개
- 복제본(replica) 기본 3개 ~> 100개 정도가 권장됨  
-> 따라서 Ceph의 기본 권장치 중 하나인 128개로 선택함

> PG 수는 너무 적으면 데이터 분산이 비효율적이고, 너무 많으면 OSD 관리 부하가 커진다. (3~5개 OSD로 시작할 땐 128 정도가 적당함)


### 2. RBD StorageClass 생성하기
Ceph POol(replicapool)을 k8s에서 쓸 수 있도록 StorageClass를 만들어야 한다.
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
```

### 3. PVC + PVC를 사용하는 테스트 Pod 생성
```yaml
# rbd-pvc-test.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: rbd-pvc
  namespace: default
spec:
  storageClassName: rook-ceph-block
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: rbd-pod
  namespace: default
spec:
  containers:
  - name: rbd-container
    image: busybox
    command: ["/bin/sh", "-c", "sleep 3600"]
    volumeMounts:
    - mountPath: "/mnt/rbd"
      name: rbd-vol
  volumes:
  - name: rbd-vol
    persistentVolumeClaim:
      claimName: rbd-pvc
```


### 4. 정상 Mount 여부 확인
```sh
kubectl -n test exec -it rbd-pod -- sh
# 내부 진입 후
ls /mnt/rbd
# => 정상적으로 디렉토리 접근 가능
```
