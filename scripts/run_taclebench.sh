#!/bin/bash


TACLE_BENCH_DIR=$(pwd)/tacle-bench/bench

BENCH=${1:-all}

export OVPSIM=$(pwd)/riscv-ovpsim-corev-20230425/bin/Linux64/riscvOVPsimCOREV.exe


function run() {
    BENCH_NAME=$1
    BENCH_DIR=$TACLE_BENCH_DIR/$BENCH_NAME
    echo "======================="
    echo "Benchmark: $BENCH_NAME"
    echo ""Directory: $BENCH_DIR
    echo "-----------------------"
    cd $BENCH_DIR
    echo "Running..."
    TIMEOUT=90
    timeout --foreground $TIMEOUT $OVPSIM --program program.elf --variant CV32E40P --processorname CVE4P --override riscvOVPsim/cpu/unaligned=T --override riscvOVPsim/cpu/pk/reportExitErrors=T --finishonopcode 0 > out.txt 2> err.txt
    echo $? > exit.txt
    cat out.txt | sed -rn 's/Info   Simulated instructions: (.*)$/\1/p' | sed 's/,//g' > instructions.txt
    echo "EXIT=$(cat exit.txt)"
    echo "INSTRUCTIONS=$(cat instructions.txt)"
    echo "#lines $(wc -l out.txt)" > notes.txt
    echo "#lines $(wc -l err.txt)" >> notes.txt
    cat out.txt | grep "Error" >> notes.txt
    cat out.txt | grep "Warning" >> notes.txt
    echo -e "NOTES=\n$(cat notes.txt)"
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
    run $bench
done
