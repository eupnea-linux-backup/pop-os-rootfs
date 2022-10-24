#!/usr/bin/env python3
import os
from urllib.request import urlretrieve

from functions import *

if __name__ == "__main__":
    set_verbose(True)

    print_status("Preparing system")
    mkdir("/tmp/pop-os/cdrom", create_parents=True)
    mkdir("/tmp/pop-os/rootfs")
    bash("sudo modprobe isofs")

    print_status("Downloading popos iso")
    urlretrieve("https://iso.pop-os.org/22.04/amd64/intel/14/pop-os_22.04_amd64_intel_14.iso",
                filename="/tmp/pop-os/pop-os.iso")

    print_status("Mounting popos iso")
    mnt_iso = bash(f"losetup -f --show /tmp/pop-os/pop-os.iso")
    bash(f"mount {mnt_iso} /tmp/pop-os/cdrom")

    print_status("Extracting popos squashfs")
    bash("unsquashfs -f -d /tmp/pop-os/rootfs /tmp/pop-os/cdrom/casper/filesystem.squashfs")

    print_status("Compressing rootfs")
    os.chdir(f"/tmp/pop-os/rootfs")
    bash(f"tar -cv -I 'xz -9 -T0' -f ./popos-rootfs.tar.xz ./")
