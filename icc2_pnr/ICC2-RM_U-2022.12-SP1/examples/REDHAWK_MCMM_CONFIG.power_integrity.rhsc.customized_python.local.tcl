
########################################################################################
# Script: REDHAWK_MCMM_CONFIG.power_integrity.rhsc.customized_python.local.tcl
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
########################################################################################

##INFO: The usage support for both SCSM and MCMM on GRID system 

##INFO: Below is to define the variables for DEF/SPEF/LEF/TWF/PLOC to match with the variables in customized python
##INFO: If using default setting like below, we can skip to setup it
#set_app_options -name rail.generate_file_variables -value {PLOC ploc DEF def_files LEF lef_files SPEF spef_files TWF tw_files}

##INFO: For example, if customized python set "def_files = test_def_files" in customized python script, please add below setting
#set_app_options -name rail.generate_file_variables -value { DEF test_def_files }

set_scenario_status func.ss_125c  -ir_drop true
set_scenario_status func.ff_125c  -ir_drop true

create_rail_scenario -name static_customized_func.ss_125c  -scenario func.ss_125c
set_rail_scenario -name static_customized_func.ss_125c  -generate_file {PLOC DEF SPEF TWF LEF}  -custom_script_file ./customized.static.py.GRID

#
create_rail_scenario -name static_func.ff_125c -scenario func.ff_125c
set_rail_scenario -name static_func.ff_125c -voltage_drop static
 
#INFO: Launch analyze_rail for MCMM Rail analysis on GRID system
#INFO: Below usage require set_host_options -submit_command { local }
remove_host_options -all
set_host_options -submit_command { local }

##INFO: analyze_rail is not needed as IR Driven optimization features (IRDP/IRDCCD) will invoke it automatically



