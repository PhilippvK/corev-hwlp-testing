#!/bin/bash

source $(pwd)/scripts/common.sh

SIM=${1:-ovpsim}
BENCH=${2:-all}

if [[ "$BENCH" == "all" ]]
then
    # all
    BENCHMARKS=(sequential/anagram sequential/huff_enc sequential/susan sequential/rijndael_enc sequential/rijndael_dec sequential/fmref sequential/h264_dec sequential/gsm_enc sequential/petrinet sequential/statemate sequential/g723_enc sequential/mpeg2 sequential/epic sequential/adpcm_enc sequential/cjpeg_wrbmp sequential/adpcm_dec sequential/ndes sequential/audiobeam sequential/dijkstra sequential/cjpeg_transupp sequential/huff_dec sequential/ammunition sequential/gsm_dec)

else
    # single
    BENCHMARKS=($BENCH)
fi

for bench in "${BENCHMARKS[@]}"
do
    taclebench_dump $SIM $bench
done
