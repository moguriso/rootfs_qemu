#!/bin/sh

set -e
source ./filetree.env

if [ $# -ne 1 ]; then
    echo Usage: $0 x.y.z
    exit -1
fi

VERSION=$1
shift
PACKAGE=gcc-${VERSION}

# build dir
mkdir -p ${HOST_BUILD}/libstdc++-v3-${VERSION}
pushd $_

# configure
${SOURCES}/${PACKAGE}/libstdc++-v3/configure \
    --host=${TARGET} \
    --prefix=${HOST_SYSROOT} \
    --disable-libstdcxx-threads \
    --disable-libstdcxx-pch \
    --with-gxx-include-dir=/${HOST_SYSROOT}/include/c++/${VERSION} \
    ${CONFIGURE_ARGS} \
    2>&1 | tee configure.log

# make
make 2>&1 | tee make.log

# install
make install 2>&1 | tee install.log

popd
