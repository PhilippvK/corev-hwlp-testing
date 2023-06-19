#!/bin/bash

set -e

DL_URL=https://syncandshare.lrz.de/dl/fiFUYGac2R8AXSGrvxSXx2/llvm.tar.xz

INSTALL_DIR=$(pwd)/install

if [[ -f "$INSTALL_DIR/llvm/bin/clang" ]]
then
    echo "Already downloaded!"
    exit 0
fi

cd $INSTALL_DIR
test -d llvm/ && rm -r llvm/ || :
wget $DL_URL -O llvm.tar.xz
mkdir -p llvm/
tar xvf llvm.tar.xz -C llvm/ --strip-components=1
rm llvm.tar.xz
cd -
