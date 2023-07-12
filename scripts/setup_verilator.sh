#!/bin/bash

VERILATOR_DIR=$(pwd)/verilator
VERILATOR_INSTALL_DIR=$(pwd)/install/verilator

cd $VERILATOR_DIR

autoconf
./configure --prefix=$VERILATOR_INSTALL_DIR
make -j$(nproc)
make install

cd -
