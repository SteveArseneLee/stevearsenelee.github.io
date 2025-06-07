+++
title = "Ceph 초기 설정하기"
categories = ["dataengineering", "ceph"]
+++


ceph가 정상적으로 설치됐다면 다음의 설정들을 추가해준다.
ceph-tools는 운영자가 다루는 pod라서 따로 추가해줘야한다.

rook-ceph-config.yaml
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: rook-ceph-config
  namespace: rook-ceph
data:
  ceph.conf: |
    [global]
    fsid = cb669020-44b5-4528-bdf8-5f7e082cbf71
    mon_host = 10.233.41.119,10.233.10.62,10.233.45.253
    mon_initial_members = a,b,c
    auth_cluster_required = cephx
    auth_service_required = cephx
    auth_client_required = cephx
    log_to_stderr = false
    err_to_stderr = false
    log_to_syslog = false
    log_to_monitors = true
```
- fsid 값과 mon_host IP는 각 클러스터 환경에 맞게 수정 필요.


rook-ceph-admin-keyring.yaml
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: rook-ceph-admin-keyring
  namespace: rook-ceph
type: Opaque
stringData:
  ceph.client.admin.keyring: |
    [client.admin]
      key = AQAH+wFonT6EHhAAgGph5NeWPyTTO41HkFOpDg==
      caps mds = "allow *"
      caps mgr = "allow *"
      caps mon = "allow *"
      caps osd = "allow *"
```
- key = ~ 값은 Ceph Dashboard → Admin 계정 Export로 가져온 값 사용.
- 주의: stringData를 써야 Base64 인코딩 없이 바로 적용할 수 있음.  
=> key 이름 주의: ceph.client.admin.keyring 이 정확히 필요함.


<details markdown="1">
  <summary>rook-ceph-tools.yaml</summary>

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rook-ceph-tools
  namespace: rook-ceph
spec:
  replicas: 1
  selector:
    matchLabels:
      app: rook-ceph-tools
  template:
    metadata:
      labels:
        app: rook-ceph-tools
    spec:
      containers:
      - name: rook-ceph-tools
        image: rook/ceph:v1.12.10
        command: ["/usr/bin/bash"]
        args: ["-c", "sleep infinity"]
        imagePullPolicy: IfNotPresent
        securityContext:
          privileged: true
        volumeMounts:
        - name: ceph-conf
          mountPath: /etc/ceph
      volumes:
      - name: ceph-conf
        projected:
          sources:
          - configMap:
              name: rook-ceph-config
              items:
              - key: ceph.conf
                path: ceph.conf
          - secret:
              name: rook-ceph-admin-keyring
              items:
              - key: ceph.client.admin.keyring
                path: ceph.client.admin.keyring
```
</details>

정상 동작 확인 방법
```yaml
kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- bash
```
에 들어가서

```sh
cat /etc/ceph/ceph.conf
cat /etc/ceph/ceph.client.admin.keyring
ceph status
```




|항목 | 설명|
|-|-|
|ConfigMap | /etc/ceph/ceph.conf 파일을 주입하기 위함|
|Secret | /etc/ceph/ceph.client.admin.keyring 파일을 주입하기 위함|
|rook-ceph-tools Deployment | Toolbox Pod 자체, 위 ConfigMap/Secret을 /etc/ceph에 mount|


### Troubleshooting
|문제 | 원인 | 해결 방법|
|-|-|-|
|RADOS object not found | ceph.conf, keyring 둘 다 없었음 | ConfigMap, Secret 주입|
|Malformed input | keyring 포맷 문제 (key 값 틀림) | Dashboard에서 client.admin 내보내기로 key 추출 후 적용|
|FailedMount 에러 | key 이름 mismatch (key 대신 ceph.client.admin.keyring) | Secret 안에 key 이름 수정|
|Toolbox ceph status 실패 | config, keyring 둘 중 하나라도 잘못 mount됨 | 둘 다 제대로 적용 후 성공|
