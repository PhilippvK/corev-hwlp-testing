# CORE-V HWLP Testing

## Prerequisites

First, fetch the submodules using `git submodule update --init`.

### LLVM Toolchain

```sh
./scripts/download_llvm.sh
# Alternative:
# export CLANG=/path/to/llvm/bin/clang
# export OBJDUMP=/path/to/llvm/bin/llvm-objdump
```

### GCC Toolchain

```sh
./scripts/download_gcc.sh
# Alternative:
# export GCC=/path/to/gcc/bin/riscv32-unknown-elf-gcc
```

### OVPSim

```sh
./scripts/download_ovpsim.sh
# Alternative:
# export OVPSIM=/path/to/ovpsim/exe
```

### ETISS

A recent version of ETISS is required (with semihosting support and RV32IM[ACFD]XCoreV architecture) needs to be installed. Furthermore please point the `ETISS` environment variable to the location of the `run_helper.sh` script, e.g.: `export ETISS=/path/to/etiss/repo/build/bin/run_helper.sh`

### CV32E40P Testbench

```sh
./scripts/setup_verilator.sh
# Alternative:
# export VERILATOR=/path/to/verilator/exe

./scripts/setup_cv32e40p.sh
```


## Usage

### Compile Programs

```sh
./scripts/build_taclebench.sh [ovpsim|etiss|cv32e40p] [all|sequential/petrinet|...] [rv32im|rv32im_xcvhwlp|...] [release|debug]
./scripts/build_polybench.sh [ovpsim|etiss|cv32e40p] [all|linear-algebra/solvers/gramschmidt|...] ...
./scripts/build_mibench.sh [ovpsim|etiss|cv32e40p] [all|telecomm/FFT|...] ...
./scripts/build_embench.sh [ovpsim|etiss|cv32e40p] [all|aha-mont64|...] ...
./scripts/build_examples.sh [ovpsim|etiss|cv32e40p] [all|hello_world|...] ...
./scripts/build_coremark.sh [ovpsim|etiss|cv32e40p] ...
```

### Run Simulations

```sh
./scripts/run_taclebench.sh [ovpsim|etiss|cv32e40p] [all|sequential/petrinet|...] [notrace|trace]
./scripts/run_polybench.sh [ovpsim|etiss|cv32e40p] [all|linear-algebra/solvers/gramschmidt|...] ...
./scripts/run_mibench.sh [ovpsim|etiss|cv32e40p] [all|telecom/FFT|...] ...
./scripts/run_embench.sh [ovpsim|etiss|cv32e40p] [all|aha-mont64|...] ...
./scripts/run_examples.sh [ovpsim|etiss|cv32e40p] [all|hello_world|...] ...
./scripts/run_coremark.sh [ovpsim|etiss|cv32e40p] ...
```

### Misc

Optional!

Dumping assembly:
```sh
./scripts/dump_[taclebench|polybench|mibench|embench|examples|coremark].sh [ovpsim|etiss|cv32e40p] [all|sequential/petrinet|...]
```

Investigating generated artifacts:
```sh
tail tacle-bench/bench/*/*/*_instructions.txt  # Number of executed instructions
tail tacle-bench/bench/*/*/*_exit.txt  # Exit code (if reported by the target) -> should be zero!
...
```

Cleaning up repos:
```sh
./scripts/clean.sh [all|tacle-bench|embench-iot|polybench|mibench|coremark]
```
