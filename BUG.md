# Intructions for reproduce HWLP-related bugs

**Prerequisites:**
- Ubuntu 20.04 (to use pre-built binaries for gcc & llvm)

## Block end off by one instruction

Using benchmark `sequential/dijkstra` for demonstration, however this also shows up for at least one more program.

1. Checkout `hwlp-bug-blockend` branch

```bash
git clone git@gitlab.lrz.de:de-tum-ei-eda-esl/llvm/hwlp-testing.git
git checkout hwlp-bug-blockend
git submodule update --init --recursive
```

2. Setup dependencies

```bash
./scripts/download_llvm.sh  # Build from source: ./scripts/build_llvm.sh
./scripts/download_gcc.sh
./scripts/setup_verilator.sh
./scripts/setup_cv32e40p.sh
```

3. Build & run reference benchmark (without hwlp feature)

```bash
./scripts/build_taclebench.sh cv32e40p sequential/dijkstra rv32im release
./scripts/run_taclebench.sh cv32e40p sequential/dijkstra

# Output:
# =======================
# Bechmark:  taclebench
# Program:   sequential/dijkstra
# Directory: /work/git/corev/hwlp-testing/tacle-bench/bench/sequential/dijkstra
# Simulator: cv32e40p
# Details:   notrace
# -----------------------
# Running...
# EXIT=0
# INSTRUCTIONS=28542873
# CYCLES=37087504
# CPI=1.29
# NOTES=
#
# #lines 11 cv32e40p_out.txt
# #lines 0 cv32e40p_err.txt
```

4. Build & run hwlp benchmark

```bash
./scripts/build_taclebench.sh cv32e40p sequential/dijkstra rv32im_xcvhwlp release
./scripts/run_taclebench.sh cv32e40p sequential/dijkstra

# Output:
# =======================
# Bechmark:  taclebench
# Program:   sequential/dijkstra
# Directory: /work/git/corev/hwlp-testing/tacle-bench/bench/sequential/dijkstra
# Simulator: cv32e40p
# Details:   notrace
# -----------------------
# Running...
# EXIT=0
# INSTRUCTIONS=124300
# CYCLES=144800
# CPI=1.16
# NOTES=
#
# TOP.tb_top_verilator @ 4294967295: EXIT FAILURE:              1447990
# #lines 11 cv32e40p_out.txt
# #lines 0 cv32e40p_err.txt
```

The hwlp version of the program exits way to early (reduction of executed instructions > 99%).

5. Workaround: Revert https://github.com/openhwgroup/cv32e40p/commit/14716209ec6d09ad2d31af4a5c36a094a65d767f in `cv32e40p` RTL

```bash
git -C cv32e40p cherry-pick 8e29b89d1b3c8451bac36545a4d5b154ad0a1ab8
./scripts/setup_cv32e40p.sh
```

6. Run-run benchmark with workaround

```bash
./scripts/run_taclebench.sh cv32e40p sequential/dijkstra

# Output:
# =======================
# Bechmark:  taclebench
# Program:   sequential/dijkstra
# Directory: /work/git/corev/hwlp-testing/tacle-bench/bench/sequential/dijkstra
# Simulator: cv32e40p
# Details:   notrace
# -----------------------
# Running...
# EXIT=0
# INSTRUCTIONS=28531114
# CYCLES=37051787
# CPI=1.29
# NOTES=
#
# #lines 11 cv32e40p_out.txt
# #lines 0 cv32e40p_err.txt
```

Works as expected
