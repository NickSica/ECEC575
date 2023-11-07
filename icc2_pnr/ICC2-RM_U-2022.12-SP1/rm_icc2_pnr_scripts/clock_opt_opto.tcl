##########################################################################################
# Script: clock_opt_opto.tcl
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################

source ./rm_utilities/procs_global.tcl 
source ./rm_utilities/procs_icc2.tcl 
rm_source -file ./rm_setup/design_setup.tcl
rm_source -file ./rm_setup/icc2_pnr_setup.tcl
rm_source -file ./rm_setup/header_icc2_pnr.tcl
rm_source -file sidefile_setup.tcl -after_file technology_override.tcl
set PREVIOUS_STEP $CLOCK_OPT_CTS_BLOCK_NAME
set CURRENT_STEP $CLOCK_OPT_OPTO_BLOCK_NAME
if { [info exists env(RM_VARFILE)] } {
	if { [file exists $env(RM_VARFILE)] } {
		rm_source -file $env(RM_VARFILE)
	} else {
		puts "RM-error: env(RM_VARFILE) specified but not found"
	}
}

set REPORT_PREFIX $CURRENT_STEP
file mkdir ${REPORTS_DIR}/${REPORT_PREFIX}
puts "RM-info: PREVIOUS_STEP = $PREVIOUS_STEP"
puts "RM-info: CURRENT_STEP  = $CURRENT_STEP"
puts "RM-info: REPORT_PREFIX = $REPORT_PREFIX"
redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/run_start.rpt {run_start}

rm_source -file $TCL_PVT_CONFIGURATION_FILE -optional -print "TCL_PVT_CONFIGURATION_FILE"

open_lib $DESIGN_LIBRARY
copy_block -from ${DESIGN_NAME}/${PREVIOUS_STEP} -to ${DESIGN_NAME}/${CURRENT_STEP}
current_block ${DESIGN_NAME}/${CURRENT_STEP}
link_block

## The following only applies to hierarchical designs
## Swap abstracts if abstracts specified for clock_opt_cts and clock_opt_opto are different
if {$DESIGN_STYLE == "hier"} {
	if {$USE_ABSTRACTS_FOR_BLOCKS != "" && ($BLOCK_ABSTRACT_FOR_CLOCK_OPT_OPTO != $BLOCK_ABSTRACT_FOR_CLOCK_OPT_CTS)} {
		puts "RM-info: Swapping from [lindex $BLOCK_ABSTRACT_FOR_CLOCK_OPT_CTS 0] to [lindex $BLOCK_ABSTRACT_FOR_CLOCK_OPT_OPTO 0] abstracts for all blocks."
		change_abstract -references $USE_ABSTRACTS_FOR_BLOCKS -label [lindex $BLOCK_ABSTRACT_FOR_CLOCK_OPT_OPTO 0] -view [lindex $BLOCK_ABSTRACT_FOR_CLOCK_OPT_OPTO 1]
		report_abstracts
	}
	## Promote clock tree exceptions from blocks to top
	if {$USE_ABSTRACTS_FOR_BLOCKS != "" && $PROMOTE_CLOCK_BALANCE_POINTS} {
		rm_source -file $PROMOTE_ABSTRACT_CLOCK_DATA_FILE
	}
}

if {$CLOCK_OPT_OPTO_ACTIVE_SCENARIO_LIST != ""} {
	set_scenario_status -active false [get_scenarios -filter active]
	set_scenario_status -active true $CLOCK_OPT_OPTO_ACTIVE_SCENARIO_LIST
}

## Adjustment file for modes/corners/scenarios/models to applied to each step (optional)
rm_source -file $TCL_MODE_CORNER_SCENARIO_MODEL_ADJUSTMENT_FILE -optional -print "TCL_MODE_CORNER_SCENARIO_MODEL_ADJUSTMENT_FILE"

if {$CLOCK_OPT_OPTO_ACTIVE_SCENARIO_LIST != "" || $TCL_MODE_CORNER_SCENARIO_MODEL_ADJUSTMENT_FILE != ""} {
        ## Propagate clocks and compute IO latencies for modes or corners which are not active during clock_opt_cts step
        synthesize_clock_trees -propagate_only
        compute_clock_latency
}

rm_source -file $TCL_LIB_CELL_PURPOSE_FILE -optional -print "TCL_LIB_CELL_PURPOSE_FILE"


## Non-persistent settings to be applied in each step (optional)
rm_source -file $TCL_USER_NON_PERSISTENT_SCRIPT -optional -print "TCL_USER_NON_PERSISTENT_SCRIPT"

## Multi Vt constraint file to be applied in each step (optional)
rm_source -file $TCL_MULTI_VT_CONSTRAINT_FILE -optional -print "TCL_MULTI_VT_CONSTRAINT_FILE"

##########################################################################################
## Settings
##########################################################################################
## set_stage : a command to apply stage-based application options; intended to be used after set_qor_strategy within RM scripts.
set_stage -step post_cts_opto

## GRE - Support for a single focused scenario for routing (optional)
if {$ROUTE_FOCUSED_SCENARIO != ""} {
	set_app_options -name route.common.focus_scenario -value $ROUTE_FOCUSED_SCENARIO
}

## Prefix
set_app_options -name opt.common.user_instance_name_prefix -value clock_opt_opto_
set_app_options -name cts.common.user_instance_name_prefix -value clock_opt_opto_cts_

## For set_qor_strategy -metric timing, disabling the leakage and dynamic power analysis in active scenarios for optimization
## For set_qor_strategy -metric leakage, disabling the dynamic power analysis in active scenarios for optimization
# Scenario power analysis will be renabled after optimization for reporting
if {$SET_QOR_STRATEGY_METRIC == "timing"} {
   set rm_leakage_scenarios [get_object_name [get_scenarios -filter active==true&&leakage_power==true]]
   set rm_dynamic_scenarios [get_object_name [get_scenarios -filter active==true&&dynamic_power==true]]

   if {[llength $rm_leakage_scenarios] > 0 || [llength $rm_dynamic_scenarios] > 0} {
      puts "RM-info: Disabling leakage analysis for $rm_leakage_scenarios"
      puts "RM-info: Disabling dynamic analysis for $rm_dynamic_scenarios"
      set_scenario_status -leakage_power false -dynamic_power false [get_scenarios "$rm_leakage_scenarios $rm_dynamic_scenarios"]
   }
} elseif {$SET_QOR_STRATEGY_METRIC == "leakage_power"} {
   set rm_dynamic_scenarios [get_object_name [get_scenarios -filter active==true&&dynamic_power==true]]

   if {[llength $rm_dynamic_scenarios] > 0} {
      puts "RM-info: Disabling dynamic analysis for $rm_dynamic_scenarios"
      set_scenario_status -dynamic_power false [get_scenarios $rm_dynamic_scenarios]
  }
}


##########################################################################
## IR-driven placement (IRDP)
##########################################################################
if {$ENABLE_IRDP && [check_license -quiet "Digital-AF"]} {
	## Specify additional IRDP confgurations needed per your design
        ## Example for IRDP with manual RH config :      	examples/TCL_IRDP_CONFIG_FILE.manual.rh.tcl
        ## Example for IRDP with streamlined RH config : 	examples/TCL_IRDP_CONFIG_FILE.streamlined.rh.tcl
        ## Example for IRDP with manual RHSC config :    	examples/TCL_IRDP_CONFIG_FILE.manual.rhsc.tcl
        ## Example for IRDP with streamlined RHSC config : 	examples/TCL_IRDP_CONFIG_FILE.streamlined.rhsc.tcl
	rm_source -file $TCL_IRDP_CONFIG_FILE -print "ENABLE_IRDP requires a proper TCL_IRDP_CONFIG_FILE"
	#if {[file exists [which $TCL_IRDP_CONFIG_FILE]]} {
	#	puts "RM-info: Running IRDP by sourcing $TCL_IRDP_CONFIG_FILE"
	#       	source $TCL_IRDP_CONFIG_FILE
	#} elseif {$TCL_IRDP_CONFIG_FILE != ""} {
	#        puts "RM-error: ENABLE_IRDP is enabled but TCL_IRDP_CONFIG_FILE($TCL_IRDP_CONFIG_FILE) is invalid. Please correct it."
	#} elseif {$TCL_IRDP_CONFIG_FILE == ""} {
	#        puts "RM-error: ENABLE_IRDP is enabled but TCL_IRDP_CONFIG_FILE is not specified. Please correct it."
	#}
}

##########################################################################################
## Pre-opto customizations
##########################################################################################
rm_source -file $TCL_USER_CLOCK_OPT_OPTO_PRE_SCRIPT -optional -print "TCL_USER_CLOCK_OPT_OPTO_PRE_SCRIPT"

redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_app_options.start {report_app_options -non_default *}
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_lib_cell_purpose {report_lib_cell -objects [get_lib_cells] -column {full_name:20 valid_purposes}}


if {$ENABLE_INLINE_REPORT_QOR} {
   redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_qor.start {report_qor -scenarios [all_scenarios] -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit}
   redirect -append -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_qor.start {report_qor -summary -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit}
   redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_global_timing.start {report_global_timing -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit}
}

set check_stage_settings_cmd "check_stage_settings -stage pnr -metric \"${SET_QOR_STRATEGY_METRIC}\" -step post_cts_opto"
if {$ENABLE_REDUCED_EFFORT} {lappend check_stage_settings_cmd -reduced_effort}
if {$RESET_CHECK_STAGE_SETTINGS == "true"} {lappend check_stage_settings_cmd -reset_app_options}
if {$NON_DEFAULT_CHECK_STAGE_SETTINGS == "true"} {lappend check_stage_settings_cmd -all_non_default}
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_stage_settings {eval ${check_stage_settings_cmd}}



## The following only applies to designs with physical hierarchy
## Ignore the sub-blocks (bound to abstracts) internal timing paths
if {$DESIGN_STYLE == "hier" && $PHYSICAL_HIERARCHY_LEVEL != "bottom"} {
	set_timing_paths_disabled_blocks  -all_sub_blocks
}

##########################################################################################
## clock_opt final_opto flow
##########################################################################################
if {![rm_source -file $TCL_USER_CLOCK_OPT_OPTO_SCRIPT -optional -print "TCL_USER_CLOCK_OPT_OPTO_SCRIPT"]} {
# Note : The following executes if TCL_USER_CLOCK_OPT_OPTO_SCRIPT is not sourced

	puts "RM-info: Running clock_opt -from final_opto -to final_opto command"
	clock_opt -from final_opto -to final_opto

}

##########################################################################################
## Post-opto customizations
##########################################################################################
rm_source -file $TCL_USER_CLOCK_OPT_OPTO_POST_SCRIPT -optional -print "TCL_USER_CLOCK_OPT_OPTO_POST_SCRIPT"
##########################################################################################
#### Indesign PrimePower 
##########################################################################################
if {([check_license -quiet "ICCompilerII-4"] || [check_license -quiet "ICCompilerII"]) && [llength $TCL_PRIMEPOWER_CONFIG_FILE]> 0  && [lsearch $INDESIGN_PRIMEPOWER_STAGES "AFTER_CLOCK_OPT_OPTO"] >= 0} {
        ## Specify Indesign PrimePower confguration needed per your design
        ## Example for Indesign PrimePower config :             examples/TCL_PRIMEPOWER_CONFIG_FILE.indesign_options.tcl
        rm_source -file $TCL_PRIMEPOWER_CONFIG_FILE -print "ENABLE_PRIMEPOWER requires a proper TCL_PRIMEPOWER_CONFIG_FILE"
        set update_indesign_cmd "update_indesign_activity"
        if {$KEEP_INDESIGN_SAIF_FILE} {lappend update_indesign_cmd -keep_saif -saif_suffix clock_opt_opto}
        puts "RM-info: Running ${update_indesign_cmd}"
  	eval ${update_indesign_cmd}
}

##########################################################################################
## connect_pg_net
##########################################################################################
if {![rm_source -file $TCL_USER_CONNECT_PG_NET_SCRIPT -optional -print "TCL_USER_CONNECT_PG_NET_SCRIPT"]} {
## Note : the following executes if TCL_USER_CONNECT_PG_NET_SCRIPT is not sourced
	connect_pg_net
        # For non-MV designs with more than one PG, you should use connect_pg_net in manual mode.
}

## Re-enable power analysis if disabled for set_qor_strategy -metric timing
if {[info exists rm_leakage_scenarios] && [llength $rm_leakage_scenarios] > 0} {
   puts "RM-info: Reenabling leakage power analysis for $rm_leakage_scenarios"
   set_scenario_status -leakage_power true [get_scenarios $rm_leakage_scenarios]
}
if {[info exists rm_dynamic_scenarios] && [llength $rm_dynamic_scenarios] > 0} {
   puts "RM-info: Reenabling dynamic power analysis for $rm_dynamic_scenarios"
   set_scenario_status -dynamic_power true [get_scenarios $rm_dynamic_scenarios]
}

## Save block
save_block

##########################################################################################
## Create abstract and frame
##########################################################################################
## Enabled for hierarchical designs; for bottom and intermediate levels of physical hierarchy
if {$DESIGN_STYLE == "hier" && $PHYSICAL_HIERARCHY_LEVEL != "top" && !$SKIP_ABSTRACT_GENERATION} {
	if {$USE_ABSTRACTS_FOR_POWER_ANALYSIS == "true"} {
	        set_app_options -name abstract.annotate_power -value true
	}
	if { $PHYSICAL_HIERARCHY_LEVEL == "bottom" } {
	        create_abstract -read_only
	        create_frame -block_all true
	} elseif { $PHYSICAL_HIERARCHY_LEVEL == "intermediate"} {
	    if { $ABSTRACT_TYPE_FOR_MPH_BLOCKS == "nested"} {
	        ## Create nested abstract for the intermediate level of physical hierarchy
	        create_abstract -read_only
	        create_frame -block_all true
	    } elseif { $ABSTRACT_TYPE_FOR_MPH_BLOCKS == "flattened"} {
	        ## Create flattened abstract for the intermediate level of physical hierarchy
	        create_abstract -read_only -preserve_block_instances false
	        create_frame -block_all true
	    }
	}
}

##########################################################################################
## Report and output
##########################################################################################
if {$REPORT_QOR} {
	set REPORT_STAGE post_cts_opt
        set REPORT_ACTIVE_SCENARIOS $REPORT_CLOCK_OPT_OPTO_ACTIVE_SCENARIO_LIST
	if {$REPORT_PARALLEL_SUBMIT_COMMAND != ""} {
		## Generate a file to pass necessary RM variables for running report_qor.tcl to the report_parallel command
		rm_generate_variables_for_report_parallel -work_directory ${REPORTS_DIR}/${REPORT_PREFIX} -file_name rm_tcl_var.tcl

		## Parallel reporting using the report_parallel command (requires a valid REPORT_PARALLEL_SUBMIT_COMMAND)
		report_parallel -work_directory ${REPORTS_DIR}/${REPORT_PREFIX} -submit_command ${REPORT_PARALLEL_SUBMIT_COMMAND} -max_cores ${REPORT_PARALLEL_MAX_CORES} -user_scripts [list "${REPORTS_DIR}/${REPORT_PREFIX}/rm_tcl_var.tcl" "[which report_qor.tcl]"]
	} else {
		## Classic reporting
		rm_source -file report_qor.tcl
	}
}
redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/run_end.rpt {run_end}

write_qor_data -report_list "performance host_machine report_app_options" -label $REPORT_PREFIX -output $WRITE_QOR_DATA_DIR

report_msg -summary
print_message_info -ids * -summary
rm_logparse $LOGS_DIR/clock_opt_opto.log
echo [date] > clock_opt_opto

exit 
