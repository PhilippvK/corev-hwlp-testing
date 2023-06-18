#!/bin/bash


TACLE_BENCH_DIR=$(pwd)/tacle-bench/bench

SIM=${1:-ovpsim}
BENCH=${2:-all}

export EXTRA_DIR=$(pwd)/extra
export OVPSIM=$(pwd)/riscv-ovpsim-corev-20230425/bin/Linux64/riscvOVPsimCOREV.exe
export ETISS=$(pwd)/etiss/build/bin/run_helper.sh


function common_run() {
    SIM=$1
    BENCH_NAME=$2
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
        exit 1
    fi
    ${SIM}_run
    echo "EXIT=$(cat ${SIM}_exit.txt)"
    echo "INSTRUCTIONS=$(cat ${SIM}_instructions.txt)"
    echo "#lines $(wc -l ${SIM}_out.txt)" >> ${SIM}_notes.txt
    echo "#lines $(wc -l ${SIM}_err.txt)" >> ${SIM}_notes.txt
    echo -e "NOTES=\n$(cat ${SIM}_notes.txt)"
    echo "Done."
    echo "======================="
    cd - > /dev/null
}

function ovpsim_run() {
    TIMEOUT=90
    timeout --foreground $TIMEOUT $OVPSIM --program ovpsim.elf --variant CV32E40P --processorname CVE4P --override riscvOVPsim/cpu/unaligned=T --override riscvOVPsim/cpu/pk/reportExitErrors=T --finishonopcode 0 > ovpsim_out.txt 2> ovpsim_err.txt
    echo $? > ovpsim_exit.txt
    cat ovpsim_out.txt | sed -rn 's/Info   Simulated instructions: (.*)$/\1/p' | sed 's/,//g' > ovpsim_instructions.txt
    echo "" > ovpsim_notes.txt
    cat ovpsim_out.txt | grep "Error" >> ovpsim_notes.txt
    cat ovpsim_out.txt | grep "Warning" >> ovpsim_notes.txt
}

function etiss_run() {
    TIMEOUT=90
    echo timeout --foreground $TIMEOUT $ETISS etiss.elf -i$EXTRA_DIR/memsegs.ini
    timeout --foreground $TIMEOUT $ETISS etiss.elf -i$EXTRA_DIR/memsegs.ini > etiss_out.txt 2> etiss_err.txt
    echo $? > etiss_exit.txt
    cat etiss_out.txt | sed -rn 's/CPU Cycles \(estimated\): (.*)$/\1/p' > etiss_instructions.txt
    echo "" > etiss_notes.txt
    cat etiss_out.txt | grep "Error" >> etiss_notes.txt
    cat etiss_out.txt | grep "Warning" >> etiss_notes.txt
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
    common_run $SIM $bench
done
