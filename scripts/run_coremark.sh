#!/bin/bash

source $(pwd)/scripts/common.sh

SIM=${1:-ovpsim}
TRACE=${2:-notrace}

coremark_run $SIM $TRACE
