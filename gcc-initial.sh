#!/bin/sh

set -e
source ./filetree.env

if [ $# -ne 4 ]; then
    echo Usage: $0 x.y.z mpfr-x.y.z gmp-x.y.z mpc-x.y.z
    exit -1
fi

VERSION=$1
mpfr=$2
gmp=$3
mpc=$4

PACKAGE=gcc-${VERSION}

tarball=${PACKAGE}.tar.gz

# download
if [ ! -e ${DOWNLOADS}/${tarball} ]; then
    wget -nc http://ftpmirror.gnu.org/gcc/${PACKAGE}/${tarball} -P ${DOWNLOADS}
fi

if [ ! -e ${DOWNLOADS}/${mpfr}.tar.xz ]; then
    wget -nc http://ftpmirror.gnu.org/mpfr/${mpfr}.tar.xz -P ${DOWNLOADS}
fi

if [ ! -e ${DOWNLOADS}/${gmp}.tar.xz ]; then
    wget -nc http://ftpmirror.gnu.org/gmp/${gmp}.tar.xz -P ${DOWNLOADS}
fi

if [ ! -e ${DOWNLOADS}/${mpc}.tar.gz ]; then
    wget -nc http://ftpmirror.gnu.org/mpc/${mpc}.tar.gz -P ${DOWNLOADS}
fi

# extract
if [ ! -e ${SOURCES}/${PACKAGE} ]; then
    tar xf ${DOWNLOADS}/${tarball} -C ${SOURCES}
fi

pushd ${SOURCES}/${PACKAGE}

if [ ! -e mpfr ]; then
    tar xf ${DOWNLOADS}/${mpfr}.tar.xz -C .
    ln -snf ${mpfr} mpfr
fi

if [ ! -e gmp ]; then
    tar xf ${DOWNLOADS}/${gmp}.tar.xz -C .
    ln -snf ${gmp} gmp
fi

if [ ! -e mpc ]; then
    tar xf ${DOWNLOADS}/${mpc}.tar.gz -C .
    ln -snf ${mpc} mpc
fi

echo $PWD

for file in \
 $(find gcc/config -name linux64.h -o -name linux.h -o -name sysv4.h)
do
  if [ ! -e $file.orig ]; then
      cp -uv $file{,.orig}
      sed -e "s@/lib\(64\)\?\(32\)\?/ld@${HOST_SYSROOT}&@g" \
          -e "s@/usr@${HOST_SYSROOT}@g" $file.orig > $file
      echo "
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 \"${HOST_SYSROOT}/lib/\"
#define STANDARD_STARTFILE_PREFIX_2 \"\"" >> $file
      touch $file.orig
  fi
done

popd

# build dir
mkdir -p ${HOST_BUILD}/gcc-initial-${VERSION}
pushd $_

# configure
${SOURCES}/${PACKAGE}/configure \
    --prefix=${HOST_SYSROOT} \
    --target=${TARGET} \
    --with-glibc-version=2.11 \
    --with-sysroot=${HOST_SYSROOT} \
    --with-newlib \
    --without-headers \
    --with-local-prefix=${HOST_SYSROOT} \
    --with-native-system-header-dir=${HOST_SYSROOT}/include \
    --disable-nls \
    --disable-shared \
    --disable-multilib \
    --disable-decimal-float \
    --disable-threads \
    --disable-libatomic \
    --disable-libgomp \
    --disable-libmpx \
    --disable-libquadmath \
    --disable-libssp \
    --disable-libvtv \
    --disable-libstdcxx \
    --enable-languages=c,c++ \
    2>&1 | tee configure.log

# make
make 2>&1 | tee make.log

# install
make install 2>&1 | tee install.log

popd

exit 0
