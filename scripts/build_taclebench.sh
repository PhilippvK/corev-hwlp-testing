#!/bin/bash


TACLE_BENCH_DIR=$(pwd)/tacle-bench/bench
EXTRA_DIR=$(pwd)/extra

SIM=${1:-ovpsim}
BENCH=${2:-all}
ARCH=${3:-rv32im}
# ARCH=${2:-rv32im_xcvmac_xcvmem_xcvalu_xcvbitmanip_xcvsimd_xcvhwlp}

DEFAULT_CLANG=$(pwd)/install/llvm/bin/clang
export CLANG=${CLANG:-$DEFAULT_CLANG}
DEFAULT_GCC=$(pwd)/install/rv32im_ilp32/bin/riscv32-unknown-elf-gcc
export GCC=${GCC:-$DEFAULT_GCC}
export GCC_TOOLCHAIN=$(dirname $(dirname $GCC))
export SYSROOT=$GCC_TOOLCHAIN/$(basename $GCC | cut -d- -f1-3)
# export GCC=$(pwd)/corev-openhw-gcc-ubuntu2004-20230504/bin/riscv32-corev-elf-gcc
# export GCC_TOOLCHAIN=$(pwd)/corev-openhw-gcc-ubuntu2004-20230504/
# export SYSROOT=$(pwd)/corev-openhw-gcc-ubuntu2004-20230504/riscv32-corev-elf

function common_build() {
    SIM=$1
    BENCH_NAME=$2
    BENCH_DIR=$TACLE_BENCH_DIR/$BENCH_NAME
    ARCH=$3
    echo "======================="
    echo "Benchmark: $BENCH_NAME"
    echo "Directory: $BENCH_DIR"
    echo "Simulator: $SIM"
    echo "-----------------------"
    cd $BENCH_DIR
    echo "Compiling..."
    $CLANG *.c -march=$ARCH -mabi=ilp32 -O3 -c --target=riscv32 --gcc-toolchain=$GCC_TOOLCHAIN --sysroot=$SYSROOT
    echo "Linking..."
    ${SIM}_link
    echo "Done."
    echo "======================="
    cd - > /dev/null
}

function ovpsim_link() {
    $GCC *.o -o ovpsim.elf
}

function etiss_link() {
    $GCC $EXTRA_DIR/crt0.S $EXTRA_DIR/trap_handler.c --specs=$EXTRA_DIR/etiss-semihost.specs -T $EXTRA_DIR/etiss.ld *.o -march=rv32im_zicsr -nostdlib -lc -lsemihost -lgcc -o etiss.elf
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
    common_build $SIM $bench $ARCH
done
