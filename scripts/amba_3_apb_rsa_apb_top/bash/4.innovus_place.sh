#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
export PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"

INNOVUS="/home/cadence/DDI221/INNOVUS221"
LOG_DIR="$PROJECT_ROOT/logs/amba_3_apb_rsa_apb_top/innovus/4.place"

mkdir -p -- "$LOG_DIR"
cd -- "$LOG_DIR"

exec "$INNOVUS/bin/innovus" -stylus -no_gui \
    -files "$SCRIPT_DIR/../tcl/4.innovus_place.tcl"
