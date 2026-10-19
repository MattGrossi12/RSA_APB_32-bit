# Experimental export; a GDS layer map and std-cell layouts are unavailable.
set project_root $::env(PROJECT_ROOT)
set db_dir [file join $project_root ps_files rsa_apb_top innovus]
set output_dir [file join $db_dir export]
file mkdir $output_dir
read_db [file join $db_dir postroute_amba_3_apb_rsa_apb_top]

write_def [file join $output_dir amba_3_apb_rsa_apb_top.def]
write_netlist [file join $output_dir amba_3_apb_rsa_apb_top.v]
write_sdf [file join $output_dir amba_3_apb_rsa_apb_top.sdf]
exit
