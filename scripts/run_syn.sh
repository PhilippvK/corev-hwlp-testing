#!/bin/bash

source $(pwd)/scripts/common.sh

SIM=${1:-ovpsim}
BENCH=${2:-all}
TRACE=${3:-notrace}

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
    syn_run $SIM $bench $TRACE
done
