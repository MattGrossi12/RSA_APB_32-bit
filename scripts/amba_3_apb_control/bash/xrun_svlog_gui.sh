#!/bin/sh
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
cd "$SCRIPT_DIR"
xrun \
    -64bit \
    -gui \
    -input ../tcl/xrun_svlog_probe.tcl \
    -sv \
    -access +rwc \
    -timescale 1ns/1ps \
    -makelib svlib \
        $PROJECT_ROOT/src/amba_3_apb/amba_3_apb_control.sv \
        $PROJECT_ROOT/testbenchs/amba_3_apb_control/testbench.sv \
    -endlib \
    -top svlib.testbench \
    -l ../../../logs/amba_3_apb_control/xrun/xrun_svlog.log \
    -history_file ../../../logs/amba_3_apb_control/xrun/xrun.history \
    -xmlibdirname xcelium.d
