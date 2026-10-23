#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
RUN="amba_3_apb_rsa_apb_top_uvm_$(date '+%Y-%m-%d_%H-%M-%S')"
LOG_DIR="$PROJECT_ROOT/logs/amba_3_apb_rsa_apb_top/xrun_uvm/nogui"
IMC_LOG_DIR="$PROJECT_ROOT/logs/amba_3_apb_rsa_apb_top/imc_uvm"
WAVE_DIR="$PROJECT_ROOT/waveforms/amba_3_apb_rsa_apb_top/uvm"
RTL_DIR="$PROJECT_ROOT/src/amba_3_apb"
UVM_DIR="$PROJECT_ROOT/UVM"
COV_DIR="$PROJECT_ROOT/coverage/amba_3_apb_rsa_apb_top/uvm"
REPORT_DIR="$PROJECT_ROOT/reports/amba_3_apb_rsa_apb_top/uvm"
UVM_TESTNAME="${UVM_TESTNAME:-test_rsa_operation}"
UVM_VERBOSITY="${UVM_VERBOSITY:-UVM_MEDIUM}"

for tool in xrun imc; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "Erro: '$tool' nao encontrado no PATH. Execute o setup das ferramentas Cadence." >&2
        exit 1
    fi
done

mkdir -p -- "$LOG_DIR" "$IMC_LOG_DIR" "$WAVE_DIR" "$COV_DIR" "$REPORT_DIR"
export RUN WAVE_FILE="$WAVE_DIR/${RUN}.shm"
cd -- "$LOG_DIR"

# RTL e bancada UVM: testbench.svh inclui os pacotes e seus componentes.
xrun -64bit -sv -uvm -uvmhome CDNS-1.2 \
    -timescale 1ns/1ps \
    -input "$SCRIPT_DIR/../tcl/xrun_uvm_nogui.tcl" \
    -top top_tb \
    -access +rwc \
    -incdir "$UVM_DIR" \
    -coverage all \
    -covoverwrite \
    -covdut amba_3_apb_rsa_apb_top \
    -covworkdir "$COV_DIR" \
    -covtest "$RUN" \
    -l "$LOG_DIR/${RUN}.log" \
    "$PROJECT_ROOT/src/rsa32/v2/rsa32_core_kogge_stone_adder.sv" \
    "$PROJECT_ROOT/src/rsa32/v2/rsa32_core_mult.sv" \
    "$PROJECT_ROOT/src/rsa32/v2/rsa32_core_mod.sv" \
    "$PROJECT_ROOT/src/rsa32/v2/rsa32_core_ctrl.sv" \
    "$PROJECT_ROOT/src/rsa32/v2/rsa32_core_top.sv" \
    "$RTL_DIR/amba_3_apb_adrec.sv" \
    "$RTL_DIR/amba_3_apb_data_o_mux.sv" \
    "$RTL_DIR/amba_3_apb_data_io_top.sv" \
    "$RTL_DIR/amba_3_apb_control.sv" \
    "$RTL_DIR/amba_3_apb_regbank.sv" \
    "$RTL_DIR/amba_3_apb_reset.sv" \
    "$RTL_DIR/amba_3_apb_rsa_wrapper_control.sv" \
    "$RTL_DIR/amba_3_apb_rsa_wrapper_data.sv" \
    "$RTL_DIR/amba_3_apb_rsa_wrapper_top.sv" \
    "$RTL_DIR/amba_3_apb_rsa_apb_top.sv" \
    "$UVM_DIR/testbench.svh" \
    "+UVM_TESTNAME=$UVM_TESTNAME" \
    "+UVM_VERBOSITY=$UVM_VERBOSITY" \
    "$@"

# Relatorio de cobertura - Cadence IMC.
COV_RUN="$COV_DIR/scope/$RUN"
REPORT_FILE="$REPORT_DIR/${RUN}_coverage.rpt"

if [[ ! -d "$COV_RUN" ]]; then
    echo "Erro: banco de cobertura nao encontrado: $COV_RUN" >&2
    exit 1
fi

(
    cd -- "$IMC_LOG_DIR"
    imc -load "$COV_RUN" \
        -execcmd "report -summary -cumulative on -inst -local off -out \"$REPORT_FILE\""
)

if [[ ! -s "$REPORT_FILE" ]]; then
    echo "Erro: o IMC nao gerou o relatorio esperado: $REPORT_FILE" >&2
    exit 1
fi

echo "Simulacao UVM e relatorio de cobertura concluidos."
echo "Teste:     $UVM_TESTNAME"
echo "Log:       $LOG_DIR/${RUN}.log"
echo "Ondas:     $WAVE_FILE"
echo "Cobertura: $COV_RUN"
echo "Relatorio: $REPORT_FILE"
