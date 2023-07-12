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
./scripts/build_taclebench.sh [ovpsim|etiss] [all|sequential/petrinet|...] [rv32im|rv32im_xcvhwlp|...] [release|debug]
```

### Run Simulations

```sh
./scripts/run_taclebench.sh [ovpsim|etiss] [all|sequential/petrinet|...] [notrace|trace]
```

### Misc

Optional!

```sh
./scripts/dump_taclebench.sh [ovpsim|etiss] [all|sequential/petrinet|...]
tail tacle-bench/bench/*/*/*_instructions.txt
./scripts/clean_taclebench.sh
```
