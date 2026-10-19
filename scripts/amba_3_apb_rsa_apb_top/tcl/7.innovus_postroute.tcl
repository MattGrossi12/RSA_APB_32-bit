# Post-route timing optimization.
set project_root $::env(PROJECT_ROOT)
set db_dir [file join $project_root ps_files rsa_apb_top innovus]
set report_dir [file join $project_root reports amba_3_apb_rsa_apb_top innovus postroute]
file mkdir $report_dir
read_db [file join $db_dir route_amba_3_apb_rsa_apb_top]

opt_design -post_route -setup
opt_design -post_route -hold

time_design -post_route -report_dir [file join $report_dir setup]
time_design -post_route -hold -report_dir [file join $report_dir hold]
write_db [file join $db_dir postroute_amba_3_apb_rsa_apb_top]
exit
