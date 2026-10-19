# Innovus 22.18 - RSA_APB power planning (GSCLib045).
# Preliminary geometry; verify power connectivity and DRC before placement.

set project_root $::env(PROJECT_ROOT)
set db_dir [file join $project_root ps_files rsa_apb_top innovus]
set report_dir [file join $project_root reports amba_3_apb_rsa_apb_top innovus power]
file mkdir $report_dir

read_db [file join $db_dir floorplan_amba_3_apb_rsa_apb_top]

connect_global_net VDD -type pg_pin -pin_base_name VDD -all
connect_global_net VSS -type pg_pin -pin_base_name VSS -all

add_rings -nets {VDD VSS} -type core_rings -follow core \
    -layer {top M9 bottom M9 left M10 right M10} \
    -width 1.0 -spacing 1.5 -offset 1.0

add_stripes -nets {VDD VSS} -layer M10 -direction vertical \
    -width 0.8 -spacing 1.5 -set_to_set_distance 25 \
    -start_from left -start_offset 15

route_special -nets {VDD VSS} \
    -connect {corePin floatingStripe} \
    -corePinTarget {ring stripe} \
    -floatingStripeTarget {ring stripe followpin}

check_connectivity -nets {VDD VSS} -type special \
    > [file join $report_dir power_connectivity.rpt]

write_db [file join $db_dir power_amba_3_apb_rsa_apb_top]
exit