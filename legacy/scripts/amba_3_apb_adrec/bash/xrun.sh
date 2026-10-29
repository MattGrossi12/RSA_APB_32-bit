#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
RUN="amba_3_apb_adrec_$(date '+%Y-%m-%d_%H-%M-%S')"
LOG_DIR="$PROJECT_ROOT/logs/amba_3_apb_adrec/xrun"

mkdir -p -- "$LOG_DIR"
cd -- "$PROJECT_ROOT"

xrun -64bit \
    -timescale 1ns/1ps \
    -top testbench \
    -access +rwc \
    -l "$LOG_DIR/${RUN}.log" \
    "$PROJECT_ROOT/src/amba_3_apb/amba_3_apb_adrec.sv" \
    "$PROJECT_ROOT/testbenchs/amba_3_apb_adrec/testbench.sv"
