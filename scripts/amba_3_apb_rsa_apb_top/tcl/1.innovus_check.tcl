# Verify imported design and timing constraints.
set project_root $::env(PROJECT_ROOT)
set db_dir [file join $project_root ps_files rsa_apb_top innovus]
set report_dir [file join $project_root reports amba_3_apb_rsa_apb_top innovus check]
file mkdir $report_dir

read_db [file join $db_dir init_amba_3_apb_rsa_apb_top]

check_library > [file join $report_dir library.rpt]
check_netlist > [file join $report_dir netlist.rpt]
check_timing -verbose > [file join $report_dir timing_constraints.rpt]
time_design -pre_place -report_dir [file join $report_dir pre_place]

exit
