#!/bin/sh
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
cd "$SCRIPT_DIR"
xrun \
    -64bit \
    -sv \
    -timescale 1ns/1ns \
    -makelib vlib \
        $PROJECT_ROOT/src/amba_3_apb/amba_3_apb_adrec.sv \
        $PROJECT_ROOT/src/amba_3_apb/amba_3_apb_data_o_mux.sv \
        $PROJECT_ROOT/src/amba_3_apb/amba_3_apb_data_io_top.sv \
        $PROJECT_ROOT/testbenchs/amba_3_apb_data_io_top/testbench.sv \
    -endlib \
    -top vlib.testbench \
    -l ../../../logs/amba_3_apb_data_io_top/xrun/xrun_svlog.log \
    -history_file ../../../logs/amba_3_apb_data_io_top/xrun/xrun.history \
    -xmlibdirname xcelium.d
