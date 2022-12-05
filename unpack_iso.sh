#!/bin/bash

set -e

echo "Preparing system"
mkdir -p "/tmp/pop-os/cdrom"
mkdir "/tmp/pop-os/rootfs"
sudo modprobe isofs

echo "Downloading pop-os iso"
curl -L https://iso.pop-os.org/22.04/amd64/intel/17/pop-os_22.04_amd64_intel_17.iso -o /tmp/pop-os/pop-os.iso

ls -a /tmp/pop-os

echo "Mounting popos iso"
ISO_MNT=$("losetup -f --show /tmp/pop-os/pop-os.iso")
mount "$ISO_MNT" /tmp/pop-os/cdrom

echo "Extracting popos squashfs"
unsquashfs -f -d /tmp/pop-os/rootfs /tmp/pop-os/cdrom/casper/filesystem.squashfs

echo "Updating all packages inside rootfs"
chroot /tmp/pop-os/rootfs /bin/bash -c "apt update -y && apt upgrade -y"

echo "Compressing rootfs"
cd "/tmp/pop-os/rootfs"
tar -cv -I 'xz -9 -T0' -f ../popos-rootfs.tar.xz ./
