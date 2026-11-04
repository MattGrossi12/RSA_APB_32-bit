#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
LOG_DIR="$PROJECT_ROOT/logs/amba_3_apb_adrec/lec"

mkdir -p -- "$LOG_DIR"
export LINT_LOG="$LOG_DIR/lint.log"
cd -- "$PROJECT_ROOT"

exec lec -nogui -dofile "$SCRIPT_DIR/../tcl/lint.tcl"
