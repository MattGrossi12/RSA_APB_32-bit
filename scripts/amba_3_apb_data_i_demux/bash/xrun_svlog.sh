#!/bin/sh
xrun \
    -64bit \
    -input ../tcl/xrun_svlog_probe.tcl \
    -sv \
    -access +rwc \
    -timescale 1ns/1ns \
    -makelib svlib \
        ../../RTL/rsa_core_32.sv \
        ../../testbench/testbench_32.sv \
    -endlib \
    -top svlib.testbench_32 \
    -l ../../../logs/amba_3_apb_data_i_demux/xrun/xrun_svlog.log \
    -history_file ../../../logs/amba_3_apb_data_i_demux/xrun/xrun.history \
    -xmlibdirname xcelium.d
