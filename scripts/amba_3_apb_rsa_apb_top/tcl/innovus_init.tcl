source [file join [file dirname [info script]] innovus_common.tcl]

innovus_stage {
    set lef_dir [file join $tech_dir LEF]
    set report_dir [file join $report_root init]
    file mkdir $db_dir $report_dir

    set_db design_process_node 45
    set_db add_route_vias_auto true
    set_db init_power_nets {VDD}
    set_db init_ground_nets {VSS}

    # Consume the mapped netlist and SDC from the same Genus execution.
    read_mmmc $::env(MMMC_FILE)
    read_physical -lef [list \
        [file join $lef_dir gsclib045_tech.lef] \
        [file join $lef_dir gsclib045_macro.lef]]
    read_netlist -top $project_name $::env(NETLIST_FILE)
    init_design

    check_timing -verbose > [file join $report_dir timing_constraints.rpt]
    write_db [file join $db_dir init_${project_name}]

    # Record provenance and select this run only after initialization succeeds.
    set provenance [open [file join $db_dir synthesis_inputs.txt] w]
    puts $provenance "RSA implementation: src/rsa32/v2"
    puts $provenance "Synthesis: $::env(SYNTH_RUN)"
    puts $provenance "Netlist: $::env(NETLIST_FILE)"
    puts $provenance "SDC: $::env(SDC_FILE)"
    close $provenance

    set marker [file join $::env(INNOVUS_BASE_DIR) active_run]
    set temporary "${marker}.[pid].tmp"
    set handle [open $temporary w]
    puts $handle $::env(SYNTH_RUN)
    close $handle
    file rename -force $temporary $marker
    exit
}
