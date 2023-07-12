# Miscellaneous files for compilation and benchmarking

This directory contains files required to use the Toolchains and Simulators.

## Overview

### ETISS Configuration files

ETISS uses `.ini` files for the configuration of the memories, plugins, jits, architectures,...

Some example files are provides for varous use-cases:

- `memsegs.ini` (default): Use this whenever possible
- `memsegs_debug.ini`: This one is helpful for debugging if something is not working as expected.


Use the environment-variable `ETISS_INI` to overwrite the default ETISS config file with a custom one.

### ETISS Target SW files

Some files required to get ETISS running with semihosting-support: `crt0.S,etiss.ld,etiss-semihost.specs,trap_handler.c`
