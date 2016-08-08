#!/bin/sh

# http://www.linuxfromscratch.org/lfs/view/development/chapter05/chapter05.html

set -e
source ./filetree.env

for dir in ${DOWNLOADS} ${SOURCES} ${HOST_BUILD} ${TARGET_BUILD} ${HOST_SYSROOT} ${TARGET_SYSROOT}; do
    mkdir -p $dir
done
case $(uname -m) in
  x86_64) mkdir -v ${HOST_SYSROOT}/lib && ln -sv lib ${HOST_SYSROOT}/lib64 ;;
esac

# 5.4. Binutils-2.26.1 - Pass 1
# http://www.linuxfromscratch.org/lfs/view/development/chapter05/binutils-pass1.html
./binutils.sh 2.26.1

# 5.5. GCC-6.1.0 - Pass 1
# http://www.linuxfromscratch.org/lfs/view/development/chapter05/gcc-pass1.html
./gcc-initial.sh 6.1.0 mpfr-3.1.4 gmp-6.1.1 mpc-1.0.3

# 5.6. Linux-4.7 API Headers
# http://www.linuxfromscratch.org/lfs/view/development/chapter05/linux-headers.html
./linux-headers.sh 4.7

# 5.7. Glibc-2.24
# http://www.linuxfromscratch.org/lfs/view/development/chapter05/glibc.html
./glibc-initial.sh 2.24

# 5.8. Libstdc++-6.1.0
# http://www.linuxfromscratch.org/lfs/view/development/chapter05/gcc-libstdc++.html
./libstdc++-v3.sh 6.1.0

cd $root
