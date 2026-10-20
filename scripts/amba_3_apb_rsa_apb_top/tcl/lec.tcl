reset
set log file $::env(LEC_LOG) -replace

read library -verilog -replace -both \
    /home/grossimatheus/PDK/TSMC28/TSMCHOME/digital/Front_End/verilog/tcbn28hpcplusbwp30p140_110a/tcbn28hpcplusbwp30p140.v \
    /home/grossimatheus/PDK/TSMC28/TSMCHOME/digital/Front_End/verilog/tcbn28hpcplusbwp30p140lvt_110a/tcbn28hpcplusbwp30p140lvt.v

set source_dir [file join [pwd] src amba_3_apb]
set rtl_files [list \
    [file join [pwd] src rsa32 rsa_core_32.sv] \
    [file join $source_dir amba_3_apb_adrec.sv] \
    [file join $source_dir amba_3_apb_data_o_mux.sv] \
    [file join $source_dir amba_3_apb_data_io_top.sv] \
    [file join $source_dir amba_3_apb_control.sv] \
    [file join $source_dir amba_3_apb_regbank.sv] \
    [file join $source_dir amba_3_apb_reset.sv] \
    [file join $source_dir amba_3_apb_rsa_wrapper_control.sv] \
    [file join $source_dir amba_3_apb_rsa_wrapper_data.sv] \
    [file join $source_dir amba_3_apb_rsa_wrapper_top.sv] \
    [file join $source_dir amba_3_apb_rsa_apb_top.sv] \
]
foreach rtl_file $rtl_files {
    read design -systemverilog -golden $rtl_file
}
read design -verilog -revised $::env(NETLIST)

report design data
report black box -detail
set system mode lec
add compared points -all
compare
report verification
exit
