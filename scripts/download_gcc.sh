#!/bin/bash

set -e

DL_URL=https://syncandshare.lrz.de/dl/fiWBtDLWz17RBc1Yd4VDW7/GCC/default/rv32im_ilp32.tar.xz

INSTALL_DIR=$(pwd)/install

if [[ -f "$INSTALL_DIR/rv32im_ilp32/bin/riscv32-unknown-elf-gcc" ]]
then
    echo "Already downloaded!"
    exit 0
fi

cd $INSTALL_DIR
test -d rv32im_ilp32/ && rm -r rv32im_ilp32/ || :
wget $DL_URL -O rv32im_ilp32.tar.xz
mkdir -p rv32im_ilp32/
tar xvf rv32im_ilp32.tar.xz -C rv32im_ilp32/ --strip-components=1
rm rv32im_ilp32.tar.xz
cd -
