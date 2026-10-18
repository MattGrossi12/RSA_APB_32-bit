reset

set log file ../../../logs/amba_3_apb_data_io_top/lec/run-vlog2svlg.log -replace

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
    ../../RTL/rsa_core_32.sv

// ============================================================
// REVISED: synthesized gate-level netlist
// ============================================================

read design -verilog -revised \
    ../../../ps_files/amba_3_apb_data_io_top/netlist/*.v

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