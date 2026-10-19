#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
RUN="amba_3_apb_data_io_top_$(date '+%Y-%m-%d_%H-%M-%S')"
LOG_DIR="$PROJECT_ROOT/logs/amba_3_apb_data_io_top/xrun"
WAVE_DIR="$PROJECT_ROOT/waveforms/amba_3_apb_data_io_top"

mkdir -p -- "$LOG_DIR" "$WAVE_DIR"
export RUN WAVE_FILE="$WAVE_DIR/${RUN}.shm"
cd -- "$PROJECT_ROOT"

xrun -64bit -gui \
    -timescale 1ns/1ps \
    -input "$SCRIPT_DIR/../tcl/xrun_wgui.tcl" \
    -top testbench \
    -access +rwc \
    -l "$LOG_DIR/${RUN}.log" \
    "$PROJECT_ROOT/src/amba_3_apb/amba_3_apb_adrec.sv" \
    "$PROJECT_ROOT/src/amba_3_apb/amba_3_apb_data_o_mux.sv" \
    "$PROJECT_ROOT/src/amba_3_apb/amba_3_apb_data_io_top.sv" \
    "$PROJECT_ROOT/testbenchs/amba_3_apb_data_io_top/testbench.sv"
