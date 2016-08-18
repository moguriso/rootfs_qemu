#!/bin/sh

set -e
source ./filetree.env

case $1 in
first|second)
    ;;
*)
    echo Usage: $0 first or second
    exit -1
esac

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
mkdir -p ${HOST_BUILD}/${PACKAGE}/${1}
pushd $_

# configure
case $1 in
first)
    ${SOURCES}/${PACKAGE}/configure \
        --prefix=${HOST_SYSROOT} \
        --target=${TARGET} \
        2>&1 | tee configure.log
    ;;
second)
    CC=${TARGET}-gcc \
    AR=${TARGET}-ar \
    RANLIB=${TARGET}-ranlib \
    ${SOURCES}/${PACKAGE}/configure \
        --prefix=${HOST_SYSROOT} \
        --host=${TARGET} \
        --disable-nls \
        --disable-werror \
        --with-lib-path=/lib \
        --with-sysroot \
        2>&1 | tee configure.log
    ;;
*)
    echo Usage: $0 first, second or third
    exit -1
esac

# make
make 2>&1 | tee make.log

# install
make install 2>&1 | tee install.log

popd

exit 0
