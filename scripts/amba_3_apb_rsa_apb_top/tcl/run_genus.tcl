
set project_name "amba_3_apb_rsa_apb_top"
set run_id $::env(RUN)
set output_dir $::env(OUTPUT_DIR)
set report_dir $::env(REPORT_DIR)
set source_dir [file join [pwd] src amba_3_apb]
set sdc_file [file join [pwd] constraints amba_3_apb_rsa_apb_top.sdc]
set_db / .use_scan_seqs_for_non_dft false

set rtl_files [list \
    [file join [pwd] src rsa32 rsa_core_32.sv] \
    [file join $source_dir amba_3_apb_adrec.sv] \
    [file join $source_dir amba_3_apb_data_o_mux.sv] \
    [file join $source_dir amba_3_apb_data_io_top.sv] \
    [file join $source_dir amba_3_apb_control.sv] \
    [file join $source_dir amba_3_apb_regbank.sv] \
    [file join $source_dir amba_3_apb_reset.sv] \
    [file join $source_dir amba_3_apb_rsa_wrapper_control.sv] \
    [file join $source_dir amba_3_apb_rsa_wrapper_data.sv] \
    [file join $source_dir amba_3_apb_rsa_wrapper_top.sv] \
    [file join $source_dir amba_3_apb_rsa_apb_top.sv] \
]

set_db init_lib_search_path \
    {/home/cadence/DDI221/JLS221/etc/rtls/tutorial/libraries/LIB/}

read_libs [list \
    /home/cadence/DDI221/JLS221/etc/rtls/tutorial/libraries/LIB/typical.lib \
]

set_db lef_library [list \
    /home/cadence/DDI221/JLS221/etc/rtls/tutorial/libraries/LEF/gsclib045_tech.lef \
    /home/cadence/DDI221/JLS221/etc/rtls/tutorial/libraries/LEF/gsclib045_macro.lef \
]

set_db init_hdl_search_path [list [file join [pwd] src rsa32] $source_dir]


foreach rtl_file $rtl_files {
    read_hdl -language sv $rtl_file
}

elaborate $project_name

set_time_unit -nanoseconds 1.0
read_sdc $sdc_file

check_design -unresolved > [file join $report_dir check_unresolved.rpt]
report_clocks > [file join $report_dir clocks.rpt]

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
