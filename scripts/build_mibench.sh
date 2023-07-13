#!/bin/bash


source $(pwd)/scripts/common.sh

SIM=${1:-ovpsim}
BENCH=${2:-all}
ARCH=${3:-rv32im}
MODE=${4:-release}

if [[ "$BENCH" == "all" ]]
then
    # all
    BENCHMARKS=(telecomm/FFT telecomm/CRC32 automotive/susan automotive/basicmath automotive/bitcount automotive/qsort security/sha security/rijndael network/dijkstra office/stringsearch)
else
    # single
    BENCHMARKS=($BENCH)
fi

for bench in "${BENCHMARKS[@]}"
do
    mibench_build $SIM $bench $ARCH $MODE
done
