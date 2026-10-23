#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/innovus_common.sh"
innovus_setup "7.postroute"
innovus_run "$SCRIPT_DIR/../tcl/7.innovus_postroute.tcl" batch "$@"
