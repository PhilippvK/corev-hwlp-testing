#!/bin/bash


export EXAMPLES_DIR=$(pwd)/examples

SIM=${1:-ovpsim}
BENCH=${2:-all}
ARCH=${3:-rv32im}
# ARCH=${2:-rv32im_xcvmac_xcvmem_xcvalu_xcvbitmanip_xcvsimd_xcvhwlp}
MODE=${4:-release}

DEFAULT_CLANG=$(pwd)/install/llvm/bin/clang
export CLANG=${CLANG:-$DEFAULT_CLANG}
DEFAULT_GCC=$(pwd)/install/rv32im_ilp32/bin/riscv32-unknown-elf-gcc
export GCC=${GCC:-$DEFAULT_GCC}
DEFAULT_OBJCOPY=$(pwd)/install/rv32im_ilp32/bin/riscv32-unknown-elf-objcopy
export OBJCOPY=${OBJCOPY:-$DEFAULT_OBJCOPY}
export GCC_TOOLCHAIN=$(dirname $(dirname $GCC))
export SYSROOT=$GCC_TOOLCHAIN/$(basename $GCC | cut -d- -f1-3)
# export GCC=$(pwd)/corev-openhw-gcc-ubuntu2004-20230504/bin/riscv32-corev-elf-gcc
# export GCC_TOOLCHAIN=$(pwd)/corev-openhw-gcc-ubuntu2004-20230504/
# export SYSROOT=$(pwd)/corev-openhw-gcc-ubuntu2004-20230504/riscv32-corev-elf
COREVVERIF_DIR=$(pwd)/core-v-verif
export CV32E40P_SW_DIR=$COREVVERIF_DIR/cv32e40p/bsp

function common_build() {
    SIM=$1
    BENCH_NAME=$2
    BENCH_DIR=$EXAMPLES_DIR/$BENCH_NAME
    ARCH=$3
    MODE=$4
    echo "======================="
    echo "Benchmark: $BENCH_NAME"
    echo "Directory: $BENCH_DIR"
    echo "Simulator: $SIM"
    echo "-----------------------"
    cd $BENCH_DIR
    EXTRA_ARGS=""
    if [[ "$MODE" == "release" ]]
    then
        OPT="3"
    elif [[ "$MODE" == "size" ]]
    then
        OPT="s"
    elif [[ "$MODE" == "debug" ]]
    then
        OPT="0"
        EXTRA_ARGS="$EXTRA_ARGS -g"
    else
        echo "Invalid mode: $MODE"
        return 1
    fi
    echo "Compiling..."
    # if [[ "$SIM" == "cv32e40p" ]]
    # then
    #     echo "TODO"
    #     return 2
    # else
        echo $CLANG *.c -march=$ARCH -mabi=ilp32 -O$OPT -c --target=riscv32 --gcc-toolchain=$GCC_TOOLCHAIN --sysroot=$SYSROOT $EXTRA_ARGS
        $CLANG *.c -march=$ARCH -mabi=ilp32 -O$OPT -c --target=riscv32 --gcc-toolchain=$GCC_TOOLCHAIN --sysroot=$SYSROOT $EXTRA_ARGS
    # fi
    echo "Linking..."
    ${SIM}_link
    echo "Hexdumping..."
    $OBJCOPY -O verilog $SIM.elf $SIM.elf.hex
    echo "Done."
    echo "======================="
    cd - > /dev/null
}

function cv32e40p_link() {
    $GCC ${CV32E40P_SW_DIR}/crt0.S ${CV32E40P_SW_DIR}/syscalls.c ${CV32E40P_SW_DIR}/vectors.S ${CV32E40P_SW_DIR}/handlers.S *.o -o cv32e40p.elf -march=rv32im_zicsr -T $CV32E40P_SW_DIR/link.ld -nostartfiles
}

function ovpsim_link() {
    echo $GCC *.o -o ovpsim.elf
    $GCC *.o -o ovpsim.elf
}

function etiss_link() {
    $GCC $EXTRA_DIR/crt0.S $EXTRA_DIR/trap_handler.c --specs=$EXTRA_DIR/etiss-semihost.specs -T $EXTRA_DIR/etiss.ld *.o -march=rv32im_zicsr -nostdlib -lc -lsemihost -lgcc -o etiss.elf
}

if [[ "$BENCH" == "all" ]]
then
    # all
    BENCHMARKS=(hello_world matmult matmult_div matmult_div2)

else
    # single
    BENCHMARKS=($BENCH)
fi

for bench in "${BENCHMARKS[@]}"
do
    common_build $SIM $bench $ARCH $MODE
done
