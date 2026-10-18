#!/usr/bin/env bash
set -eu

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

RUN="rsa_core_$(date '+%Y-%m-%d_%H-%M-%S')"
LOG="$SCRIPT_DIR/../../../logs/amba_3_apb_rsa_wrapper_data/genus/${RUN}.log"

# Clear results from previous runs:
rm -f ../../../ps_files/amba_3_apb_rsa_wrapper_data/netlist/*.v
rm -f ../../../ps_files/amba_3_apb_rsa_wrapper_data/sdc/*.sdc
rm -f ../../../ps_files/amba_3_apb_rsa_wrapper_data/db/*.db

exec genus -files ../tcl/run_genus.tcl -log "$LOG"
