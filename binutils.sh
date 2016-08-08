#!/bin/sh

set -e
source ./filetree.env

if [ $# -ne 1 ]; then
    echo Usage: $0 x.yz
    exit -1
fi

VERSION=$1
shift
PACKAGE=binutils-${VERSION}

tarball=${PACKAGE}.tar.gz

# download
if [ ! -e ${DOWNLOADS}/${tarball} ]; then
    wget -nc http://ftpmirror.gnu.org/binutils/${tarball} -P ${DOWNLOADS}
fi

# extract
if [ ! -e ${SOURCES}/${PACKAGE} ]; then
    tar xf ${DOWNLOADS}/${tarball} -C ${SOURCES}
fi

# build dir
mkdir -p ${HOST_BUILD}/${PACKAGE}
pushd $_

# configure
${SOURCES}/${PACKAGE}/configure \
    --prefix=${HOST_SYSROOT} \
    --with-sysroot=${HOST_SYSROOT} \
    --with-lib-path=${HOST_SYSROOT}/lib \
    --target=${TARGET} \
    --disable-nls \
    --disable-werror \
    2>&1 | tee configure.log

# make
make 2>&1 | tee make.log

# install
make install 2>&1 | tee install.log

popd

exit 0
