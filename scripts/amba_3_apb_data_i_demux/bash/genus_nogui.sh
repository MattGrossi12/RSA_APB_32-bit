#!/usr/bin/env bash
set -eu

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

RUN="rsa_core_$(date '+%Y-%m-%d_%H-%M-%S')"
LOG="$SCRIPT_DIR/../../../logs/amba_3_apb_data_i_demux/genus/${RUN}.log"

# Clear results from previous runs:
rm -f ../../../ps_files/amba_3_apb_data_i_demux/netlist/*.v
rm -f ../../../ps_files/amba_3_apb_data_i_demux/sdc/*.sdc
rm -f ../../../ps_files/amba_3_apb_data_i_demux/db/*.db

exec genus -files ../tcl/run_genus.tcl -log "$LOG"
