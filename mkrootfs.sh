#!/bin/sh

set -e
source ./filetree.env

pushd ${HOST_SYSROOT}/${TARGET}

mkdir -p ${TARGET_SYSROOT}/lib/
cp -a lib/libc.so* lib/libc-*.so lib/ld-*.so lib/ld-linux.so* lib/libm.so* lib/libm-*.so ${TARGET_SYSROOT}/lib/
mkdir -p ${TARGET_SYSROOT}/sbin/
cp -a sbin/ldconfig  ${TARGET_SYSROOT}/sbin/

popd

pushd ${TARGET_SYSROOT}

find . | cpio -o --format=newc --owner=root:root > ${IMAGES}/initrd
gzip -c ${IMAGES}/initrd > ${IMAGES}/initrd.gz

popd

cp ${TARGET_BUILD}/linux-*/arch/arm/boot/zImage ${IMAGES}

exit 0
