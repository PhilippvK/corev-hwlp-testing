#!/bin/bash


source $(pwd)/scripts/common.sh

SIM=${1:-ovpsim}
BENCH=${2:-all}
ARCH=${3:-rv32im}
MODE=${4:-release}

if [[ "$BENCH" == "all" ]]
then
    # all
    BENCHMARKS=(telecomm/FFT telecomm/CRC32 automotive/susan automotive/basicmath automotive/bitcount automotive/qsort consumer/tiffmedian consumer/tiffdither consumer/jpeg consumer/jpeg/jpeg-6a consumer/tiff2rgba consumer/tiff2bw consumer/tiff-data security/sha security/blowfish security/rijndael network/patricia network/dijkstra office/stringsearch)

else
    # single
    BENCHMARKS=($BENCH)
fi

for bench in "${BENCHMARKS[@]}"
do
    mibench_build $SIM $bench $ARCH $MODE
    read -n 1
done
