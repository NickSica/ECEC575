
##########################################################################################
# Script: init_design.additional_setup.tcl (example)
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################

########################################################################
## Additional timer related setups : create path groups 	
########################################################################
## Optionally create a register to register group
#  set cur_mode [current_mode]
#  foreach_in_collection mode [all_modes] {
#  	current_mode $mode;
#  	group_path -name reg2reg -from [all_clocks] -to [all_clocks] ;# creates register to register path group   
#  }
#  current_mode $cur_mode

## Optionally increase path group weight on critical path groups, for ex:
#  It is recommended to increase path group weight to at least 15 for critical ones 
#	group_path -name clk_gate_enable -weight 15
#	group_path -name xyz -weight 15

#  redirect -file ${REPORTS_DIR}/${INIT_DESIGN_BLOCK_NAME}.report_path_groups {report_path_groups -nosplit -modes [all_modes]}

########################################################################
## Additional timer related setups : clock gating check 	
########################################################################
# To set clock gating check :
# set cur_mode [current_mode]
# foreach_in_collection mode [all_modes] {
#	current_mode $mode
#	set_clock_gating_check -setup 0 [current_design]
#	set_clock_gating_check -hold  0 [current_design]
# }
# current_mode $cur_mode

########################################################################
## Additional power related setups : power derate	
########################################################################
## Power derating factors can affect power analysis and power optimization
#  To set power derating factors on objects, use set_power_derate command
#  Examples
#	set_power_derate 0.98 -scenarios [current_scenario] -leakage -internal
#	set_power_derate 0.9 -switching [get_lib_cells my_lib/cell1] 
#	set_power_derate 0.5 -group {memory} 
#  To report and get power derating factors
#	report_power_derate ...
#  To remove all power derating factors when no arguments are specified
#	reset_power_derate

