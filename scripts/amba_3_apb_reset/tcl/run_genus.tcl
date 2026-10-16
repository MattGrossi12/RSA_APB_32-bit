
# Clear results from previous runs:
rm -f ../../../ps_files/amba_3_apb_reset/netlist/*.v
rm -f ../../../ps_files/amba_3_apb_reset/sdc/*.sdc
rm -f ../../../ps_files/amba_3_apb_reset/db/*.db

######################################
#               Synth                #
######################################
# Var creates:
set project_name "rsa_core"
set DATE [clock format [clock seconds] -format "%Y-%m-%d_%H-%M-%S"]
set RUN "${project_name}_${DATE}"


###########################################################################################################################################
# LIB
###########################################################################################################################################

# TSMC28 track PDK
set_db init_lib_search_path \
{/home/grossimatheus/PDK/TSMC28/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn28hpcplusbwp30p140_180a}

# TSMC28 LIB-Adress path:
#set LIBDIR /home/grossimatheus/PDK/TSMC28/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn28hpcplusbwp30p140_180a

# TSMC28 LIB PDK READ:
set LIBFILES [list \
    /home/grossimatheus/PDK/TSMC28/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn28hpcplusbwp30p140_180a/tcbn28hpcplusbwp30p140tt0p9v25c.lib \
    /home/grossimatheus/PDK/TSMC28/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn28hpcplusbwp30p140lvt_180a/tcbn28hpcplusbwp30p140lvttt0p9v25c.lib \
]

# Read all LIB files:
read_libs $LIBFILES

#Set our RTL directory:
set_db init_hdl_search_path {../../RTL}

#Read the RTL:
read_hdl -language sv -f  ../../filelist.f

#Build the design:
elaborate $project_name

#Check for unresolved references: (Probably will had a few problems):
check_design -unresolved > ../../reports/check_unresolved.rpt

#Load 
read_sdc ../../constraints/$project_name.sdc

#Define the level synthesis effort to use:
set_db syn_generic_effort high

#Synthesizing the design:
syn_generic

#Define the effort level for map/opt:
set_db syn_map_effort high
set_db syn_opt_effort high

#Syn process:
syn_map
syn_opt

#Write the databased used:
write_db $project_name -to_file ../../../ps_files/amba_3_apb_reset/db/synth_${RUN}.db

#Write the netlist:
write_hdl > ../../../ps_files/amba_3_apb_reset/netlist/synth_${RUN}.v

#Register the sdc created by the synthesis tool:
write_sdc > ../../../ps_files/amba_3_apb_reset/sdc/synth_${RUN}.sdc

#Report session:
report_timing -max_paths 20 > ../../reports/timing_max.rpt
report_area > ../../reports/area.rpt
report_power > ../../reports/power.rpt
report_gates > ../../reports/gates.rpt
report_qor > ../../reports/qor.rpt
check_design > ../../reports/check_design.rpt

exit