+++
title = "Kubespray로 쉽게 구축하기"
draft = false
+++
모든 인스턴스에 접근할 수 있는 곳에서 다음과 같은 작업을 실행한다.
In my case, it's control node.

1. Kubespray Downlaod & venv setting
```sh
# 필요한 패키지 설치
sudo apt update
sudo apt install -y git python3-venv python3-pip

# Kubespray 다운로드
git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray

# Python 가상환경 설정
python3 -m venv k8s-venv
source k8s-venv/bin/activate

# 의존성 설치
pip install -r requirements.txt
```

2. Inventory 구성
```sh
# 샘플 inventory 복사
cp -rfp inventory/sample inventory/mycluster

# 편집기로 inventory 구성 파일 수정
vim inventory/mycluster/inventory.ini
```

```inventory.ini```는 다음과 같다.
```sh
[kube_control_plane]
k8s-m1 ansible_host=192.168.0.101 ip=192.168.0.101
k8s-m2 ansible_host=192.168.0.102 ip=192.168.0.102
k8s-m3 ansible_host=192.168.0.103 ip=192.168.0.103

[etcd]
k8s-m1
k8s-m2
k8s-m3

[kube_node]
k8s-w1 ansible_host=192.168.0.104 ip=192.168.0.104
k8s-w2 ansible_host=192.168.0.105 ip=192.168.0.105
k8s-w3 ansible_host=192.168.0.106 ip=192.168.0.106
k8s-w4 ansible_host=192.168.0.107 ip=192.168.0.107
k8s-w5 ansible_host=192.168.0.108 ip=192.168.0.108
k8s-w6 ansible_host=192.168.0.109 ip=192.168.0.109
k8s-w7 ansible_host=192.168.0.110 ip=192.168.0.110

[k8s_cluster:children]
kube_control_plane
kube_node

[all:vars]
ansible_user=ubuntu
```

3. ssh 접속 확인 및 ping test
```sh
# passwordless ssh 접속 가능한지 확인
ansible -i inventory/mycluster/inventory.ini all -m ping
```

4. 모든 인스턴스에 다음 명령어 실행
- ubuntu 사용자에게 sudo 비밀번호 없이 실행 허용
```sh
echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/ubuntu

```

5. Cluster install
```sh
ansible-playbook -i inventory/mycluster/inventory.ini cluster.yml -b --become-user=root
```
