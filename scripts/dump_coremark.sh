#!/bin/bash

source $(pwd)/scripts/common.sh

SIM=${1:-ovpsim}

coremark_dump $SIM
