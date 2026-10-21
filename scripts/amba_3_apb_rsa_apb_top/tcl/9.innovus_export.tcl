
# Experimental Export:
set project_name "amba_3_apb_rsa_apb_top"
set project_root $::env(PROJECT_ROOT)
set db_dir [file join $project_root ps_files rsa_apb_top innovus]
set output_dir [file join $db_dir export]

file mkdir $output_dir

# Restore Post-route Database:
read_db [file join $db_dir postroute_${project_name}]

# DEF:
write_def [file join $output_dir ${project_name}.def]

# Verilog Netlist:
write_netlist [file join $output_dir ${project_name}.v]

# SDF:
write_sdf [file join $output_dir ${project_name}.sdf]

# Experimental GDSII:
# Standard-cell layouts and validated GDS layer map are unavailable.
write_stream [file join $output_dir ${project_name}_experimental.gds]

exit
