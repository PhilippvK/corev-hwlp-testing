#!/bin/bash

set -e

DL_URL=https://github.com/openhwgroup/riscv-ovpsim-corev/archive/refs/heads/v20230724.zip

INSTALL_DIR=$(pwd)/install

if [[ -f "$INSTALL_DIR/ovpsim/bin/Linux64/riscvOVPsimCOREV.exe" ]]
then
    echo "Already downloaded!"
    exit 0
fi

cd $INSTALL_DIR
test -d ovpsim/ && rm -r ovpsim/ || :
wget $DL_URL -O ovpsim.zip
unzip ovpsim.zip -d ovpsim_
rm ovpsim.zip
mv ovpsim_/* ovpsim
rmdir ovpsim_
cd -
