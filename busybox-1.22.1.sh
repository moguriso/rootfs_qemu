#!/bin/sh

set -e
source ./filetree.env

PACKAGE=`basename $0`
PACKAGE=${PACKAGE%.*}
PN=${PACKAGE%-*}
V=${PACKAGE##*-}

tarball=${PACKAGE}.tar.bz2

# download
if [ ! -e ${DOWNLOADS}/${tarball} ]; then
    wget -nc http://busybox.net/downloads/${tarball} -P ${DOWNLOADS}
fi

# extract
if [ ! -e ${SOURCES}/${PACKAGE} ]; then
    tar xf ${DOWNLOADS}/${tarball} -C ${SOURCES}
fi

# build dir
mkdir -p ${TARGET_BUILD}/${PACKAGE}
pushd $_

if [ ! -e Makefile ]; then
    cp -r ${SOURCES}/${PACKAGE}/* .
fi

make distclean

ARCH=${ARCH} make defconfig 2>&1 | tee defconfig.log

sed -i 's/\(CONFIG_\)\(.*\)\(INETD\)\(.*\)=y/# \1\2\3\4 is not set/g' .config
sed -i 's/\(CONFIG_IFPLUGD\)=y/# \1 is not set/' .config
sed -i 's/# \(CONFIG_STATIC\) is not set/\1=y/' .config

ARCH=${ARCH} CROSS_COMPILE=${TARGET}- make 2>&1 | tee make.log

ARCH=${ARCH} CROSS_COMPILE=${TARGET}- make  \
  CONFIG_PREFIX="${TARGET_SYSROOT}" install  2>&1 | tee install.log

cp examples/depmod.pl ${HOST_SYSROOT}/bin
chmod 755 ${HOST_SYSROOT}/bin/depmod.pl
popd

exit 0
