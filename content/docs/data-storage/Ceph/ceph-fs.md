+++
title = "CephFS 구축하기"
draft = false
categories = ["Data Engineering", "Ceph"]
+++

### 1. CephFS Filesystem 생성
rook-ceph-filesystem.yaml
```yaml
apiVersion: ceph.rook.io/v1
kind: CephFilesystem
metadata:
  name: rook-ceph-fs
  namespace: rook-ceph
spec:
  metadataPool:
    replicated:
      size: 3
  dataPools:
    - replicated:
        size: 3
  preserveFilesystemOnDelete: true
  metadataServer:
    activeCount: 1
    activeStandby: true
```
- metadataPool, dataPools 모두 replication 3개로 설정(3 OSD)
- MDS(Metadata Server)는 1 active + 1 standby (HA)


### 2. CephFS용 StorageClass 생성
rook-cephfs-sc.yaml
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: rook-cephfs
provisioner: rook-ceph.cephfs.csi.ceph.com
parameters:
  clusterID: rook-ceph
  fsName: rook-ceph-fs
  pool: rook-ceph-fs-data0
  csi.storage.k8s.io/provisioner-secret-name: rook-csi-cephfs-provisioner
  csi.storage.k8s.io/provisioner-secret-namespace: rook-ceph
  csi.storage.k8s.io/node-stage-secret-name: rook-csi-cephfs-node
  csi.storage.k8s.io/node-stage-secret-namespace: rook-ceph
reclaimPolicy: Delete
allowVolumeExpansion: true
mountOptions:
  - noatime
```
- CephFS는 rook-ceph-fs Filesystem을 바라봄
- Ceph CSI가 자동으로 PV/PVC를 생성하고 Mount하도록 설정함
- noatime 설정으로 파일 접근 시간 기록을 방지하여 성능 최적화


### 3. CephFS PVC + Pod 테스트
cephfs-pvc-test.yaml
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: cephfs-pvc
  namespace: test
spec:
  storageClassName: rook-cephfs
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: cephfs-pod
  namespace: test
spec:
  containers:
  - name: cephfs-container
    image: busybox
    command: ["/bin/sh", "-c", "sleep 3600"]
    volumeMounts:
    - mountPath: "/mnt/cephfs"
      name: cephfs-vol
  volumes:
  - name: cephfs-vol
    persistentVolumeClaim:
      claimName: cephfs-pvc
```
- CephFS는 기본적으로 RWX(ReadWriteMany)를 지원함. (여러 Pod에서 동시에 Mount 가능)


---
## 삭제
cephFS는 RGW를 씀으로써 내 환경에서 너무 과하게 많은 리소스를 사용함.
- block storage : Ceph RBD
- object storage : Minio
- File System : NFS  
위와 같이 사용함으로써 리소스 낭비를 줄이는 방향으로 간다.

```sh
# 1. test 네임스페이스에서 cephfs-pvc, cephfs-pod 삭제
kubectl delete pvc cephfs-pvc -n test
kubectl delete pod cephfs-pod -n test

# 2. rook-cephfs StorageClass 삭제
kubectl delete sc rook-cephfs

# 3. rook-ceph-fs CephFilesystem 삭제
kubectl delete cephfilesystem rook-ceph-fs -n rook-ceph

# 4. (자동) MDS 관련 Deployment 삭제 확인
kubectl get deploy -n rook-ceph | grep mds

# 5. rook-ceph-fs 관련 Ceph Pools 삭제
kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- bash

# rook-ceph-tools 내부에서 실행
ceph osd pool ls
ceph osd pool delete rook-ceph-fs-metadata rook-ceph-fs-metadata --yes-i-really-really-mean-it
ceph osd pool delete rook-ceph-fs-data0 rook-ceph-fs-data0 --yes-i-really-really-mean-it

# 삭제 후 cluster 상태 점검
ceph status
```
