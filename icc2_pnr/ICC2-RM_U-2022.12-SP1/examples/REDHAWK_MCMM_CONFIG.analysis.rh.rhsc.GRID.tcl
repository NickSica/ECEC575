
########################################################################################
# Script: REDHAWK_MCMM_CONFIG.analysis.rh.rhsc.GRID.tcl
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
########################################################################################

#INFO: The examples/REDHAWK_MCMM_CONFIG.analysis.rh.tcl is to support MCMM for Redhawk
#INFO: The usage support for both SCSM and MCMM on GRID system

set_scenario_status func.ss_125c  -ir_drop true
set_scenario_status func.ff_125c  -ir_drop true

create_rail_scenario -name static_func.ss_125c -scenario func.ss_125c
set_rail_scenario -name static_func.ss_125c -voltage_drop static 
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
analyze_rail -rail_scenario { static_func.ss_125c dynamic_func.ss_125c static_func.ff_125c } -submit_to_other_machine
#

