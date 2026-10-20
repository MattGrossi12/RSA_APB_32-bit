#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
LOG_DIR="$PROJECT_ROOT/logs/amba_3_apb_rsa_apb_top/lec"

mkdir -p -- "$LOG_DIR"

RUN="amba_3_apb_rsa_apb_top_$(date '+%Y-%m-%d_%H-%M-%S')"
export LEC_LOG="$LOG_DIR/${RUN}.log"

cd -- "$PROJECT_ROOT"

exec lec -nogui -dofile "$SCRIPT_DIR/../tcl/lec.tcl"