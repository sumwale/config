#!/bin/sh

# cgroup-lite qemu-system-x86

sudo modprobe kvm_intel

for service in qemu-kvm.service libvirtd-ro.socket libvirtd.socket libvirtd-admin.socket virtlockd-admin.socket virtlogd-admin.socket virtlogd.socket virtlockd.socket libvirt-guests.service libvirtd.service rpcbind.service nfs-kernel-server.service nfs-server.service smb.service nmb.service smbd.service nmbd.service ssh.service sshd.service; do
  if sudo systemctl list-unit-files $service; then
    sudo systemctl restart $service
  fi
done
