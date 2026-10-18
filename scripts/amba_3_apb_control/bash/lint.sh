#!/bin/sh
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
cd "$SCRIPT_DIR"

PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
LOG_DIR="$PROJECT_ROOT/logs/amba_3_apb_control/lec"
mkdir -p "$LOG_DIR"
export LINT_LOG="$LOG_DIR/lint.log"

lec -nogui -dofile ../tcl/lint.tcl
