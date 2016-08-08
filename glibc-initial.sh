#!/bin/sh

set -e
source ./filetree.env

if [ $# -ne 1 ]; then
    echo Usage: $0 x.y.z
    exit -1
fi

VERSION=$1
shift
PACKAGE=glibc-${VERSION}

tarball=${PACKAGE}.tar.xz

# download
if [ ! -e ${DOWNLOADS}/$tarball ]; then
    wget -nc http://ftpmirror.gnu.org/glibc/${tarball} -P ${DOWNLOADS}
fi

# extract
if [ ! -e ${SOURCES}/${PACKAGE} ]; then
    tar xf ${DOWNLOADS}/${tarball} -C ${SOURCES}
fi

# build dir
mkdir -p ${HOST_BUILD}/glibc-initial-${VERSION}
pushd $_

# configure
${SOURCES}/${PACKAGE}/configure \
    --prefix=${HOST_SYSROOT} \
    --host=${TARGET} \
    --build=${MACHTYPE} \
    --target=${TARGET} \
    --enable-kernel=4.7 \
    --with-headers=${HOST_SYSROOT}/include \
    libc_cv_forced_unwind=yes \
    libc_cv_ctors_header=yes \
    libc_cv_c_cleanup=yes \
    ${CONFIGURE_ARGS} 2>&1 | tee configure.log

# make
make 2>&1 | tee make.log
#make install-bootstrap-headers=yes install-headers
#make -j4 csu/subdir_lib

# install
make install 2>&1 | tee install.log
#install csu/ctr1.o csu/crti.o csu/crtn.o ${HOST_SYSROOT}/lib
#${TARGET}-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o ${HOST_SYSROOT}/${TARGET}/lib/libc.so
#touch ${HOST_SYSROOT}/${TARGET}/include/gnu/stubs.h

popd
