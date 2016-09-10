#!/bin/bash

set -e
source ./filetree.env

PACKAGE=`basename $0`
PACKAGE=${PACKAGE%.*}
PN=${PACKAGE%-*}
V=${PACKAGE##*-}

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
    --target=${TARGET} \
    --with-lib-path=lib \
    --disable-nls \
    --disable-static \
    --disable-multilib \
    --disable-werror \
    2>&1 | tee configure.log

# make
make 2>&1 | tee make.log

# install
make install 2>&1 | tee install.log

popd

exit 0
