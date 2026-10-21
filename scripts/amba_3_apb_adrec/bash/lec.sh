#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
OUTPUT_DIR="$PROJECT_ROOT/ps_files/amba_3_apb_adrec/netlist"
LOG_DIR="$PROJECT_ROOT/logs/amba_3_apb_adrec/lec"

mkdir -p -- "$LOG_DIR"
if [[ ! -d "$OUTPUT_DIR" ]]; then
    printf 'Erro: diretório de netlists não encontrado: %s. Execute genus_nogui.sh primeiro.\n' \
        "$OUTPUT_DIR" >&2
    exit 1
fi
NETLIST="$(find "$OUTPUT_DIR" -maxdepth 1 -type f -name 'synth_*.v' \
    -printf '%T@ %p\n' | sort -nr | head -n 1 | cut -d ' ' -f 2-)"
if [[ -z "$NETLIST" ]]; then
    printf 'Erro: nenhuma netlist Genus encontrada em %s. Execute genus_nogui.sh primeiro.\n' \
        "$OUTPUT_DIR" >&2
    exit 1
fi

RUN="amba_3_apb_adrec_$(date '+%Y-%m-%d_%H-%M-%S')"
export NETLIST
export LEC_LOG="$LOG_DIR/${RUN}.log"
cd -- "$PROJECT_ROOT"

exec lec -nogui -dofile "$SCRIPT_DIR/../tcl/lec.tcl"
