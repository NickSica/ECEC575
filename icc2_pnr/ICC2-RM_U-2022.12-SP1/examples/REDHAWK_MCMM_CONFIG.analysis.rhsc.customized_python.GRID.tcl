
########################################################################################
# Script: REDHAWK_MCMM_CONFIG.analysis.rhsc.customized_python.GRID.tcl
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
########################################################################################

##INFO: The examples/REDHAWK_MCMM_CONFIG.analysis.rh.tcl is to support MCMM for Redhawk
##INFO: The usage support for both SCSM and MCMM on GRID system
set_scenario_status func.ss_125c  -ir_drop true
set_scenario_status func.ff_125c  -ir_drop true
#

##INFO: Below is to define the variables for DEF/SPEF/LEF/TWF/PLOC to match with the variables in customized python
##INFO: If using default setting like below, we can skip to setup the rail.generate_file_variables
#set_app_options -name rail.generate_file_variables -value {PLOC ploc DEF def_files LEF lef_files SPEF spef_files TWF tw_files}

#
##INFO: If customized python include some user-defined variable (ex "def_files = test_def_files") in customized python script, please add below setting
# set_app_options -name rail.generate_file_variables -value { DEF test_def_files }
#
create_rail_scenario -name static_customized_func.ss_125c  -scenario func.ss_125c
set_rail_scenario -name static_customized_func.ss_125c  -generate_file {PLOC DEF SPEF TWF LEF}  -custom_script_file ./customized.static.py.GRID

#
create_rail_scenario -name dynamic_func.ss_125c -scenario func.ss_125c
set_rail_scenario -name dynamic_func.ss_125c -voltage_drop dynamic
#
create_rail_scenario -name static_func.ff_125c -scenario func.ff_125c
set_rail_scenario -name static_func.ff_125c -voltage_drop static
 
#INFO: Launch analyze_rail for MCMM Rail analysis on GRID system
#INFO: Below usage require set_host_options -submit_protocol .......
set_host_options -submit_protocol sge -submit_command {qsub -V -notify -b y -cwd -j y -P bnormal -l mfree=16G}

#INFO: Run analyze_rail for rail analysis
analyze_rail -rail_scenario { static_customized_func.ss_125c static_func.ss_125c  static_func.ff_125c } -submit_to_other_machine
#

