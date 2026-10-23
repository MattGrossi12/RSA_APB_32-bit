#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/innovus_common.sh"
innovus_setup "4.place"
innovus_run "$SCRIPT_DIR/../tcl/4.innovus_place.tcl" batch "$@"
