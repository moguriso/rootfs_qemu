#!/bin/bash

set -e
source ./filetree.env

PACKAGE=`basename $0`
PACKAGE=${PACKAGE%.*}
PN=${PACKAGE%-*}
V=${PACKAGE##*-}

tarball=${PACKAGE}.tar.xz

# download
if [ ! -e ${DOWNLOADS}/${tarball} ]; then
    wget -nc http://ftpmirror.gnu.org/gdb/${tarball} -P ${DOWNLOADS}
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
    --target=${TARGET} \
    --prefix=${HOST_SYSROOT} \
    --with-python=no
    2>&1 | tee configure.log

# make
make 2>&1 | tee make.log

# install
make install 2>&1 | tee install.log

popd

exit 0
