reset

set log file ../../../logs/amba_3_apb_reset/lec/run-vlog2svlg.log -replace

// ============================================================
// TSMC28 standard-cell libraries
// ============================================================

read library -verilog -replace -both \
/home/grossimatheus/PDK/TSMC28/TSMCHOME/digital/Front_End/verilog/tcbn28hpcplusbwp30p140_110a/tcbn28hpcplusbwp30p140.v \
/home/grossimatheus/PDK/TSMC28/TSMCHOME/digital/Front_End/verilog/tcbn28hpcplusbwp30p140lvt_110a/tcbn28hpcplusbwp30p140lvt.v

// ============================================================
// GOLDEN: RTL SystemVerilog
// ============================================================

read design -systemverilog -golden \
    ../../../src/rsa32/v2/rsa32_core_kogge_stone_adder.sv \
    ../../../src/rsa32/v2/rsa32_core_mult.sv \
    ../../../src/rsa32/v2/rsa32_core_mod.sv \
    ../../../src/rsa32/v2/rsa32_core_ctrl.sv \
    ../../../src/rsa32/v2/rsa32_core_top.sv

// ============================================================
// REVISED: synthesized gate-level netlist
// ============================================================

read design -verilog -revised \
    ../../../ps_files/amba_3_apb_reset/netlist/*.v

// ============================================================
// Diagnostics before LEC
// ============================================================

report design data
report black box -detail

// ============================================================
// LEC
// ============================================================

set system mode lec

add compared points -all

compare

report verification

exit -force