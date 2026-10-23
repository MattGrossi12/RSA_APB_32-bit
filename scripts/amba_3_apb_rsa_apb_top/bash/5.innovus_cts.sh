#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/innovus_common.sh"
innovus_setup "5.cts"
innovus_run "$SCRIPT_DIR/../tcl/5.innovus_cts.tcl" batch "$@"
