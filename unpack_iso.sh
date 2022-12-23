#!/bin/bash

set -e

echo "Preparing system"
mkdir -p "/tmp/pop-os/cdrom"
mkdir "/tmp/pop-os/rootfs"
sudo modprobe isofs

echo "Downloading pop-os iso"
# Get latest iso link
pop_link=$(curl 'https://api.pop-os.org/builds/22.04/intel?arch=amd64' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; rv:107.0) Gecko/20100101 Firefox/107.0' | jq -r ".url")
# Download image with latest link
curl -L "$pop_link" -o /tmp/pop-os/pop-os.iso

echo "Mounting popos iso"
ISO_MNT=$(losetup -f --show /tmp/pop-os/pop-os.iso)
mount "$ISO_MNT" /tmp/pop-os/cdrom

echo "Extracting popos squashfs"
unsquashfs -f -d /tmp/pop-os/rootfs /tmp/pop-os/cdrom/casper/filesystem.squashfs

echo "Updating all packages inside rootfs"
chroot /tmp/pop-os/rootfs /bin/bash -c "apt update -y && apt upgrade -y"

echo "Cleaning rootfs"
# Clean rootfs of temporary files to reduce its size
rm -rf /mnt/depthboot/tmp
rm -rf /mnt/depthboot/var/tmp
rm -rf /mnt/depthboot/var/cache
rm -rf /mnt/depthboot/proc
rm -rf /mnt/depthboot/run
rm -rf /mnt/depthboot/sys
rm -rf /mnt/depthboot/lost+found
rm -rf /mnt/depthboot/dev

echo "Compressing rootfs"
cd "/tmp/pop-os/rootfs"
tar -cv -I 'xz -9 -T0' -f ../popos-rootfs.tar.xz ./
