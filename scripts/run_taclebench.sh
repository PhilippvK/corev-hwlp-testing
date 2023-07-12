#!/bin/bash


TACLE_BENCH_DIR=$(pwd)/tacle-bench/bench

SIM=${1:-ovpsim}
BENCH=${2:-all}
TRACE=${3:-notrace}

export PRINT=${PRINT:-0}
export VERBOSE=${VERBOSE:-0}

if [[ "$VERBOSE" == "1" ]]
then
    set -x
fi

export ETISS_ARGS=${ETISS_ARGS:-""}

export EXTRA_DIR=$(pwd)/extra
DEFAULT_OVPSIM=$(pwd)/install/ovpsim/bin/Linux64/riscvOVPsimCOREV.exe
export OVPSIM=${OVPSIM:-$DEFAULT_OVPSIM}
DEFAULT_ETISS_INI=$EXTRA_DIR/memsegs.ini
ETISS_INI=${ETISS_INI:-$DEFAULT_ETISS_INI}
COREVVERIF_DIR=$(pwd)/core-v-verif

common_run() {
    SIM=$1
    BENCH_NAME=$2
    TRACE=$3
    BENCH_DIR=$TACLE_BENCH_DIR/$BENCH_NAME
    echo "======================="
    echo "Benchmark: $BENCH_NAME"
    echo "Directory: $BENCH_DIR"
    echo "Simulator: $SIM"
    echo "-----------------------"
    cd $BENCH_DIR
    echo "Running..."
    if [[ ! -f "$SIM.elf" ]]
    then
        echo "ELF not found!"
        return 0
    fi
    ${SIM}_run $TRACE
    echo "EXIT=$(cat ${SIM}_exit.txt)"
    echo "INSTRUCTIONS=$(cat ${SIM}_instructions.txt)"
    echo "#lines $(wc -l ${SIM}_out.txt)" >> ${SIM}_notes.txt
    echo "#lines $(wc -l ${SIM}_err.txt)" >> ${SIM}_notes.txt
    echo -e "NOTES=\n$(cat ${SIM}_notes.txt)"
    echo "Done."
    echo "======================="
    cd - > /dev/null
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
    EXTRA_ARGS=""
    if [[ "$TRACE" == "trace" ]]
    then
        EXTRA_ARGS="$EXTRA_ARGS --trace --tracefile ovpsim_trace.txt"
    fi

    if [[ "$PRINT" == "1" ]]
    then
        timeout --foreground $TIMEOUT $OVPSIM --program ovpsim.elf --variant CV32E40P --processorname CVE4P --override riscvOVPsim/cpu/unaligned=T --override riscvOVPsim/cpu/pk/reportExitErrors=T --finishonopcode 0 $EXTRA_ARGS > >(tee ovpsim_out.txt) 2> >(tee ovpsim_err.txt)
        echo $? > ovpsim_exit.txt
    else
        timeout --foreground $TIMEOUT $OVPSIM --program ovpsim.elf --variant CV32E40P --processorname CVE4P --override riscvOVPsim/cpu/unaligned=T --override riscvOVPsim/cpu/pk/reportExitErrors=T --finishonopcode 0 $EXTRA_ARGS > ovpsim_out.txt 2> ovpsim_err.txt
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
    common_run $SIM $bench $TRACE
done
