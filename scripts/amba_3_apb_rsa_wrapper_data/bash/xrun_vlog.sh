#!/bin/sh
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
cd "$SCRIPT_DIR"
xrun \
    -64bit \
    -sv \
    -timescale 1ns/1ps \
    -makelib vlib \
        $PROJECT_ROOT/src/amba_3_apb/amba_3_apb_rsa_wrapper_data.sv \
        $PROJECT_ROOT/testbenchs/amba_3_apb_rsa_wrapper_data/testbench.sv \
    -endlib \
    -top vlib.testbench \
    -l ../../../logs/amba_3_apb_rsa_wrapper_data/xrun/xrun_svlog.log \
    -history_file ../../../logs/amba_3_apb_rsa_wrapper_data/xrun/xrun.history \
    -xmlibdirname xcelium.d
