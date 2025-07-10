+++
title = "Worker & NFS 설정"
draft = false
+++
### Worker Node에 Role 부여하기
```
kubectl label node {node명} node-role.kubernetes.io/worker=worker
```

### NFS 서버 연결 및 PersistentVolume, StorageClass 설정
1. NFS 서버 확인
- IP 확인
- 공유 디렉토리 : e.g. ```/srv/nfs/k8s```  
> NFS 서버 설치하기
```sh
sudo apt update && sudo apt install nfs-kernel-server -y
sudo mkdir -p /srv/nfs/k8s
sudo chown nobody:nogroup /srv/nfs/k8s
echo "/srv/nfs/k8s *(rw,sync,no_subtree_check,no_root_squash)" | sudo tee -a /etc/exports
sudo exportfs -rav
sudo systemctl restart nfs-kernel-server
```

2. NFS Client 설치  
모든 워커 노드에 아래 실행
```sh
sudo apt update && sudo apt install nfs-common -y
```


### kubespray

```ini
[kube_control_plane]
k8s-m1 ansible_host=192.168.0.101 ip=192.168.0.101 etcd_member_name=etcd1
k8s-m2 ansible_host=192.168.0.102 ip=192.168.0.102 etcd_member_name=etcd2
k8s-m3 ansible_host=192.168.0.103 ip=192.168.0.103 etcd_member_name=etcd3

[etcd]
k8s-m1
k8s-m2
k8s-m3

[kube_node]
k8s-w1 ansible_host=192.168.0.104 ip=192.168.0.104
k8s-w2 ansible_host=192.168.0.105 ip=192.168.0.105
k8s-w3 ansible_host=192.168.0.106 ip=192.168.0.106

[k8s_cluster:children]
kube_control_plane
kube_node
```
