#!/bin/bash

set -e
source ./filetree.env

PACKAGE=`basename $0`
PACKAGE=${PACKAGE%.*}
PN=${PACKAGE%-*}
V=${PACKAGE##*-}

# extract
if [ ! -e ${SOURCES}/${PACKAGE} ]; then
    mkdir ${SOURCES}/${PACKAGE}
    cat > ${SOURCES}/${PACKAGE}/main.cpp << "EOF"
#include <iostream>

int main(int argc, char **argv)
{
    std::cout << "test" << std::endl;
    return 0;
}
EOF

fi

# build dir
mkdir -p ${HOST_BUILD}/${PACKAGE}
pushd $_

# make
arm-linux-gnueabi-g++ -o test ${SOURCES}/${PACKAGE}/main.cpp 2>&1 | tee make.log

# install
cp test ${TARGET_SYSROOT} 2>&1 | tee install.log

popd

exit 0
