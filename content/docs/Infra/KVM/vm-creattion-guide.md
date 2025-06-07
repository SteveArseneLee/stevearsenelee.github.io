+++
title = "VM 생성"
draft = false
tags = ["infra", "kvm"]
bookHidden = true
+++

[준비 단계]
1. os image 다운로드 받아놓기
2. Resource 용량 산정 (cpu, memory, disk)
3. ip 설계
4. (선택) 물리 서버가 n대라면 VM 분배 계획

[실습 단계]
1. storage pool & volume 생성
2. cockpit에서 vm 생성(이때 앞서 계획한 ip 및 자원 할당)

---
```
# 1. 디렉토리 생성 및 권한 설정
sudo mkdir -p /mnt/kvm-pool
sudo chown libvirt-qemu:kvm /mnt/kvm-pool
sudo chmod 770 /mnt/kvm-pool

# 2. 스토리지 풀 정의 및 등록
sudo virsh pool-define-as kvm-pool dir - - - - /mnt/kvm-pool
sudo virsh pool-build kvm-pool
sudo virsh pool-start kvm-pool
sudo virsh pool-autostart kvm-pool
```

### Pool 삭제하는 법
```
# 스토리지 풀 조회
sudo virsh pool-list --all

# 스토리지 풀 중지
sudo virsh pool-destroy {pool명}

# 스토리지 풀 정의 삭제
sudo virsh pool-undefine {pool명}
```

### Home
|VM명|CPU|RAM|
|-|-|-|
|ctrl-node|2|2GB|
|k8s-m1|2|4|
|k8s-m2|2|4|
|k8s-w1|2|8|
|k8s-w2|2|8|
|k8s-w3|2|8|

|VM명|Disk|CPU|RAM|
|-|-|-|-|
|ctrl-node|/mnt/kvm-pool/ctrl-node.qcow2|2|2GB|
|k8s-m1|/mnt/kvm-pool/k8s-m1.qcow2|2|4GB|
|k8s-m2|/mnt/kvm-pool/k8s-m2.qcow2|2|4GB|
|k8s-w3|/mnt/kvm-pool/k8s-w3.qcow2|2|4GB|



### Test
|VM명|CPU|RAM|
|-|-|-|
|k8s-m3|2|4GB|
|k8s-w4|2|8GB|
|k8s-w5|2|8GB|
|k8s-w6|2|8GB|
|k8s-w7|2|8GB|
|nfs-server|1|2GB|


|VM명|Disk|CPU|RAM|HOST
|-|-|-|-|-|
|k8s-m3| /mnt/kvm-pool/k8s-m3.qcow2 | 2| 4GB |
|k8s-w1| /mnt/kvm-pool/k8s-w1.qcow2 | 2| 4GB |
|k8s-w2| /mnt/kvm-pool/k8s-w2.qcow2 | 2| 4GB |
|nfs-server| /mnt/kvm-pool/nfs.qcow2 | 1| 2GB |
