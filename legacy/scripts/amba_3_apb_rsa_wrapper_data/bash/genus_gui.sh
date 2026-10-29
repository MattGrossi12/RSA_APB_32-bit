#!/usr/bin/env bash
set -eu

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
RUN="rsa_core_$(date '+%Y-%m-%d_%H-%M-%S')"
LOG="$SCRIPT_DIR/../../../logs/amba_3_apb_rsa_wrapper_data/genus/${RUN}.log"

exec genus -gui -files ../tcl/open_genus_gui.tcl -log "$LOG"
