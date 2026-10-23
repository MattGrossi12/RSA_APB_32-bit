source [file join [file dirname [info script]] innovus_common.tcl]

innovus_stage {
    # Verify imported design and timing constraints.
    set report_dir [file join $report_root check]
    file mkdir $report_dir

    innovus_read_stage init

    check_library > [file join $report_dir library.rpt]
    check_netlist > [file join $report_dir netlist.rpt]
    check_timing -verbose > [file join $report_dir timing_constraints.rpt]
    time_design -pre_place -report_dir [file join $report_dir pre_place]

    exit
}
