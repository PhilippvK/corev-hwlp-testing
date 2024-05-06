#!/bin/bash

set -e

echo "Building gcc from sources..."

CLONE_URL=https://github.com/riscv-collab/riscv-gnu-toolchain.git
GNU_REF=2023.03.14
INSTALL_DIR=$(pwd)/install

if [[ -f "$INSTALL_DIR/rv32im_ilp32/bin/riscv32-unknown-elf-gcc" ]]
then
    echo "Already downloaded!"
    exit 0
fi

cd $INSTALL_DIR
test -d rv32im_ilp32/ && rm -r rv32im_ilp32/ || :
test -d gcc_src/ || git clone $CLONE_URL gcc_src
git -C gcc_src/ checkout $GNU_REF
mkdir -p gcc_build
cd gcc_build
../gcc_src/configure --prefix=$INSTALL_DIR/rv32im_ilp32 --with-arch=rv32im --with-abi=ilp32
make -j`nproc`
cd ../..
