# Clock tree synthesis and post-CTS optimization.
set project_root $::env(PROJECT_ROOT)
set db_dir [file join $project_root ps_files rsa_apb_top innovus]
set report_dir [file join $project_root reports amba_3_apb_rsa_apb_top innovus cts]
file mkdir $report_dir
read_db [file join $db_dir place_amba_3_apb_rsa_apb_top]

ccopt_design
time_design -post_cts -report_dir [file join $report_dir post_cts]

write_db [file join $db_dir cts_amba_3_apb_rsa_apb_top]
exit
