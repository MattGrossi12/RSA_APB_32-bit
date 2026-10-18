SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
# Var creates:
set project_name "rsa_core"
set DATE [clock format [clock seconds] -format "%Y-%m-%d_%H-%M-%S"]
set RUN "${project_name}_${DATE}"

xrun -gui -files ../tcl/legacy/run.tcl -log ../../../logs/amba_3_apb_data_io_top/xrun/${RUN}.log \

\
-64bit \
-gui \
-l ../../../logs/amba_3_apb_data_io_top/xrun/${RUN}.log \


#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
LOG_DIR="$SCRIPT_DIR/../../../logs/amba_3_apb_data_io_top/xrun"


cd "$PROJECT_ROOT"
xrun -64bit \
  -top testbench \
  -access +rwc \
  -l "$LOG_DIR/${RUN}.log" \
  $PROJECT_ROOT/src/amba_3_apb/amba_3_apb_adrec.sv \
  $PROJECT_ROOT/src/amba_3_apb/amba_3_apb_data_o_mux.sv \
  $PROJECT_ROOT/src/amba_3_apb/amba_3_apb_data_io_top.sv \
  $PROJECT_ROOT/testbenchs/amba_3_apb_data_io_top/testbench.sv
