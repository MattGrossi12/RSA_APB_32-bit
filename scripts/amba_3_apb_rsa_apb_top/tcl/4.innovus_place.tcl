source [file join [file dirname [info script]] innovus_common.tcl]

innovus_stage {
    # Placement and pre-CTS timing optimization.
    set report_dir [file join $report_root place]
    file mkdir $report_dir
    innovus_read_stage power

    place_opt_design
    time_design -pre_cts -report_dir [file join $report_dir pre_cts_${pdk}]

    write_db [file join $db_dir place_${artifact_name}]
    exit
}
