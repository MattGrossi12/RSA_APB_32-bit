#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/pdk_common.sh"
pdk_parse_args "$@"
export PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
RUN="amba_3_apb_rsa_apb_top_$(date '+%Y-%m-%d_%H-%M-%S_%N')_${PDK}"
OUTPUT_DIR="$PROJECT_ROOT/ps_files/rsa_apb_top_${PDK}"
LOG_DIR="$PROJECT_ROOT/logs/amba_3_apb_rsa_apb_top_${PDK}/genus/$RUN"
REPORT_DIR="$PROJECT_ROOT/reports/amba_3_apb_rsa_apb_top_${PDK}/genus/$RUN"
GENUS_BIN="${GENUS_BIN:-genus}"

if ! command -v "$GENUS_BIN" >/dev/null 2>&1; then
    printf 'Erro: Genus não encontrado. Configure o PATH ou GENUS_BIN.\n' >&2
    exit 127
fi
mkdir -p -- "$OUTPUT_DIR"/{db,netlist,sdc,sdf} "$LOG_DIR" "$REPORT_DIR"
cd -- "$LOG_DIR"

export RUN OUTPUT_DIR REPORT_DIR
printf 'PDK: %s\nSíntese: %s\nResultados: %s\nRelatórios: %s\n' "$PDK" "$RUN" "$OUTPUT_DIR" "$REPORT_DIR"
exec "$GENUS_BIN" -no_gui -files "$SCRIPT_DIR/../tcl/run_genus_${PDK}.tcl" \
    -log "$LOG_DIR/${RUN}.log" "${TOOL_ARGS[@]}"
