
# Log:
set_log_file -replace $::env(LEC_LOG)

# Technology Library:
read_library -liberty -replace -both \
    /home/cadence/DDI221/JLS221/etc/rtls/tutorial/libraries/LIB/typical.lib

# RTL Files:
set project_root $::env(PROJECT_ROOT)
set source_dir [file join $project_root src amba_3_apb]

set rtl_files [list \
    [file join $project_root src rsa32 rsa_core_32.sv] \
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

# Golden Design:
read_design -systemverilog -golden \
    -root amba_3_apb_rsa_apb_top {*}$rtl_files

# Revised Netlist:
set netlist_dir [file join $project_root ps_files rsa_apb_top netlist]
set netlists [glob -directory $netlist_dir synth_*.v]

set netlist_times {}
foreach f $netlists {
    lappend netlist_times [list [file mtime $f] $f]
}

set netlist [lindex [lindex \
    [lsort -integer -decreasing -index 0 $netlist_times] 0] 1]

read_design -verilog -revised \
    -root amba_3_apb_rsa_apb_top $netlist

# Design Reports:
report_design_data
report_black_box -detail

# Sequential Constant Modeling:
set_flatten_model -seq_constant

# Logic Equivalence Checking:
set_system_mode lec

# Remodel Sequential Constants:
remodel -seq_constant -seq_constant_feedback -repeat

# Remap Key Points:
map_key_points

# Compare:
add_compared_points -all
compare

# LEC Reports:
set report_dir [file join $project_root reports amba_3_apb_rsa_apb_top lec]
file mkdir $report_dir

report_compare_data -class nonequivalent > [file join $report_dir lec_nonequivalent.rpt]
report_unmapped_points > [file join $report_dir lec_unmapped.rpt]
report_verification > [file join $report_dir lec_verification.rpt]

# Diagnosis Summary:
diagnose -summary > [file join $report_dir lec_diagnosis_summary.rpt]

# Diagnosis Groups:
diagnose -noneq -group > [file join $report_dir lec_diagnosis_groups.rpt]

# Diagnose PSLVERR:
if {[catch {
    diagnose /pslverr_o -golden > [file join $report_dir lec_diagnose_pslverr.rpt]
    report_test_vector /pslverr_o -golden > [file join $report_dir lec_test_vector_pslverr.rpt]
} result]} {
    puts "Aviso: Diagnostico PSLVERR nao disponivel: $result"
}

# Diagnose PRDATA[0]:
if {[catch {
    diagnose {/prdata_o[0]} -golden > [file join $report_dir lec_diagnose_prdata.rpt]
    report_test_vector {/prdata_o[0]} -golden > [file join $report_dir lec_test_vector_prdata.rpt]
} result]} {
    puts "Aviso: Diagnostico PRDATA nao disponivel: $result"
}

exit