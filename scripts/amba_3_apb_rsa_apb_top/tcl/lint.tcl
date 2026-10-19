set_log_file -replace $::env(LINT_LOG)

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
    read_design $rtl_file -systemverilog -golden
}

set_root_module amba_3_apb_rsa_apb_top -golden
report_rule_check -RTL -status FAIL -verbose

exit
