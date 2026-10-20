# ============================================================
# Conformal 23.20 - RTL lint
# Top: amba_3_apb_rsa_apb_top
# ============================================================

set_dofile_abort exit
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

read_design {*}$rtl_files -systemverilog -golden -noelaborate
elaborate_design -golden -root amba_3_apb_rsa_apb_top

report_design_data -golden -summary
report_black_box -golden -detail
report_rule_check -all -verbose -design -golden

exit