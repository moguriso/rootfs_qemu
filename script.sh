#!/bin/sh

# http://tanehp.ec-net.jp/heppoko-lab/prog/qemu_arm/qemu-arm.html

set -e
source ./filetree.env

for dir in ${DOWNLOADS} ${SOURCES} ${HOST_BUILD} ${TARGET_BUILD} ${HOST_SYSROOT} ${TARGET_SYSROOT} ${IMAGES}; do
    mkdir -p $dir
done
case $(uname -m) in
  x86_64) mkdir -v ${HOST_SYSROOT}/lib && ln -sv lib ${HOST_SYSROOT}/lib64 ;;
esac

./binutils-2.25.sh first

./gcc-4.9.2.sh first

./linux-3.18.1.sh header

./glibc-2.20.sh

./gcc-4.9.2.sh second

#./binutils-2.25.sh second

./gcc-4.9.2.sh third

./gdb-7.8.1.sh

./baselayout.sh

./iana-etc-2.30.sh

./busybox-1.22.1.sh

./linux-3.18.1.sh kernel

./mkrootfs.sh

cd $root
