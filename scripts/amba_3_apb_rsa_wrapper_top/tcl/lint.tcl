// Log file
set_log_file -replace ../../../logs/amba_3_apb_rsa_wrapper_top/lec/lint.log

// Read the wrapper and its instantiated RTL dependencies
read_design \
    ../../../src/amba_3_apb/amba_3_apb_rsa_wrapper_top.sv \
    ../../../src/amba_3_apb/amba_3_apb_rsa_wrapper_control.sv \
    ../../../src/amba_3_apb/amba_3_apb_rsa_wrapper_data.sv \
    ../../../src/rsa32/v2/rsa32_core_kogge_stone_adder.sv \
    ../../../src/rsa32/v2/rsa32_core_mult.sv \
    ../../../src/rsa32/v2/rsa32_core_mod.sv \
    ../../../src/rsa32/v2/rsa32_core_ctrl.sv \
    ../../../src/rsa32/v2/rsa32_core_top.sv \
    -systemverilog -golden

// Define the top-level module
set_root_module amba_3_apb_rsa_wrapper_top -golden

// Report all failing RTL rule checks
report_rule_check -RTL -status FAIL -verbose

exit
