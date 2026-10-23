source [file join [file dirname [info script]] innovus_common.tcl]

innovus_stage {
    # Post-route timing optimization:
    set report_dir [file join $report_root postroute]

    file mkdir $report_dir

    # Restore Routed Database:
    innovus_read_stage route

    # Disable Signal Integrity Analysis:
    set_db delaycal_enable_si false

    # Post-route Optimization:
    opt_design -post_route -setup
    opt_design -post_route -hold

    # Timing Reports:
    time_design -post_route -report_dir [file join $report_dir setup]
    time_design -post_route -hold -report_dir [file join $report_dir hold]

    # Save Post-route Database:
    write_db [file join $db_dir postroute_amba_3_apb_rsa_apb_top]

    exit
}
