if {![namespace exists ::IMEX]} { namespace eval ::IMEX {} }
set ::IMEX::dataVar [file dirname [file normalize [info script]]]
set ::IMEX::libVar ${::IMEX::dataVar}/libs

create_library_set -name lib_typical\
   -timing\
    [list ${::IMEX::libVar}/mmmc/typical.lib]
create_timing_condition -name tc_typical\
   -library_sets [list lib_typical]
create_rc_corner -name rc_typical\
   -pre_route_res 1\
   -post_route_res {1 1 1}\
   -pre_route_cap 1\
   -post_route_cap {1 1 1}\
   -post_route_cross_cap 1\
   -pre_route_clock_res 0\
   -pre_route_clock_cap 0\
   -temperature 25
create_delay_corner -name dc_typical\
   -timing_condition {tc_typical}\
   -rc_corner rc_typical
create_constraint_mode -name mode_functional\
   -sdc_files\
    [list ${::IMEX::libVar}/mmmc/synth_amba_3_apb_rsa_apb_top_2026-10-23_16-44-16.sdc]
create_analysis_view -name view_typical -constraint_mode mode_functional -delay_corner dc_typical
set_analysis_view -setup [list view_typical] -hold [list view_typical]
