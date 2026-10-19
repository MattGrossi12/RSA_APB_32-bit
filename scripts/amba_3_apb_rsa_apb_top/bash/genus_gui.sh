#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
RUN="amba_3_apb_rsa_apb_top_$(date '+%Y-%m-%d_%H-%M-%S')"
DB_DIR="$PROJECT_ROOT/ps_files/rsa_apb_top/db"
LOG_DIR="$PROJECT_ROOT/logs/amba_3_apb_rsa_apb_top/genus"

mkdir -p -- "$LOG_DIR"
if [[ ! -d "$DB_DIR" ]]; then
    printf 'Erro: diretório de bancos Genus não encontrado: %s\nExecute genus_nogui.sh primeiro.\n' \
        "$DB_DIR" >&2
    exit 1
fi

DB_FILE="$(find "$DB_DIR" -maxdepth 1 -type f -name 'synth_*.db' \
    -printf '%T@ %p\n' | sort -nr | head -n 1 | cut -d ' ' -f 2-)"
if [[ -z "$DB_FILE" ]]; then
    printf 'Erro: nenhum banco de síntese Genus encontrado em %s. Execute genus_nogui.sh primeiro.\n' \
        "$DB_DIR" >&2
    exit 1
fi

export DB_FILE
cd -- "$PROJECT_ROOT"
exec genus -gui -files "$SCRIPT_DIR/../tcl/open_genus_gui.tcl" \
    -log "$LOG_DIR/${RUN}.log"
