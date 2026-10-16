#Read :
set db_files [glob ../../../ps_files/amba_3_apb_data_io_top/db/*.db]
read_db [lindex $db_files 0]
gui_show
