#!/bin/sh

set -e
source ./filetree.env

case $1 in
first|second|third)
    ;;
*)
    echo Usage: $0 first, second or third
    exit -1
esac

PACKAGE=`basename $0`
PACKAGE=${PACKAGE%.*}
PN=${PACKAGE%-*}
V=${PACKAGE##*-}

tarball=${PACKAGE}.tar.gz

# download
if [ ! -e ${DOWNLOADS}/${tarball} ]; then
    wget -nc http://ftpmirror.gnu.org/gcc/${PACKAGE}/${tarball} -P ${DOWNLOADS}
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
        --target=${TARGET} \
        --prefix=${HOST_SYSROOT} \
        --with-newlib \
        --without-headers \
        --disable-nls \
        --disable-shared \
        --disable-multilib \
        --disable-decimal-float \
        --disable-threads \
        --disable-libatomic \
        --disable-libgomp \
        --disable-libitm \
        --disable-libquadmath \
        --disable-libsanitizer \
        --disable-libssp \
        --disable-libvtv \
        --disable-libcilkrts \
        --disable-libstdc++-v3 \
        --enable-languages=c,c++ \
        2>&1 | tee configure.log
    ;;
second)
# configure
    ${SOURCES}/${PACKAGE}/libstdc++-v3/configure \
        --target=${TARGET} \
        --prefix=${HOST_SYSROOT}/${TARGET} \
        --disable-multilib \
        --disable-shared \
        --disable-nls \
        --disable-libstdcxx-threads \
        --disable-libstdcxx-pch \
        --with-gxx-include-dir=/${HOST_SYSROOT}/${TARGET}/include/c++/${VERSION} \
        2>&1 | tee configure.log
    ;;
third)
    ${SOURCES}/${PACKAGE}/configure \
        --target=${TARGET} \
        --prefix=${HOST_SYSROOT} \
        --disable-nls \
        --disable-shared \
        --disable-multilib \
        --disable-threads \
        --disable-libgomp \
        --enable-languages=c,c++ \
        --disable-libstdcxx-pch \
        --disable-bootstrap \
        2>&1 | tee configure.log
    ;;
esac

# make
make 2>&1 | tee make.log

# install
make install 2>&1 | tee install.log

popd

exit 0
