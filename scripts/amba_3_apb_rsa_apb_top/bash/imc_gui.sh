#!/usr/bin/env bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
COV_SCOPE="$PROJECT_ROOT/coverage/amba_3_apb_rsa_apb_top/scope"
export IMC_COV_RUN="${1:-$(find "$COV_SCOPE" -mindepth 1 -maxdepth 1 -type d -name 'amba_3_apb_rsa_apb_top_*' -print | sort -r | head -n 1)}"

imc -gui -init "$SCRIPT_DIR/../tcl/imc.tcl"

