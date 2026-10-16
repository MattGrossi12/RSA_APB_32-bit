#!/bin/sh
xrun \
    -64bit \
    -sv \
    -timescale 1ns/1ns \
    -makelib vlib \
        ../../RTL/rsa_core.v \
        ../../testbench/testbench.v \
    -endlib \
    -top Vlib.testbench \
    -l ../../../logs/amba_3_apb_data_i_demux/xrun/xrun_svlog.log \
    -history_file ../../../logs/amba_3_apb_data_i_demux/xrun/xrun.history \
    -xmlibdirname xcelium.d
