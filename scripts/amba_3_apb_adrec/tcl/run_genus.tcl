set project_name "amba_3_apb_adrec"
set run_id $::env(RUN)
set output_dir $::env(OUTPUT_DIR)
set report_dir $::env(REPORT_DIR)
set rtl_file [file join [pwd] src amba_3_apb amba_3_apb_adrec.sv]

set_db init_lib_search_path \
    {/home/cadence/DDI221/JLS221/etc/rtls/tutorial/libraries/LIB/}
read_libs [list \
    /home/cadence/DDI221/JLS221/etc/rtls/tutorial/libraries/LIB/typical.lib \
]
set_db lef_library [list \
    /home/cadence/DDI221/JLS221/etc/rtls/tutorial/libraries/LEF/gsclib045_tech.lef \
    /home/cadence/DDI221/JLS221/etc/rtls/tutorial/libraries/LEF/gsclib045_macro.lef \
]

set_db init_hdl_search_path [file dirname $rtl_file]
read_hdl -language sv $rtl_file
elaborate $project_name

check_design -unresolved > [file join $report_dir check_unresolved.rpt]
set_db syn_generic_effort high
syn_generic
set_db syn_map_effort high
set_db syn_opt_effort high
syn_map
syn_opt

write_db $project_name -to_file [file join $output_dir db "synth_${run_id}.db"]
write_hdl > [file join $output_dir netlist "synth_${run_id}.v"]
write_sdc > [file join $output_dir sdc "synth_${run_id}.sdc"]
report_timing -max_paths 20 > [file join $report_dir timing_max.rpt]
report_area > [file join $report_dir area.rpt]
report_power > [file join $report_dir power.rpt]
report_gates > [file join $report_dir gates.rpt]
report_qor > [file join $report_dir qor.rpt]
check_design > [file join $report_dir check_design.rpt]

exit
