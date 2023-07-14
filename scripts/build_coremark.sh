#!/bin/bash


source $(pwd)/scripts/common.sh

SIM=${1:-ovpsim}
ARCH=${2:-rv32im}
MODE=${3:-release}

coremark_build $SIM $ARCH $MODE
