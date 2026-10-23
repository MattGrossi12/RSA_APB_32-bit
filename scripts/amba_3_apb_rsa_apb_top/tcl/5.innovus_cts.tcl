source [file join [file dirname [info script]] innovus_common.tcl]

innovus_stage {
    # Clock tree synthesis and post-CTS optimization.
    set report_dir [file join $report_root cts]
    file mkdir $report_dir
    innovus_read_stage place

    ccopt_design
    time_design -post_cts -report_dir [file join $report_dir post_cts]

    write_db [file join $db_dir cts_amba_3_apb_rsa_apb_top]
    exit
}
