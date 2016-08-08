#!/bin/sh

set -e
source ./filetree.env

if [ $# -ne 1 ]; then
    echo Usage: $0 x.y.z
    exit -1
fi

VERSION=$1
shift
PACKAGE=linux-${VERSION}

MAJOR=${VERSION%%\.*}

tarball=${PACKAGE}.tar.xz

# download
if [ ! -e ${DOWNLOADS}/$tarball ]; then
    wget -nc https://www.kernel.org/pub/linux/kernel/v${MAJOR}.x/${tarball} -P ${DOWNLOADS}
fi

# extract
if [ ! -e ${SOURCES}/${PACKAGE} ]; then
    tar xf ${DOWNLOADS}/${tarball} -C ${SOURCES}
fi

# make mrproper
make -C ${SOURCES}/${PACKAGE} mrproper

# make headers_install
make -C ${SOURCES}/${PACKAGE} ARCH=${ARCH} INSTALL_HDR_PATH=${HOST_SYSROOT}/${TARGET} headers_install
mkdir -p ${HOST_SYSROOT}/include
cp -rv ${HOST_SYSROOT}/${TARGET}/include/* ${HOST_SYSROOT}/include

exit 0
