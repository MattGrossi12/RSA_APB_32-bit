#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
export PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"

# Latest synthesized netlist:
export NETLIST_FILE="$(ls -t "$PROJECT_ROOT/ps_files/rsa_apb_top/netlist"/synth_*.v | head -n 1)"

# Corresponding SDC:
export SDC_FILE="$PROJECT_ROOT/ps_files/rsa_apb_top/sdc/$(basename "${NETLIST_FILE%.v}").sdc"

# MMMC:
export MMMC_FILE="$SCRIPT_DIR/../tcl/innovus_mmmc.tcl"

# Innovus:
INNOVUS="/home/cadence/DDI221/INNOVUS221"
LOG_DIR="$PROJECT_ROOT/logs/amba_3_apb_rsa_apb_top/innovus/0.init"

mkdir -p -- "$LOG_DIR"
cd -- "$LOG_DIR"

exec "$INNOVUS/bin/innovus" \
    -stylus \
    -no_gui \
    -files "$SCRIPT_DIR/../tcl/innovus_init.tcl"
