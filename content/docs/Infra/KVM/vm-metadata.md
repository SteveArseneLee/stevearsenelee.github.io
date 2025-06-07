+++
title = "Hello"
draft = false
bookHidden = true
+++


인프라 구성은 다음과 같다.

### Home(192.168.0.19)
|VM명|Disk|CPU|RAM|Disk 사이즈|
|-|-|-|-|-|
|ctrl-node|/mnt/kvm-pool/ctrl-node.qcow2|2|2GB|40GB|
|k8s-m1|/mnt/kvm-pool/k8s-m1.qcow2|3|8GB|30GB|
|k8s-m2|/mnt/kvm-pool/k8s-m2.qcow2|3|8GB|30GB|
|k8s-w1|/mnt/kvm-pool/k8s-w1.qcow2|3|16GB|50GB + Ceph 100GB|
|k8s-w2|/mnt/kvm-pool/k8s-w2.qcow2|4|16GB|50GB + Ceph 100GB|
|총합||15|50GB|



### Test(192.168.0.18)
|VM명|Disk|CPU|RAM|Disk 사이즈|
|-|-|-|-|-|
|k8s-m3| /mnt/kvm-pool/k8s-m3.qcow2 | 4| 8GB |30GB|
|k8s-w3| /mnt/kvm-pool/k8s-w3.qcow2 | 4| 16GB |50GB + Ceph 100GB|
|k8s-w4| /mnt/kvm-pool/k8s-w4.qcow2 | 4| 16GB |50GB + Ceph 100GB|
|k8s-w5| /mnt/kvm-pool/k8s-w5.qcow2 | 4| 16GB |50GB + Ceph 100GB|
|nfs-server| /mnt/kvm-pool/nfs.qcow2 | 1| 2GB |30GB + NFS 300GB|
|총합||17|58GB|

### IP
|Key | Value|
|-|-|
|Subnet|192.168.0.0/24|
|Gateway| 192.168.0.1|
|Name Servers | 8.8.8.8, 1.1.1.1|
|Search Domains| (비워도 무방)|


|VM 이름|Address 입력값(고정 IP)| 생성 여부 |
|-|-|-|
|ctrl-node | 192.168.0.100/24| O |
|k8s-m1 | 192.168.0.101/24| O |
|k8s-m2 | 192.168.0.102/24| O |
|k8s-m3 | 192.168.0.103/24| O |
|worker|||
|k8s-w1 | 192.168.0.111/24| O |
|k8s-w2 | 192.168.0.112/24| O |
|k8s-w3 | 192.168.0.113/24| O |
|k8s-w4 | 192.168.0.114/24| O |
|k8s-w5 | 192.168.0.115/24| O |
|nfs-server | 192.168.0.200/24| O |


---

### GPU있는 서버(192.168.0.19)
|VM명|Disk|CPU|RAM|Disk 사이즈|
|-|-|-|-|-|
k8s-w3||4|20|
k8s-w4||4|18|
k8w-w5||4|18|

총합||16vcpu|62gb|



### Main(192.168.0.62)
|VM명|Disk|CPU|RAM|Disk 사이즈|
|-|-|-|-|-|
k8s-m1||6|12GB|50GB
k8s-w1||6|20GB|
k8s-w2||6|20GB|




### IP
|Key | Value|
|-|-|
|Subnet|192.168.0.0/24|
|Gateway| 192.168.0.1|
|Name Servers | 8.8.8.8, 1.1.1.1|
|Search Domains| (비워도 무방)|


|VM 이름|Address 입력값(고정 IP)| 생성 여부 |
|-|-|-|
|ctrl-node | 192.168.0.100/24| O |
|k8s-m1 | 192.168.0.101/24| O |
|k8s-m2 | 192.168.0.102/24| O |
|k8s-m3 | 192.168.0.103/24| O |
|worker|||
|k8s-w1 | 192.168.0.111/24| O |
|k8s-w2 | 192.168.0.112/24| O |
|k8s-w3 | 192.168.0.113/24| O |
|k8s-w4 | 192.168.0.114/24| O |
|k8s-w5 | 192.168.0.115/24| O |
|nfs-server | 192.168.0.200/24| O |
