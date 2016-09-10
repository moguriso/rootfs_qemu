#!/bin/bash

set -e
source ./filetree.env

case $1 in
header|kernel)
    ;;
*)
    echo Usage: $0 header or kernel
    exit -1
esac

PACKAGE=`basename $0`
PACKAGE=${PACKAGE%.*}
PN=${PACKAGE%-*}
V=${PACKAGE##*-}
MAJOR=${V%%\.*}
NPROC=`nproc`

tarball=${PACKAGE}.tar.xz

# download
if [ ! -e ${DOWNLOADS}/$tarball ]; then
    wget -nc https://www.kernel.org/pub/linux/kernel/v${MAJOR}.x/${tarball} -P ${DOWNLOADS}
fi

# extract
if [ ! -e ${SOURCES}/${PACKAGE} ]; then
    tar xf ${DOWNLOADS}/${tarball} -C ${SOURCES}
fi

# build dir
case $1 in
header)
    mkdir -p ${HOST_BUILD}/${PACKAGE}/
    pushd $_
    ;;
kernel)
    mkdir -p ${TARGET_BUILD}/${PACKAGE}/
    pushd $_
    ;;
esac

# copy source
cp -r ${SOURCES}/${PACKAGE}/* .

# make mrproper
make mrproper 2>&1 | tee mrproper.log

case $1 in
header)
    # make headers_check
    make ARCH=${ARCH} headers_check 2>&1 | tee headers_check.log

    # make headers_install
    make ARCH=${ARCH} INSTALL_HDR_PATH=${HOST_SYSROOT}/${TARGET} headers_install 2>&1 | tee headers_install.log
    ;;
kernel)
    # make menu config
    make ARCH=${ARCH} CROSS_COMPILE=${TARGET}- versatile_defconfig
#    make ARCH=${ARCH} CROSS_COMPILE=${TARGET}- menuconfig

    # make
    make ARCH=${ARCH} -j${NPROC} CROSS_COMPILE=${TARGET}- 2>&1 | tee make.log

    # install
    make ARCH=${ARCH} CROSS_COMPILE=${TARGET}- INSTALL_MOD_PATH=${TARGET_SYSROOT} modules_install 2>&1 | tee modules_install.log
    make ARCH=${ARCH} CROSS_COMPILE=${TARGET}- INSTALL_MOD_PATH=${TARGET_SYSROOT} firmware_install 2>&1 | tee firmware_install.log
    ;;
esac

popd

exit 0
