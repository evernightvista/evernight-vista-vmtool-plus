#!/bin/bash

if ! systemd-detect-virt | grep -qi "vmware"; then
    echo "Not VMware Environment!"
    exit 0
fi

MOUNT_POINT="/mnt/hgfs"
mkdir -p "${MOUNT_POINT}"

/usr/bin/vmhgfs-fuse .host:/ /mnt/hgfs -o subtype=vmhgfs-fuse,allow_other

if mountpoint -q "${MOUNT_POINT}"; then
    echo "VMware hgfs mount success：${MOUNT_POINT}"
else
    echo "VMware hgfs mount failed"
    exit 1
fi
