#!/bin/bash
qemu-system-arm -M versatilepb -kernel 05-images/zImage -m 128M -initrd 05-images/initramfs.gz -append "root=/dev/ram rdinit=/bin/sh" $@
