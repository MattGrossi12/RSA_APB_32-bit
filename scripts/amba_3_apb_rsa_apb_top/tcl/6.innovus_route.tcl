# Signal routing and preliminary RC extraction (no QRC techfile).
set project_root $::env(PROJECT_ROOT)
set db_dir [file join $project_root ps_files rsa_apb_top innovus]
set report_dir [file join $project_root reports amba_3_apb_rsa_apb_top innovus route]
file mkdir $report_dir
read_db [file join $db_dir cts_amba_3_apb_rsa_apb_top]

route_design
set_db extract_rc_engine post_route
set_db extract_rc_effort_level low
extract_rc
time_design -post_route -report_dir [file join $report_dir post_route]

write_db [file join $db_dir route_amba_3_apb_rsa_apb_top]
exit
