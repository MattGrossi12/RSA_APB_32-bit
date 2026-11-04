reset
set log file $::env(LEC_LOG) -replace

read library -verilog -replace -both \
    /home/grossimatheus/PDK/TSMC28/TSMCHOME/digital/Front_End/verilog/tcbn28hpcplusbwp30p140_110a/tcbn28hpcplusbwp30p140.v \
    /home/grossimatheus/PDK/TSMC28/TSMCHOME/digital/Front_End/verilog/tcbn28hpcplusbwp30p140lvt_110a/tcbn28hpcplusbwp30p140lvt.v

read design -systemverilog -golden \
    [file join [pwd] src amba_3_apb amba_3_apb_adrec.sv]
read design -verilog -revised $::env(NETLIST)

report design data
report black box -detail
set system mode lec
add compared points -all
compare
report verification
exit -force
