#!/bin/bash


TACLE_BENCH_DIR=$(pwd)/tacle-bench/bench

BENCH=${1:-all}
ARCH=${2:-rv32im}
# ARCH=${2:-rv32im_xcvmac_xcvmem_xcvalu_xcvbitmanip_xcvsimd_xcvhwlp}

export CLANG=$(pwd)/corev-llvm-project/build/bin/clang
export GCC=$(pwd)/rv32im2_ilp32/bin/riscv32-unknown-elf-gcc
# export OBJDUMP=$(pwd)/corev-openhw-gcc-ubuntu2004-20230504/bin/riscv32-corev-elf-objdump
# export COL=3
export OBJDUMP="$(pwd)/./corev-llvm-project/build/bin/llvm-objdump --mattr=+xcvmac,+xcvmem,+xcvbi,+xcvalu,+xcvbitmanip,+xcvsimd,+xcvhwlp"
export COL=2


function dump() {
    BENCH_NAME=$1
    BENCH_DIR=$TACLE_BENCH_DIR/$BENCH_NAME
    ARCH=$2
    echo "======================="
    echo "Benchmark: $BENCH_NAME"
    echo ""Directory: $BENCH_DIR
    echo "-----------------------"
    cd $BENCH_DIR
    echo "Dumping..."
    echo $OBJDUMP -d program.elf
    $OBJDUMP -d program.elf > program.dump
    cat program.dump | cut -f $COL | sort | uniq -c | sort -h > program.counts
    cat program.counts | grep "cv\." > program.cvcounts
    cat program.cvcounts
    echo "Done."
    echo "======================="
    cd -
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
    dump $bench
done
