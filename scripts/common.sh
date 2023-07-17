#!/bin/bash

export DIR=$(pwd)
export SCRIPTS_DIR=$DIR
export TACLE_BENCH_DIR=$DIR/tacle-bench/bench
export EXTRA_DIR=$DIR/extra

export DEFAULT_CLANG=$DIR/install/llvm/bin/clang
export CLANG=${CLANG:-$DEFAULT_CLANG}
export DEFAULT_GCC=$DIR/install/rv32im_ilp32/bin/riscv32-unknown-elf-gcc
export GCC=${GCC:-$DEFAULT_GCC}
export DEFAULT_OBJCOPY=$DIR/install/rv32im_ilp32/bin/riscv32-unknown-elf-objcopy
export OBJCOPY=${OBJCOPY:-$DEFAULT_OBJCOPY}
export DEFAULT_SIZE=$DIR/install/rv32im_ilp32/bin/riscv32-unknown-elf-size
export SIZE=${SIZE:-$DEFAULT_SIZE}
export GCC_TOOLCHAIN=$(dirname $(dirname $GCC))
export SYSROOT=$GCC_TOOLCHAIN/$(basename $GCC | cut -d- -f1-3)
# export GCC=$DIR/corev-openhw-gcc-ubuntu2004-20230504/bin/riscv32-corev-elf-gcc
# export GCC_TOOLCHAIN=$DIR/corev-openhw-gcc-ubuntu2004-20230504/
# export SYSROOT=$DIR/corev-openhw-gcc-ubuntu2004-20230504/riscv32-corev-elf
export COREVVERIF_DIR=$DIR/core-v-verif
export CV32E40P_SW_DIR=$COREVVERIF_DIR/cv32e40p/bsp
export DEFAULT_OVPSIM=$DIR/install/ovpsim/bin/Linux64/riscvOVPsimCOREV.exe
export OVPSIM=${OVPSIM:-$DEFAULT_OVPSIM}
export DEFAULT_ETISS_INI=$EXTRA_DIR/memsegs.ini
export ETISS_INI=${ETISS_INI:-$DEFAULT_ETISS_INI}
export EXAMPLES_DIR=$DIR/examples
export POLYBENCH_DIR=$DIR/polybench
export MIBENCH_DIR=$DIR/mibench
export COREMARK_DIR=$DIR/coremark
export DEFAULT_OBJDUMP=$DIR/install/llvm/bin/llvm-objdump
export OBJDUMP_ARGS="--mattr=+xcvmac,+xcvmem,+xcvbi,+xcvalu,+xcvbitmanip,+xcvsimd,+xcvhwlp"
export OBJDUMP=${OBJDUMP:-$DEFAULT_OBJDUMP}
export OBJDUMP_COL=${OBJDUMP_COL:-2}


export ETISS_ARGS=${ETISS_ARGS:-""}
export OVPSIM_ARGS=${OVPSIM_ARGS:-""}
export COMPILE_ARGS=${COMPILE_ARGS:-""}

export PRINT=${PRINT:-0}
export VERBOSE=${VERBOSE:-0}

if [[ "$VERBOSE" == "1" ]]
then
    set -x
fi

function print_head() {
    BENCHMARK=$1
    BENCH_NAME=$2
    BENCH_DIR=$3
    SIM=$4
    EXTRA=$5

    echo "======================="
    echo "Bechmark:  $BENCHMARK"
    echo "Program:   $BENCH_NAME"
    echo "Directory: $BENCH_DIR"
    echo "Simulator: $SIM"
    echo "Details:   $EXTRA"
    echo "-----------------------"
}

function mibench_dump() {
    SIM=$1
    BENCH_NAME=$2
    BENCH_DIR=$POLYBENCH_DIR/$BENCH_NAME
    print_head mibench $BENCH_NAME $BENCH_DIR $SIM
    cd $BENCH_DIR
    common_dump $@
    cd - > /dev/null
}

function coremark_dump() {
    SIM=$1
    BENCH_DIR=$COREMARK_DIR
    print_head coremark - $BENCH_DIR $SIM
    cd $BENCH_DIR
    common_dump $@
    cd - > /dev/null
}

function polybench_dump() {
    SIM=$1
    BENCH_NAME=$2
    BENCH_DIR=$POLYBENCH_DIR/$BENCH_NAME
    print_head polybench $BENCH_NAME $BENCH_DIR $SIM
    cd $BENCH_DIR
    common_dump $@
    cd - > /dev/null
}

function taclebench_dump() {
    SIM=$1
    BENCH_NAME=$2
    BENCH_DIR=$TACLE_BENCH_DIR/$BENCH_NAME
    print_head taclebench $BENCH_NAME $BENCH_DIR $SIM
    cd $BENCH_DIR
    common_dump $@
    cd - > /dev/null
}

function examples_dump() {
    SIM=$1
    BENCH_NAME=$2
    BENCH_DIR=$EXAMPLES_DIR/$BENCH_NAME
    print_head examples $BENCH_NAME $BENCH_DIR $SIM
    cd $BENCH_DIR
    common_dump $@
    cd - > /dev/null
}

function common_dump() {
    SIM=$1
    BENCH_NAME=$2
    echo "Dumping..."
    $OBJDUMP $OBJDUMP_ARGS -d $SIM.elf > $SIM.dump
    echo "Counting..."
    cat $SIM.dump | cut -f $OBJDUMP_COL | grep -v "<" | grep -v "Disassembly" | grep -v "file format" | sed '/^$/d' | sort | uniq -c | sort -h > $SIM.counts
    cat $SIM.counts | grep "cv\." > $SIM.cvcounts
    cat $SIM.cvcounts
}

function coremark_build() {
    SIM=$1
    ARCH=$2
    MODE=$3
    BENCH_DIR=$COREMARK_DIR/
    print_head coremark - $BENCH_DIR $SIM ${ARCH}_${MODE}
    cd $BENCH_DIR
    common_build $SIM $ARCH $MODE *.c -I$EXTRA_DIR -DITERATIONS=10 -DPERFORMANCE_RUN -DHAS_STDIO -DFLAGS_STR $EXTRA_DIR/core_portme.c -I$BENCH_DIR
    cd - > /dev/null
}

function taclebench_build() {
    SIM=$1
    BENCH_NAME=$2
    ARCH=$3
    MODE=$4
    BENCH_DIR=$TACLE_BENCH_DIR/$BENCH_NAME
    print_head taclebench $BENCH_NAME $BENCH_DIR $SIM ${ARCH}_${MODE}
    cd $BENCH_DIR
    common_build $SIM $ARCH $MODE *.c
    cd - > /dev/null
}

function polybench_build() {
    SIM=$1
    BENCH_NAME=$2
    ARCH=$3
    MODE=$4
    BENCH_DIR=$POLYBENCH_DIR/$BENCH_NAME
    print_head polybench $BENCH_NAME $BENCH_DIR $SIM ${ARCH}_${MODE}
    cd $BENCH_DIR
    common_build $SIM $ARCH $MODE -I $POLYBENCH_DIR/utilities -I $BENCH_DIR $POLYBENCH_DIR/utilities/polybench.c
    cd - > /dev/null
    # utilities/polybench.c
}

function mibench_build() {
    SIM=$1
    BENCH_NAME=$2
    ARCH=$3
    MODE=$4
    BENCH_DIR=$MIBENCH_DIR/$BENCH_NAME
    print_head mibench $BENCH_NAME $BENCH_DIR $SIM ${ARCH}_${MODE}
    cd $BENCH_DIR
    SRCS=$(find . -maxdepth 1 -name "*.c" -not -name "*_large*")
    common_compile $SIM $ARCH $MODE $SRCS -Wno-implicit-int -Wno-implicit-function-declaration
    common_link $SIM *.o -o $SIM.elf
    common_hexdump $SIM.elf $SIM.elf.hex
    common_size $SIM.elf ${SIM}_size.txt
    cd - > /dev/null
}

function examples_build() {
    SIM=$1
    BENCH_NAME=$2
    ARCH=$3
    MODE=$4
    BENCH_DIR=$EXAMPLES_DIR/$BENCH_NAME
    print_head examples $BENCH_NAME $BENCH_DIR $SIM ${ARCH}_${MODE}
    cd $BENCH_DIR
    common_build $SIM $ARCH $MODE
    cd - > /dev/null
}

function common_size() {
    ELF=$1
    OUT=$2
    $SIZE $ELF > $OUT
}

function common_build() {
    SIM=$1
    ARCH=$2
    MODE=$3
    shift 3
    common_compile $SIM $ARCH $MODE *.c $@
    common_link $SIM *.o -o $SIM.elf
    common_hexdump $SIM.elf $SIM.elf.hex
    common_size $SIM.elf ${SIM}_size.txt
}

function common_compile() {
    SIM=$1
    ARCH=$2
    MODE=$3
    shift 3
    EXTRA_ARGS=$COMPILE_ARGS
    if [[ "$MODE" == "release" ]]
    then
        OPT="3"
    elif [[ "$MODE" == "size" ]]
    then
        OPT="s"
    elif [[ "$MODE" == "debug" ]]
    then
        OPT="0"
        # EXTRA_ARGS="$EXTRA_ARGS -g"
    else
        echo "Invalid mode: $MODE"
        return 1
    fi
    echo "Compiling..."
    $CLANG -march=$ARCH -mabi=ilp32 -O$OPT -c --target=riscv32 --gcc-toolchain=$GCC_TOOLCHAIN --sysroot=$SYSROOT $EXTRA_ARGS -g $@
}

function common_link() {
    SIM=$1
    shift
    echo "Linking..."
    ${SIM}_link -march=rv32im_zicsr $@ -lm -lc
}

function common_hexdump() {
    echo "Hexdumping..."
    $OBJCOPY -O verilog $@
}


function cv32e40p_link() {
    $GCC ${CV32E40P_SW_DIR}/crt0.S ${CV32E40P_SW_DIR}/syscalls.c ${CV32E40P_SW_DIR}/vectors.S ${CV32E40P_SW_DIR}/handlers.S -T $CV32E40P_SW_DIR/link.ld -nostartfiles $@
}

function ovpsim_link() {
    $GCC $@
}

function etiss_link() {
    $GCC $EXTRA_DIR/crt0.S $EXTRA_DIR/trap_handler.c --specs=$EXTRA_DIR/etiss-semihost.specs -T $EXTRA_DIR/etiss.ld -nostdlib -lc -lsemihost -lgcc $@
}

coremark_run() {
    SIM=$1
    TRACE=$2
    BENCH_DIR=$COREMARK_DIR/
    print_head coremark - $BENCH_DIR $SIM ${TRACE}
    cd $BENCH_DIR
    common_run $SIM $TRACE
    cd - > /dev/null
}

polybench_run() {
    SIM=$1
    BENCH_NAME=$2
    TRACE=$3
    BENCH_DIR=$POLYBENCH_DIR/$BENCH_NAME
    print_head polybench $BENCH_NAME $BENCH_DIR $SIM ${TRACE}
    cd $BENCH_DIR
    common_run $SIM $TRACE
    cd - > /dev/null
}

mibench_run() {
    SIM=$1
    BENCH_NAME=$2
    TRACE=$3
    BENCH_DIR=$MIBENCH_DIR/$BENCH_NAME
    print_head mibench $BENCH_NAME $BENCH_DIR $SIM ${TRACE}
    cd $BENCH_DIR
    common_run $SIM $TRACE
    cd - > /dev/null
}

examples_run() {
    SIM=$1
    BENCH_NAME=$2
    TRACE=$3
    BENCH_DIR=$EXAMPLES_DIR/$BENCH_NAME
    print_head examples $BENCH_NAME $BENCH_DIR $SIM ${TRACE}
    cd $BENCH_DIR
    common_run $SIM $TRACE
    cd - > /dev/null
}

taclebench_run() {
    SIM=$1
    BENCH_NAME=$2
    TRACE=$3
    BENCH_DIR=$TACLE_BENCH_DIR/$BENCH_NAME
    print_head taclebench $BENCH_NAME $BENCH_DIR $SIM ${TRACE}
    cd $BENCH_DIR
    common_run $SIM $TRACE
    cd - > /dev/null
}

common_run() {
    SIM=$1
    # BENCH_NAME=$2
    TRACE=$2
    echo "Running..."
    if [[ ! -f "$SIM.elf" ]]
    then
        echo "ELF not found!"
        return 0
    fi
    ${SIM}_run $TRACE
    echo "EXIT=$(cat ${SIM}_exit.txt)"
    test ! -f ${SIM}_instructions.txt || echo "INSTRUCTIONS=$(cat ${SIM}_instructions.txt)"
    test ! -f ${SIM}_cycles.txt || echo "CYCLES=$(cat ${SIM}_cycles.txt)"
    test ! -f ${SIM}_cpi.txt || echo "CPI=$(cat ${SIM}_cpi.txt)"

    echo "#lines $(wc -l ${SIM}_out.txt)" >> ${SIM}_notes.txt
    echo "#lines $(wc -l ${SIM}_err.txt)" >> ${SIM}_notes.txt
    echo -e "NOTES=\n$(cat ${SIM}_notes.txt)"
}

function cv32e40p_run() {
    TIMEOUT=900
    TRACE=$1
    EXTRA_ARGS=""
    if [[ "$TRACE" == "trace" ]]
    then
        echo "Trace not yet supported"
    fi

    TESTBENCH=$COREVVERIF_DIR/cv32e40p/sim/core/simulation_results/hello-world/verilator_executable
    timeout --foreground $TIMEOUT $TESTBENCH "+firmware=cv32e40p.elf.hex" $EXTRA_ARGS > cv32e40p_out.txt 2> cv32e40p_err.txt
    echo $? > cv32e40p_exit.txt
    INSTRUCTIONS=$(cat log_insn.csv | cut -d, -f2 | uniq | wc -l)
    echo $INSTRUCTIONS > cv32e40p_instructions.txt
    CYCLES=$(tail -1 log_insn.csv | cut -d, -f1)
    echo $CYCLES > cv32e40p_cycles.txt
    CPI=$(echo "scale=2; $CYCLES/$INSTRUCTIONS" | bc)
    echo $CPI > cv32e40p_cpi.txt
    echo "" > cv32e40p_notes.txt
    cat cv32e40p_out.txt | grep "Error" >> cv32e40p_notes.txt
    cat cv32e40p_out.txt | grep "EXCEPTION" >> cv32e40p_notes.txt
    cat cv32e40p_out.txt | grep "FAILURE" >> cv32e40p_notes.txt
}

function ovpsim_run() {
    TIMEOUT=90
    TRACE=$1
    EXTRA_ARGS=$OVPSIM_ARGS
    OVPSIM_ARGV="101010101010"
    if [[ "$TRACE" == "trace" ]]
    then
        EXTRA_ARGS="$EXTRA_ARGS --trace --tracefile ovpsim_trace.txt"
    fi

    if [[ "$PRINT" == "1" ]]
    then
        timeout --foreground $TIMEOUT $OVPSIM --program ovpsim.elf --variant CV32E40P --processorname CVE4P --override riscvOVPsim/cpu/unaligned=T --override riscvOVPsim/cpu/pk/reportExitErrors=T --override riscvOVPsim/cpu/extension_CVE4P/mcountinhibit_reset=0 --finishonopcode 0 $EXTRA_ARGS --argv $OVPSIM_ARGV > >(tee ovpsim_out.txt) 2> >(tee ovpsim_err.txt)
        echo $? > ovpsim_exit.txt
    else
        timeout --foreground $TIMEOUT $OVPSIM --program ovpsim.elf --variant CV32E40P --processorname CVE4P --override riscvOVPsim/cpu/unaligned=T --override riscvOVPsim/cpu/pk/reportExitErrors=T --override riscvOVPsim/cpu/extension_CVE4P/mcountinhibit_reset=0 --finishonopcode 0 $EXTRA_ARGS --argv $OVPSIM_ARGV > ovpsim_out.txt 2> ovpsim_err.txt
        echo $? > ovpsim_exit.txt
    fi
    cat ovpsim_out.txt | sed -rn 's/Info   Simulated instructions: (.*)$/\1/p' | sed 's/,//g' > ovpsim_instructions.txt
    echo "" > ovpsim_notes.txt
    cat ovpsim_out.txt | grep "Error" >> ovpsim_notes.txt
    cat ovpsim_out.txt | grep "Warning" >> ovpsim_notes.txt
}

function etiss_run() {
    if [[ -z $ETISS ]]
    then
        echo "ETISS enviornment variable not set!"
        exit 1
    fi
    if [[ ! -f $ETISS ]]
    then
        echo "ETISS not found: $ETISS!"
        exit 1
    fi
    TRACE=$1
    EXTRA_ARGS=${ETISS_ARGS}
    if [[ "$TRACE" == "trace" ]]
    then
        EXTRA_ARGS="$EXTRA_ARGS -pPrintInstruction"
    fi

    TIMEOUT=90
    if [[ "$PRINT" == "1" ]]
    then
        timeout --foreground $TIMEOUT $ETISS etiss.elf -i$ETISS_INI $EXTRA_ARGS > >(tee etiss_out.txt) 2> >(tee etiss_err.txt)
        echo $? > etiss_exit.txt
    else
        timeout --foreground $TIMEOUT $ETISS etiss.elf -i$ETISS_INI $EXTRA_ARGS > etiss_out.txt 2> etiss_err.txt
        echo $? > etiss_exit.txt
    fi
    cat etiss_out.txt | sed -rn 's/CPU Cycles \(estimated\): (.*)$/\1/p' > etiss_instructions.txt
    echo "" > etiss_notes.txt
    cat etiss_out.txt | grep "Error" >> etiss_notes.txt
    cat etiss_out.txt | grep "Warning" >> etiss_notes.txt
    cat etiss_out.txt | grep "EXCEPTION" >> etiss_notes.txt
}
