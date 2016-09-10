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
    wget -nc http://ftpmirror.gnu.org/${PN}/${tarball} -P ${DOWNLOADS}
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
    --prefix=${HOST_SYSROOT}/${TARGET} \
    --host=${TARGET} \
    --build=${MACHTYPE} \
    --disable-profile \
    --enable-kernel=3.18.1 \
    --with-headers=${HOST_SYSROOT}/${TARGET}/include \
    libc_cv_forced_unwind=yes \
    libc_cv_ctors_header=yes \
    libc_cv_c_cleanup=yes
    2>&1 | tee configure.log

# make
make 2>&1 | tee make.log

# install
make install 2>&1 | tee install.log

popd
