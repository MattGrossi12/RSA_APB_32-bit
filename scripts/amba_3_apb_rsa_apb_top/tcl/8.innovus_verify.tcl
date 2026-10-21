# Physical checks; not a foundry sign-off.
set project_root $::env(PROJECT_ROOT)
set db_dir [file join $project_root ps_files rsa_apb_top innovus]
set report_dir [file join $project_root reports amba_3_apb_rsa_apb_top innovus verify]
file mkdir $report_dir
read_db [file join $db_dir postroute_amba_3_apb_rsa_apb_top]

check_design -type all -out_file [file join $report_dir design.rpt]
check_timing -verbose > [file join $report_dir timing.rpt]
check_drc > [file join $report_dir drc.rpt]
check_connectivity -type all > [file join $report_dir connectivity.rpt]
time_design -post_route -report_dir [file join $report_dir setup]
time_design -post_route -hold -report_dir [file join $report_dir hold]
exit
