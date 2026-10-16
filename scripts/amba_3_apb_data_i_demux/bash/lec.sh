#!/bin/sh

RUN="rsa_core_$(date '+%Y-%m-%d_%H-%M-%S')"

lec -nogui -dofile ../tcl/lec.tcl
less ../../../logs/amba_3_apb_data_i_demux/lec/lec_${RUN}.log
