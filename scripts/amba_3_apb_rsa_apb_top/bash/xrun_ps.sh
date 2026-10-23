
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
RUN="amba_3_apb_rsa_apb_top_$(date '+%Y-%m-%d_%H-%M-%S')"

# Directories:
LOG_DIR="$PROJECT_ROOT/logs/amba_3_apb_rsa_apb_top/xrun"
IMC_LOG_DIR="$PROJECT_ROOT/logs/amba_3_apb_rsa_apb_top/imc"
WAVE_DIR="$PROJECT_ROOT/waveforms/amba_3_apb_rsa_apb_top"
COV_DIR="$PROJECT_ROOT/coverage/amba_3_apb_rsa_apb_top"
REPORT_DIR="$PROJECT_ROOT/reports/amba_3_apb_rsa_apb_top"

# Innovus Export:
source "$SCRIPT_DIR/innovus_common.sh"
innovus_setup xrun_ps
EXPORT_DIR="$INNOVUS_DB_DIR/export"
NETLIST_FILE="$EXPORT_DIR/amba_3_apb_rsa_apb_top.v"
SDF_FILE="$EXPORT_DIR/amba_3_apb_rsa_apb_top.sdf"

for file in "$NETLIST_FILE" "$SDF_FILE"; do
    if [[ ! -s "$file" ]]; then
        echo "Erro: arquivo pos-route ausente: $file. Execute 9.innovus_export.sh." >&2
        exit 1
    fi
done

# GSCLib045 Standard-Cell Library:
LIB_FILE="/home/cadence/DDI221/JLS221/etc/rtls/tutorial/libraries/verilog/typical.v"

# Testbench:
TB_FILE="$PROJECT_ROOT/testbenchs/rsa_apb_top/testbench.sv"
TB_TOP="testbench"
DUT_SCOPE="testbench.dut"

# SDF Annotation:
SDF_CMD_FILE="$LOG_DIR/${RUN}.sdf.cmd"
SDF_LOG="$LOG_DIR/${RUN}_sdf.log"

mkdir -p -- "$LOG_DIR" "$IMC_LOG_DIR" "$WAVE_DIR" "$COV_DIR" "$REPORT_DIR"
cd -- "$LOG_DIR"

# ======================================
# SDF Back-Annotation Configuration
# ======================================

cat > "$SDF_CMD_FILE" <<EOF
SDF_FILE = "$SDF_FILE",
SCOPE = $DUT_SCOPE,
LOG_FILE = "$SDF_LOG",
MTM_CONTROL = "TYPICAL",
SCALE_TYPE = "FROM_MTM";
EOF

# ======================================
# Post-Route Gate-Level Simulation
# Cadence Xcelium
# ======================================

xrun -64bit \
    -timescale 1ns/1ps \
    -top "$TB_TOP" \
    -access +rwc \
    -sdf_cmd_file "$SDF_CMD_FILE" \
    -sdf_verbose \
    -coverage all \
    -covoverwrite \
    -covworkdir "$COV_DIR" \
    -covtest "$RUN" \
    -l "$LOG_DIR/${RUN}.log" \
    -v "$LIB_FILE" \
    "$NETLIST_FILE" \
    "$TB_FILE" \
    "+VCD=$WAVE_DIR/${RUN}.vcd"

# ======================================
# Coverage Report - Cadence IMC
# ======================================

COV_RUN="$COV_DIR/scope/$RUN"
REPORT_FILE="$REPORT_DIR/${RUN}_coverage.rpt"

(
    cd -- "$IMC_LOG_DIR"
    imc -load "$COV_RUN" \
        -execcmd "report -summary -cumulative on -inst -local off -out \"$REPORT_FILE\""
)

echo "Simulacao Gate-Level e relatorio de cobertura concluidos."
echo "Netlist:   $NETLIST_FILE"
echo "SDF:       $SDF_FILE"
echo "Biblioteca: $LIB_FILE"
echo "Log:       $LOG_DIR/${RUN}.log"
echo "SDF Log:   $SDF_LOG"
echo "Waveform:  $WAVE_DIR/${RUN}.vcd"
echo "Cobertura: $COV_RUN"
echo "Relatorio: $REPORT_FILE"
