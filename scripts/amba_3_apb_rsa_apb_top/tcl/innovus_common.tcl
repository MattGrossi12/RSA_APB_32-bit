# Context shared by every stage of the RSA32 v2 flow.
foreach required {PROJECT_ROOT SYNTH_RUN NETLIST_FILE SDC_FILE INNOVUS_BASE_DIR INNOVUS_DB_DIR INNOVUS_REPORT_DIR INNOVUS_TECH_DIR} {
    if {![info exists ::env($required)] || $::env($required) eq ""} {
        puts stderr "Erro: variavel $required ausente. Execute o script Bash da etapa."
        exit 1
    }
}

set project_name "amba_3_apb_rsa_apb_top"
set project_root $::env(PROJECT_ROOT)
set db_dir $::env(INNOVUS_DB_DIR)
set report_root $::env(INNOVUS_REPORT_DIR)
set tech_dir $::env(INNOVUS_TECH_DIR)

proc innovus_stage {body} {
    if {[catch {uplevel 1 $body} result]} {
        puts stderr "Erro no fluxo Innovus: $result"
        exit 1
    }
}

proc innovus_read_stage {stage} {
    global db_dir project_name
    set path [file join $db_dir ${stage}_${project_name}]
    if {![file exists $path]} {
        error "Banco da etapa $stage ausente para esta sintese: $path. Execute a etapa anterior."
    }
    read_db $path
}
