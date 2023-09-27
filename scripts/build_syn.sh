#!/bin/bash

source $(pwd)/scripts/common.sh

SIM=${1:-ovpsim}
BENCH=${2:-all}
ARCH=${3:-rv32im}
# ARCH=${2:-rv32im_xcvmac_xcvmem_xcvalu_xcvbitmanip_xcvsimd_xcvhwlp}
MODE=${4:-release}

if [[ "$BENCH" == "all" ]]
then
    # all
    BENCHMARKS=(dot32 dot32_hwlp)

else
    # single
    BENCHMARKS=($BENCH)
fi

for bench in "${BENCHMARKS[@]}"
do
    syn_build $SIM $bench $ARCH $MODE
done
