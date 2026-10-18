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
        $PROJECT_ROOT/src/amba_3_apb/amba_3_apb_data_o_mux.sv \
        $PROJECT_ROOT/testbenchs/amba_3_apb_data_o_mux/testbench.sv \
    -endlib \
    -top svlib.testbench \
    -l ../../../logs/amba_3_apb_data_o_mux/xrun/xrun_svlog.log \
    -history_file ../../../logs/amba_3_apb_data_o_mux/xrun/xrun.history \
    -xmlibdirname xcelium.d
