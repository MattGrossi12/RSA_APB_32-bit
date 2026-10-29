#!/usr/bin/env bash
set -eu

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

RUN="rsa_core_$(date '+%Y-%m-%d_%H-%M-%S')"
LOG="$SCRIPT_DIR/../../../logs/amba_3_apb_regbank/genus/${RUN}.log"

# Clear results from previous runs:
rm -f ../../../ps_files/amba_3_apb_regbank/netlist/*.v
rm -f ../../../ps_files/amba_3_apb_regbank/sdc/*.sdc
rm -f ../../../ps_files/amba_3_apb_regbank/db/*.db

exec genus -files ../tcl/run_genus.tcl -log "$LOG"
