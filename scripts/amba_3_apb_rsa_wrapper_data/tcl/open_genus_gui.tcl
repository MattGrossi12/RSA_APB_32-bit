#Read :
set db_files [glob ../../../ps_files/amba_3_apb_rsa_wrapper_data/db/*.db]
read_db [lindex $db_files 0]
gui_show
