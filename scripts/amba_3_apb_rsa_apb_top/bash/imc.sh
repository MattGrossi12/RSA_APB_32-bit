#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
COV_SCOPE="$PROJECT_ROOT/coverage/amba_3_apb_rsa_apb_top/uvm/scope"
COV_RUN="${1:-$(find "$COV_SCOPE" -mindepth 1 -maxdepth 1 -type d -name 'amba_3_apb_rsa_apb_top_*' -print | sort -r | head -n 1)}"
if [[ -z "$COV_RUN" || ! -d "$COV_RUN" ]]; then
    printf 'Erro: banco de cobertura nao encontrado: %s\n' "$COV_RUN" >&2
    exit 1
fi
COV_RUN="$(cd -- "$COV_RUN" && pwd)"
RUN="$(basename -- "$COV_RUN")"
REPORT_DIR="$PROJECT_ROOT/reports/amba_3_apb_rsa_apb_top/uvm"
LOG_DIR="$PROJECT_ROOT/logs/amba_3_apb_rsa_apb_top/imc_uvm"

mkdir -p -- "$REPORT_DIR" "$LOG_DIR"
export IMC_COV_RUN="$COV_RUN"
cd -- "$LOG_DIR"

exec imc -execcmd "source \"$SCRIPT_DIR/../tcl/imc.tcl\"; report -summary -cumulative on -inst -local off -out \"$REPORT_DIR/${RUN}_coverage.rpt\"; report_metrics -out \"$REPORT_DIR/${RUN}_coverage_html\" -overwrite -detail -metrics all -all"

