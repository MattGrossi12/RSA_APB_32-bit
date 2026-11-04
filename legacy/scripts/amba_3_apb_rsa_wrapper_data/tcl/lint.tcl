// Log file
set_log_file -replace ../../../logs/amba_3_apb_rsa_wrapper_data/lec/lint.log

// Read the SystemVerilog design
read_design ../../../src/amba_3_apb/amba_3_apb_rsa_wrapper_data.sv -systemverilog -golden

// Define the top-level module
set_root_module amba_3_apb_rsa_wrapper_data -golden

// Report all failing RTL rule checks
report_rule_check -RTL -status FAIL -verbose

exit
