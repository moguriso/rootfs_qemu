#!/bin/bash
# qemu-system-arm -M versatilepb -serial stdio -nographic -kernel 05-images/zImage -m 128M -initrd 05-images/initramfs.gz -append "root=/dev/ram rdinit=/bin/sh console=ttyS0 nosplash" $@
# qemu-system-arm -M realview-pbx-a9 -serial stdio -nographic -kernel 05-images/zImage -m 128M -initrd 05-images/initramfs.gz -append "root=/dev/ram rdinit=/bin/sh console=ttyS0 nosplash" $@
# qemu-system-arm -M versatilepb -nographic -kernel 05-images/zImage -m 128M -initrd 05-images/initramfs.gz -append "root=/dev/ram rdinit=/bin/sh console=ttyAMA0" $@

# qemu-system-arm -M versatilepb -kernel 05-images/zImage -m 128M -initrd 05-images/initramfs.gz -append "root=/dev/ram rdinit=/bin/sh" $@

qemu-system-arm -M versatilepb -nographic -kernel 05-images/zImage -m 128M -initrd 05-images/initramfs.gz -append "root=/dev/ram rdinit=/bin/sh console=ttyAMA0" $@
