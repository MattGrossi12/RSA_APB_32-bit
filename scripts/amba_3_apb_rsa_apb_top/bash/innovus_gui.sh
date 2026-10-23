#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/innovus_common.sh"

# Open the final physical database unless another stage is explicitly selected.
INNOVUS_DB_STAGE="${INNOVUS_DB_STAGE:-postroute}"
if [[ $# -gt 0 && "$1" != -* ]]; then
    INNOVUS_DB_STAGE="$1"
    shift
fi
case "$INNOVUS_DB_STAGE" in
    postroute|route|cts|place|power|floorplan|init|auto) ;;
    *)
        echo "Erro: etapa invalida: $INNOVUS_DB_STAGE. Use postroute, route, cts, place, power, floorplan, init ou auto." >&2
        exit 2
        ;;
esac
export INNOVUS_DB_STAGE

innovus_setup gui
innovus_run "$SCRIPT_DIR/../tcl/innovus_gui.tcl" gui "$@"
