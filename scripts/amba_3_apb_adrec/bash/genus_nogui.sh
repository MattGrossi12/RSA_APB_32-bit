#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
RUN="amba_3_apb_adrec_$(date '+%Y-%m-%d_%H-%M-%S')"
OUTPUT_DIR="$PROJECT_ROOT/ps_files/amba_3_apb_adrec"
LOG_DIR="$PROJECT_ROOT/logs/amba_3_apb_adrec/genus"
REPORT_DIR="$PROJECT_ROOT/reports/amba_3_apb_adrec/genus"

mkdir -p -- "$OUTPUT_DIR"/{db,netlist,sdc} "$LOG_DIR" "$REPORT_DIR"
cd -- "$PROJECT_ROOT"

export RUN OUTPUT_DIR REPORT_DIR
exec genus -files "$SCRIPT_DIR/../tcl/run_genus.tcl" \
    -log "$LOG_DIR/${RUN}.log"
