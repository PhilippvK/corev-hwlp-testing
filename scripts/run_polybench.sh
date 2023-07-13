#!/bin/bash

source $(pwd)/scripts/common.sh

SIM=${1:-ovpsim}
BENCH=${2:-all}
TRACE=${3:-notrace}

if [[ "$BENCH" == "all" ]]
then
    # all
    BENCHMARKS=(linear-algebra/solvers/gramschmidt linear-algebra/solvers/ludcmp linear-algebra/solvers/trisolv linear-algebra/solvers/durbin linear-algebra/solvers/lu linear-algebra/solvers/cholesky linear-algebra/kernels/atax linear-algebra/kernels/3mm linear-algebra/kernels/mvt linear-algebra/kernels/2mm linear-algebra/kernels/bicg linear-algebra/kernels/doitgen linear-algebra/blas/trmm linear-algebra/blas/gemver linear-algebra/blas/syrk linear-algebra/blas/gesummv linear-algebra/blas/syr2k linear-algebra/blas/symm linear-algebra/blas/gemm stencils/fdtd-2d stencils/seidel-2d stencils/adi stencils/jacobi-1d stencils/jacobi-2d stencils/heat-3d datamining/covariance datamining/correlation medley/deriche medley/nussinov medley/floyd-warshall)
else
    # single
    BENCHMARKS=($BENCH)
fi

for bench in "${BENCHMARKS[@]}"
do
    polybench_run $SIM $bench $TRACE
done
