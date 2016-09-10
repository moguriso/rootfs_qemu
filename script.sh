#!/bin/bash

set -e
source ./filetree.env

for dir in ${DOWNLOADS} ${SOURCES} ${HOST_BUILD} ${TARGET_BUILD} ${HOST_SYSROOT} ${TARGET_SYSROOT} ${IMAGES}; do
    mkdir -p $dir
done
case $(uname -m) in
  x86_64) ln -sfn lib ${HOST_SYSROOT}/lib64 ;;
esac

./binutils-2.25.sh

./gmp-6.1.1.sh

./mpfr-3.1.4.sh

./mpc-1.0.3.sh

./isl-0.17.sh

./cloog-0.18.4.sh

./gcc-4.9.2.sh first

./linux-3.18.1.sh header

./glibc-2.20.sh

./gcc-4.9.2.sh second

./gcc-4.9.2.sh third

./gdb-7.8.1.sh

./baselayout.sh

./iana-etc-2.30.sh

./busybox-1.22.1.sh

./linux-3.18.1.sh kernel

./test-0.1.sh

./mkrootfs.sh

cd $root
