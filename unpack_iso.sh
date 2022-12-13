#!/bin/bash

set -e

echo "Preparing system"
mkdir -p "/tmp/pop-os/cdrom"
mkdir "/tmp/pop-os/rootfs"
sudo modprobe isofs

echo "Downloading pop-os iso"
pop_link=$(curl 'https://api.pop-os.org/builds/22.04/intel?arch=amd64' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; rv:107.0) Gecko/20100101 Firefox/107.0' | jq -r ".url")
curl -L pop_link -o /tmp/pop-os/pop-os.iso

echo "Mounting popos iso"
ISO_MNT=$(losetup -f --show /tmp/pop-os/pop-os.iso)
mount "$ISO_MNT" /tmp/pop-os/cdrom

echo "Extracting popos squashfs"
unsquashfs -f -d /tmp/pop-os/rootfs /tmp/pop-os/cdrom/casper/filesystem.squashfs

echo "Updating all packages inside rootfs"
chroot /tmp/pop-os/rootfs /bin/bash -c "apt update -y && apt upgrade -y"

echo "Compressing rootfs"
cd "/tmp/pop-os/rootfs"
tar -cv -I 'xz -9 -T0' -f ../popos-rootfs.tar.xz ./
