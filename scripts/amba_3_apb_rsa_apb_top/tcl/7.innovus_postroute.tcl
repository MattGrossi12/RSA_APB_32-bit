
# Post-route timing optimization:
set project_root $::env(PROJECT_ROOT)
set db_dir [file join $project_root ps_files rsa_apb_top innovus]
set report_dir [file join $project_root reports amba_3_apb_rsa_apb_top innovus postroute]

file mkdir $report_dir

# Restore Routed Database:
read_db [file join $db_dir route_amba_3_apb_rsa_apb_top]

# Disable Signal Integrity Analysis:
set_db delaycal_enable_si false

# Post-route Optimization:
opt_design -post_route -setup
opt_design -post_route -hold

# Timing Reports:
time_design -post_route -report_dir [file join $report_dir setup]
time_design -post_route -hold -report_dir [file join $report_dir hold]

# Save Post-route Database:
write_db [file join $db_dir postroute_amba_3_apb_rsa_apb_top]

exit
