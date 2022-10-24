#!/usr/bin/env python3
import os

from functions import *

if __name__ == "__main__":
    set_verbose(True)
    fedora_version = args.fedora_version[0]

    print_status("Preparing system")
    mkdir("/tmp/popos/iso")
    mkdir("/tmp/popos/cdrom")
    bash("sudo modprobe isofs")

    print_status("Downloading image")
    urlretrieve("https://iso.pop-os.org/22.04/amd64/intel/14/pop-os_22.04_amd64_intel_14.iso", filename="/tmp/depthboot-build/pop-os.iso")

    print_status("Compressing rootfs")
    os.chdir(f"/tmp/{fedora_version}")
    bash(f"tar -cv -I 'xz -9 -T0' -f ../fedora-rootfs-{fedora_version}.tar.xz ./")
