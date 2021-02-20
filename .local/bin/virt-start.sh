#!/bin/sh

# cgroup-lite qemu-system-x86

sudo modprobe kvm_intel

for service in qemu-kvm.service libvirtd-ro.socket libvirtd.socket libvirtd-admin.socket virtlockd-admin.socket virtlogd-admin.socket virtlogd.socket virtlockd.socket libvirt-guests.service libvirtd.service rpcbind nfs-kernel-server nfs-server sshd; do
  sudo systemctl restart $service
done
