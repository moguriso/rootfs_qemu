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
    wget -nc http://sethwklein.net/${tarball} -P ${DOWNLOADS}
fi

if [ ! -e ${DOWNLOADS}/iana-etc-2.30-update-2.patch ]; then
    wget -nc http://patches.clfs.org/embedded-dev/iana-etc-2.30-update-2.patch -P ${DOWNLOADS}
fi

# extract
if [ ! -e ${SOURCES}/${PACKAGE} ]; then
    tar xf ${DOWNLOADS}/${tarball} -C ${SOURCES}
fi

# patch
if [ ${V} = "2.30" ]; then
    pushd ${SOURCES}/${PACKAGE}
    if ! grep protocol-numbers/protocol-numbers.xml Makefile > /dev/null; then
        patch -Np1 -r - -i ${DOWNLOADS}/iana-etc-2.30-update-2.patch
    fi
    popd
fi

# build dir
mkdir -p ${TARGET_BUILD}/${PACKAGE}
pushd $_

# make get
make -C ${SOURCES}/${PACKAGE} get 2>&1 | tee get.log

# make headers_check
make -C ${SOURCES}/${PACKAGE} ARCH=${ARCH} STRIP=yes 2>&1 | tee make.log

# make headers_install
make -C ${SOURCES}/${PACKAGE} DESTDIR=${TARGET_SYSROOT} install 2>&1 | tee install.log

popd

exit 0
