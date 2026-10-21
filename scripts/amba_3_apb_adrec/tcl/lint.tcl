set_log_file -replace $::env(LINT_LOG)

read_design [file join [pwd] src amba_3_apb amba_3_apb_adrec.sv] \
    -systemverilog -golden

set_root_module amba_3_apb_adrec -golden
report_rule_check -RTL -status FAIL -verbose

exit
