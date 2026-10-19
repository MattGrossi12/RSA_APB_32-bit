
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"

INNOVUS="/home/cadence/DDI221/INNOVUS221"
DB_FILE="$PROJECT_ROOT/ps_files/rsa_apb_top/innovus/init_amba_3_apb_rsa_apb_top"

cd -- "$PROJECT_ROOT"

"$INNOVUS/bin/innovus" -stylus \
    -execute "read_db {$DB_FILE}; gui_show"
