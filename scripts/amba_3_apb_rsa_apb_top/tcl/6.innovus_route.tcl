
# Project:
set project_name "amba_3_apb_rsa_apb_top"
set project_root $::env(PROJECT_ROOT)
set output_dir [file join $project_root ps_files rsa_apb_top innovus]

# Automatic Via Generation:
set_db add_route_vias_auto true

# Restore CTS Database:
read_db [file join $output_dir cts_${project_name}]

# Routing:
route_design

# Save Routed Database:
write_db [file join $output_dir route_${project_name}]

exit
