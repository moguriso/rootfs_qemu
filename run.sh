#!/bin/bash
qemu-system-arm -M versatilepb -kernel 05-images/zImage -m 128M -hda 05-images/rootfs.gz -append "root=/dev/sda init=/bin/sh" $@
