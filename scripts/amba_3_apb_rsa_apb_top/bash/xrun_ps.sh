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

# Final Genus synthesis: keep netlist and SDF from the same run.
SYNTH_RUN="${SYNTH_RUN:-amba_3_apb_rsa_apb_top_2026-10-26_10-13-03}"
SYNTH_DIR="$PROJECT_ROOT/ps_files/rsa_apb_top_asap7"
NETLIST_FILE="$SYNTH_DIR/netlist/synth_${SYNTH_RUN}.v"
SDF_FILE="$SYNTH_DIR/sdf/synth_${SYNTH_RUN}.sdf"

for file in "$NETLIST_FILE" "$SDF_FILE"; do
    if [[ ! -s "$file" ]]; then
        echo "Erro: arquivo da sintese $SYNTH_RUN ausente ou vazio: $file" >&2
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
MTM_CONTROL = "MAXIMUM",
SCALE_TYPE = "FROM_MTM";
EOF

# ======================================
# Post-Synthesis Gate-Level Simulation
# Cadence Xcelium
# ======================================

xrun -64bit \
    -input "$SCRIPT_DIR/../tcl/xrun_uvm_nogui.tcl" \
    -timescale 1ns/1ps \
    +define+POST_SYNTHESIS \
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
