#!/bin/bash


TACLE_BENCH_DIR=$(pwd)/tacle-bench/bench

SIM=${1:-ovpsim}
BENCH=${2:-all}

export CLANG=$(pwd)/corev-llvm-project/build/bin/clang
export GCC=$(pwd)/rv32im2_ilp32/bin/riscv32-unknown-elf-gcc
# export OBJDUMP=$(pwd)/corev-openhw-gcc-ubuntu2004-20230504/bin/riscv32-corev-elf-objdump
# export COL=3
export OBJDUMP="$(pwd)/./corev-llvm-project/build/bin/llvm-objdump --mattr=+xcvmac,+xcvmem,+xcvbi,+xcvalu,+xcvbitmanip,+xcvsimd,+xcvhwlp"
export COL=2


function dump() {
    SIM=$1
    BENCH_NAME=$2
    BENCH_DIR=$TACLE_BENCH_DIR/$BENCH_NAME
    echo "======================="
    echo "Benchmark: $BENCH_NAME"
    echo "Directory: $BENCH_DIR"
    echo "Simulator: $SIM"
    echo "-----------------------"
    cd $BENCH_DIR
    echo "Dumping..."
    $OBJDUMP -d $SIM.elf > $SIM.dump
    cat $SIM.dump | cut -f $COL | grep -v "<" | grep -v "Disassembly" | grep -v "file format" | sed '/^$/d' | sort | uniq -c | sort -h > $SIM.counts
    cat $SIM.counts | grep "cv\." > $SIM.cvcounts
    cat $SIM.cvcounts
    echo "Done."
    echo "======================="
    cd - > /dev/null
}

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
    dump $SIM $bench
done
