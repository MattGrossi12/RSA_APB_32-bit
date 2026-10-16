#!/bin/sh
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
cd "$SCRIPT_DIR"
xrun \
    -64bit \
    -input ../tcl/xrun_svlog_probe.tcl \
    -sv \
    -access +rwc \
    -timescale 1ns/1ns \
    -makelib svlib \
        $PROJECT_ROOT/src/amba_3_apb/amba_3_apb_rsa_wrapper_top.sv \
        $PROJECT_ROOT/testbenchs/amba_3_apb_rsa_wrapper_top/testbench.sv \
    -endlib \
    -top svlib.testbench \
    -l ../../../logs/amba_3_apb_rsa_wrapper_top/xrun/xrun_svlog.log \
    -history_file ../../../logs/amba_3_apb_rsa_wrapper_top/xrun/xrun.history \
    -xmlibdirname xcelium.d
