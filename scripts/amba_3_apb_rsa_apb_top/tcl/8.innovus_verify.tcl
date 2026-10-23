source [file join [file dirname [info script]] innovus_common.tcl]

innovus_stage {
    # Physical checks; not a foundry sign-off.
    set report_dir [file join $report_root verify]
    file mkdir $report_dir
    innovus_read_stage postroute

    check_design -type all -out_file [file join $report_dir design.rpt]
    check_timing -verbose > [file join $report_dir timing.rpt]
    check_drc > [file join $report_dir drc.rpt]
    check_connectivity -type all > [file join $report_dir connectivity.rpt]
    time_design -post_route -report_dir [file join $report_dir setup]
    time_design -post_route -hold -report_dir [file join $report_dir hold]
    exit
}
