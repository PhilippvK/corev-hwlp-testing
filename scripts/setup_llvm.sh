#!/bin/bash

set -e

echo "Building llvm from sources..."

CLONE_URL=https://github.com/openhwgroup/corev-llvm-project.git
INSTALL_DIR=$(pwd)/install

if [[ -f "$INSTALL_DIR/llvm/bin/clang" ]]
then
    echo "Already downloaded!"
    exit 0
fi

cd $INSTALL_DIR
test -d llvm/ && rm -r llvm/ || :
test -d llvm_src/ || (git clone $CLONE_URL llvm_src; git -C llvm_src apply ../../extra/corev_llvm.patch)
cmake -B llvm_build -S llvm_src/llvm -DCMAKE_INSTALL_PREFIX=$(pwd)/llvm -DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD="RISCV" -DLLVM_OPTIMIZED_TABLEGEN=ON -DLLVM_ENABLE_ASSERTIONS=OFF -DLLVM_PARALLEL_LINK_JOBS=8 -GNinja -DLLVM_ENABLE_PROJECTS="clang;lld"
cmake --build llvm_build
cmake --install llvm_build
cd -
