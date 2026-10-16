#!/bin/sh
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
cd "$SCRIPT_DIR"

RUN="rsa_core_$(date '+%Y-%m-%d_%H-%M-%S')"

lec -nogui -dofile ../tcl/lec.tcl
less ../../../logs/amba_3_apb_rsa_wrapper_data/lec/run-vlog2svlg.log
