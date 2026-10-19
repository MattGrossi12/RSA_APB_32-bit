# Preliminary floorplan for GSCLib045; aspect=1, utilization=60%.
set project_root $::env(PROJECT_ROOT)
set db_dir [file join $project_root ps_files rsa_apb_top innovus]
read_db [file join $db_dir init_amba_3_apb_rsa_apb_top]

create_floorplan -site CoreSite -core_density_size {1.0 0.60 10 10 10 10}

# Block-level I/O pins on M3. Review their assignment in the GUI.
edit_pin -side Left -layer M3 -spread_type center -spacing 0.6 \
    -pin [get_db [get_db ports -if {.direction == in}] .name]
edit_pin -side Right -layer M3 -spread_type center -spacing 0.6 \
    -pin [get_db [get_db ports -if {.direction == out}] .name]

write_db [file join $db_dir floorplan_amba_3_apb_rsa_apb_top]
exit