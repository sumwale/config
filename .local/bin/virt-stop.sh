#!/bin/sh

# cgroup-lite qemu-system-x86

if [ -x /etc/init.d/vmware ]; then
  sudo /etc/init.d/vmware-USBArbitrator stop
  sudo /etc/init.d/vmware stop
  sudo rmmod vmmon vmnet 2>/dev/null
  sudo rmmod vmw_vsock_vmci_transport vmw_vmci vsock
else
  for service in sshd.service ssh.service nmbd.service smbd.service nmb.service smb.service nfs-server.service nfs-kernel-server.service rpcbind.service virtlogd-admin.socket virtlockd-admin.socket libvirtd-admin.socket libvirtd.socket virtlogd.service virtlogd.socket virtlockd.socket libvirtd-ro.socket libvirt-guests.service virtlockd.service virtlogd.service libvirtd.service; do
    if sudo systemctl list-unit-files $service; then
      sudo systemctl stop $service 2>/dev/null
      sudo systemctl disable $service 2>/dev/null
      sudo killall `echo $service | sed 's/\..*//'` 2>/dev/null
    fi
  done

  #sudo rmmod kvm_intel kvm || /bin/true
fi
