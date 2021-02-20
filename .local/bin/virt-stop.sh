#!/bin/sh

# cgroup-lite qemu-system-x86

for service in nmbd smbd nmb smb nfs-server nfs-kernel-server rpcbind virtlogd-admin.socket virtlockd-admin.socket libvirtd-admin.socket libvirtd.socket virtlogd.service virtlogd.socket virtlockd.socket libvirtd-ro.socket libvirt-guests.service libvirtd.service qemu-kvm.service; do
  sudo systemctl stop $service 2>/dev/null
  sudo systemctl disable $service 2>/dev/null
  killall `echo $service | sed 's/\..*//'` 2>/dev/null
done

#sudo rmmod kvm_intel kvm
