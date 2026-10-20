# Project:
set project_name "amba_3_apb_rsa_apb_top"
set project_root $::env(PROJECT_ROOT)
set lef_dir "/home/cadence/DDI221/JLS221/etc/rtls/tutorial/libraries/LEF"
set output_dir [file join $project_root ps_files rsa_apb_top innovus]

file mkdir $output_dir

# Automatic Via Generation:
set_db add_route_vias_auto true

# Power and Ground:
set_db init_power_nets {VDD}
set_db init_ground_nets {VSS}

# MMMC:
read_mmmc $::env(MMMC_FILE)

# LEF:
read_physical -lef [list \
    [file join $lef_dir gsclib045_tech.lef] \
    [file join $lef_dir gsclib045_macro.lef]]

# Netlist:
read_netlist -top $project_name $::env(NETLIST_FILE)