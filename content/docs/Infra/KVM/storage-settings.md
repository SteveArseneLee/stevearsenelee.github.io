+++
title = "KVM에서 사용할 Storage 설정"
draft = false
bookHidden = true
+++

### 1. Logical Volume 생성
물리 저장소에 논리 볼륨을 먼저 할당해준다
```sh
sudo lvcreate -L {크기 e.g. 300G} -n {LV이름 e.g. kvm-pool-lv} {Volume Group 이름 e.g. ubuntu-vg}
```

### 2. 파일 시스템 생성 (ext4)
```sh
sudo mkfs.ext4 /dev/ubuntu-vg/kvm-pool-lv
```

### 3. 마운트 dir 생성
```sh
sudo mkdir -p /mnt/kvm-pool
```

### 4. fstab 등록 (자동 마운트 설정)
```sh
echo '/dev/ubuntu-vg/ceph-pool-lv /mnt/ceph-pool ext4 defaults 0 2' | sudo tee -a /etc/fstab
sudo mount -a
```

### 5. 권한 변경(libvirt가 접근 가능하게)
```sh
sudo chown libvirt-qemu:kvm /mnt/ceph-pool
sudo chmod 770 /mnt/ceph-pool
```

### 6. libvirt Storage Pool 등록 (virsh)
```sh
sudo virsh pool-define-as ceph-pool dir - - - - /mnt/ceph-pool
sudo virsh pool-build ceph-pool
sudo virsh pool-start ceph-pool
sudo virsh pool-autostart ceph-pool
```
