#!/bin/bash

if ! systemd-detect-virt | grep -qi "vmware"; then
    echo "Not VMware Environment!"
    exit 0
fi

# vmhgfs-fuse not installed (open-vm-tools missing or incomplete)
if ! command -v vmhgfs-fuse &>/dev/null; then
    echo "vmhgfs-fuse not found, skipping."
    exit 0
fi

MOUNT_POINT="/mnt/hgfs"

# Already mounted — nothing to do
if mountpoint -q "${MOUNT_POINT}" 2>/dev/null; then
    echo "Already mounted: ${MOUNT_POINT}"
    exit 0
fi

mkdir -p "${MOUNT_POINT}"

# Attempt to mount .host:/ — this fails when no shared folders are configured
# in VMware settings, which is a valid state, not an error.
/usr/bin/vmhgfs-fuse .host:/ "${MOUNT_POINT}" -o subtype=vmhgfs-fuse,allow_other 2>/dev/null

if mountpoint -q "${MOUNT_POINT}"; then
    echo "VMware hgfs mount success: ${MOUNT_POINT}"
    exit 0
else
    # Mount failed — most likely no shared folders configured in VMware.
    # This is an expected condition, so exit 0 to keep the service green.
    echo "VMware hgfs mount skipped (no shared folders configured or mount unavailable)."
    exit 0
fi
