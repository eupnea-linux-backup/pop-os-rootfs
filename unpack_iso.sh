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

echo "Mounting pop-os iso"
ISO_MNT=$(losetup -f --show /tmp/pop-os/pop-os.iso)
mount "$ISO_MNT" /tmp/pop-os/cdrom

echo "Extracting pop-os squashfs"
unsquashfs -f -d /tmp/pop-os/rootfs /tmp/pop-os/cdrom/casper/filesystem.squashfs

echo "Cleaning rootfs"
# Remove unneeded/temporary files to reduce the rootfs size
rm -rf /tmp/pop-os/rootfs/boot/*
#rm -rf /tmp/pop-os/rootfs/dev/*
rm -rf /tmp/pop-os/rootfs/lost+found/*
rm -rf /tmp/pop-os/rootfs/media/*
rm -rf /tmp/pop-os/rootfs/mnt/*
#rm -rf /tmp/pop-os/rootfs/proc/*
#rm -rf /tmp/pop-os/rootfs/run/*
#rm -rf /tmp/pop-os/rootfs/sys/*
rm -rf /tmp/pop-os/rootfs/tmp/*
rm -rf /tmp/pop-os/rootfs/var/tmp/*
#rm -rf /tmp/pop-os/rootfs/var/cache


echo "Compressing rootfs"
cd "/tmp/pop-os/rootfs"
tar -cv -I 'xz -9 -T0' -f ../pop-os-rootfs-22.04.tar.xz ./

echo "Calculating sha256sum"
sha256sum ../pop-os-rootfs-22.04.tar.xz > ../pop-os-rootfs-22.04.sha256
