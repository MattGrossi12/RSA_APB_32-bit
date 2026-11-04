// Log file
set_log_file -replace ../../../logs/amba_3_apb_data_io_top/lec/lint.log

// Read the SystemVerilog design
read_design \
    ../../../src/amba_3_apb/amba_3_apb_adrec.sv \
    ../../../src/amba_3_apb/amba_3_apb_data_io_top.sv \
    ../../../src/amba_3_apb/amba_3_apb_data_o_mux.sv \
    -systemverilog -golden

// Define the top-level module
set_root_module amba_3_apb_data_io_top -golden

// Report all failing RTL rule checks
report_rule_check -RTL -status FAIL -verbose

exit
