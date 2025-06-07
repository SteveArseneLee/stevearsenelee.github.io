+++
title = "VM 생성 간단"
draft = false
tags = ["infra", "kvm"]
bookHidden = true
+++

Home에는
```sh
#!/bin/bash
set -e

echo "[HOME SERVER - STORAGE POOL & VOLUME SETUP]"

# [1] Storage Pools 생성
echo "[1] Creating storage pools..."
sudo mkdir -p /mnt/kvm-pool /mnt/ceph-pool
sudo chown libvirt-qemu:kvm /mnt/kvm-pool /mnt/ceph-pool
sudo chmod 770 /mnt/kvm-pool /mnt/ceph-pool

sudo virsh pool-define-as --name kvm-pool --type dir --target /mnt/kvm-pool
sudo virsh pool-build kvm-pool
sudo virsh pool-start kvm-pool
sudo virsh pool-autostart kvm-pool

sudo virsh pool-define-as --name ceph-pool --type dir --target /mnt/ceph-pool
sudo virsh pool-build ceph-pool
sudo virsh pool-start ceph-pool
sudo virsh pool-autostart ceph-pool

# [2] Volume 생성
echo "[2] Creating VM OS disks..."
cd /mnt/kvm-pool

sudo qemu-img create -f qcow2 ctrl-node.qcow2 40G
sudo qemu-img create -f qcow2 k8s-m1.qcow2 30G
sudo qemu-img create -f qcow2 k8s-m2.qcow2 30G
sudo qemu-img create -f qcow2 k8s-w1.qcow2 50G
sudo qemu-img create -f qcow2 k8s-w2.qcow2 50G

echo "[3] Creating Ceph raw disks..."
cd /mnt/ceph-pool

sudo qemu-img create -f raw k8s-w1-ceph.img 100G
sudo qemu-img create -f raw k8s-w2-ceph.img 100G

echo "[HOME SERVER SETUP COMPLETE]"

```

Test에는
```sh
#!/bin/bash
set -e

echo "[TEST SERVER - STORAGE POOL & VOLUME SETUP]"

# [1] Storage Pools 생성
echo "[1] Creating storage pools..."
sudo mkdir -p /mnt/kvm-pool /mnt/ceph-pool /mnt/nfs-pool
sudo chown libvirt-qemu:kvm /mnt/kvm-pool /mnt/ceph-pool /mnt/nfs-pool
sudo chmod 770 /mnt/kvm-pool /mnt/ceph-pool /mnt/nfs-pool

# kvm-pool (OS용)
sudo virsh pool-define-as --name kvm-pool --type dir --target /mnt/kvm-pool
sudo virsh pool-build kvm-pool
sudo virsh pool-start kvm-pool
sudo virsh pool-autostart kvm-pool

# ceph-pool (Ceph용)
sudo virsh pool-define-as --name ceph-pool --type dir --target /mnt/ceph-pool
sudo virsh pool-build ceph-pool
sudo virsh pool-start ceph-pool
sudo virsh pool-autostart ceph-pool

# kvm-nfs-pool (NFS 서버용)
sudo virsh pool-define-as --name kvm-nfs-pool --type dir --target /mnt/kvm-nfs-pool
sudo virsh pool-build kvm-nfs-pool
sudo virsh pool-start kvm-nfs-pool
sudo virsh pool-autostart kvm-nfs-pool

# [2] Volume 생성
echo "[2] Creating VM OS disks..."
cd /mnt/kvm-pool

sudo qemu-img create -f qcow2 k8s-m3.qcow2 30G
sudo qemu-img create -f qcow2 k8s-w3.qcow2 50G
sudo qemu-img create -f qcow2 k8s-w4.qcow2 50G
sudo qemu-img create -f qcow2 k8s-w5.qcow2 50G
sudo qemu-img create -f qcow2 nfs.qcow2 30G

echo "[3] Creating Ceph raw disks..."
cd /mnt/ceph-pool

sudo qemu-img create -f raw k8s-w3-ceph.img 100G
sudo qemu-img create -f raw k8s-w4-ceph.img 100G
sudo qemu-img create -f raw k8s-w5-ceph.img 100G

echo "[4] Creating NFS data disk..."
cd /mnt/nfs-pool

sudo qemu-img create -f qcow2 nfs-data.qcow2 300G

echo "[TEST SERVER SETUP COMPLETE]"
```