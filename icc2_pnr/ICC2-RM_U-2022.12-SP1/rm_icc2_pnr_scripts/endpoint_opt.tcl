##########################################################################################
# Script: endpoint_opt.tcl for route_opt PBA-CCD targeted optimization
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################

source ./rm_utilities/procs_global.tcl 
source ./rm_utilities/procs_icc2.tcl 
rm_source -file ./rm_setup/design_setup.tcl
rm_source -file ./rm_setup/icc2_pnr_setup.tcl
rm_source -file ./rm_setup/header_icc2_pnr.tcl
rm_source -file sidefile_setup.tcl -after_file technology_override.tcl
set PREVIOUS_STEP $ENDPOINT_OPT_FROM_BLOCK_NAME
set CURRENT_STEP  $ENDPOINT_OPT_BLOCK_NAME
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

if {$ENDPOINT_OPT_ACTIVE_SCENARIO_LIST != ""} {
	set_scenario_status -active false [get_scenarios -filter active]
	set_scenario_status -active true $ENDPOINT_OPT_ACTIVE_SCENARIO_LIST
}

## Adjustment file for modes/corners/scenarios/models to applied to each step (optional)
rm_source -file $TCL_MODE_CORNER_SCENARIO_MODEL_ADJUSTMENT_FILE -optional -print "TCL_MODE_CORNER_SCENARIO_MODEL_ADJUSTMENT_FILE"

## Non-persistent settings to be applied in each step (optional)
rm_source -file $TCL_USER_NON_PERSISTENT_SCRIPT -optional -print "TCL_USER_NON_PERSISTENT_SCRIPT"

## Multi Vt constraint file to be applied in each step (optional)
rm_source -file $TCL_MULTI_VT_CONSTRAINT_FILE -optional -print "TCL_MULTI_VT_CONSTRAINT_FILE"

##########################################################################################
## Settings
##########################################################################################
## Prefix
set_app_options -name opt.common.user_instance_name_prefix -value endpoint_opt_
set_app_options -name cts.common.user_instance_name_prefix -value endpoint_opt_cts_

rm_source -file $SIDEFILE_ROUTE_OPT -optional -print "SIDEFILE_ROUTE_OPT"

## For set_qor_strategy -metric leakage, disabling the dynamic power analysis in active scenarios for optimization
# Scenario power analysis will be renabled after optimization for reporting
if {$SET_QOR_STRATEGY_METRIC == "leakage_power"} {
   set rm_dynamic_scenarios [get_object_name [get_scenarios -filter active==true&&dynamic_power==true]]

   if {[llength $rm_dynamic_scenarios] > 0} {
      puts "RM-info: Disabling dynamic analysis for $rm_dynamic_scenarios"
      set_scenario_status -dynamic_power false [get_scenarios $rm_dynamic_scenarios]
  }
}

##########################################################################################
## Pre-command customizations
##########################################################################################
rm_source -file $TCL_USER_ENDPOINT_OPT_PRE_SCRIPT -optional -print "TCL_USER_ENDPOINT_OPT_PRE_SCRIPT"

redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_app_options.start {report_app_options -non_default *}
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_lib_cell_purpose {report_lib_cell -objects [get_lib_cells] -column {full_name:20 valid_purposes}}

if {$ENABLE_INLINE_REPORT_QOR} {
   redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_qor.start {report_qor -scenarios [all_scenarios] -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit}
   redirect -append -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_qor.start {report_qor -summary -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit}
   redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_global_timing.start {report_global_timing -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit}
}
set check_stage_settings_cmd "check_stage_settings -stage pnr -metric \"${SET_QOR_STRATEGY_METRIC}\" -step post_route"
if {$ENABLE_REDUCED_EFFORT} {lappend check_stage_settings_cmd -reduced_effort}
if {$RESET_CHECK_STAGE_SETTINGS} {lappend check_stage_settings_cmd -reset_app_options}
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_stage_settings {eval ${check_stage_settings_cmd}}

## The following only applies to designs with physical hierarchy
## Ignore the sub-blocks (bound to abstracts) internal timing paths
if {$DESIGN_STYLE == "hier" && $PHYSICAL_HIERARCHY_LEVEL != "bottom"} {
	set_timing_paths_disabled_blocks  -all_sub_blocks
}

#########################################################################################
## PBA-CCD targeted optimization
##########################################################################################
## Prerequisites : already done with RM's 3 route_opt flow : 1st CCD route_opt, 2nd route_opt with PBA enabled; 3rd size-only route_opt
## Run PBA-CCD skewing and datapath opto on selected end points for controlling optimization for last mile Fmax push

if {[get_drc_error_data -quiet zroute.err] == ""} {open_drc_error_data zroute.err}
set rm_drc_before_corecmd [sizeof_collection [get_drc_errors -quiet -error_data zroute.err]]

if {![rm_source -file $TCL_USER_ENDPOINT_OPT_SCRIPT -optional -print "TCL_USER_ENDPOINT_OPT_SCRIPT"]} {
## Note : The following executes if TCL_USER_ENDPOINT_OPT_SCRIPT is not sourced
	set targeted_ep_ropt_pba_ccd_cmd "targeted_ep_ropt_pba_ccd -max_paths $ENDPOINT_OPT_MAX_PATHS -slack_lesser_than $ENDPOINT_OPT_SLACK_THRESHOLD -scenarios \"$ENDPOINT_OPT_TARGET_SCENARIOS\""
	if {$ENDPOINT_OPT_PATH_GROUP_FILTER != ""} {
		lappend targeted_ep_ropt_pba_ccd_cmd -path_group_filter $ENDPOINT_OPT_PATH_GROUP_FILTER
	}

	for {set i 1} {$i < [expr $ENDPOINT_OPT_LOOP + 1]} {incr i} {
		puts "RM-info: Running $targeted_ep_ropt_pba_ccd_cmd #${i}"
		eval $targeted_ep_ropt_pba_ccd_cmd
		puts "RM-info: Completed $targeted_ep_ropt_pba_ccd_cmd #${i}"

		if {$ENDPOINT_OPT_LOOP > 1} {save_block -as ${DESIGN_NAME}/${ENDPOINT_OPT_BLOCK_NAME}_${i}}

	}
}

##########################################################################################
## Incremental route_detail for fixing routing DRCs
##########################################################################################
if {[get_drc_error_data -quiet zroute.err] == ""} {open_drc_error_data zroute.err}
set rm_drc_after_corecmd [sizeof_collection [get_drc_errors -quiet -error_data zroute.err]]

if { [info exists rm_drc_before_corecmd] && [info exists rm_drc_after_corecmd] } {
	set incr_route_detail_cmd "route_detail -incremental true -initial_drc_from_input true"
	if {$INCR_ROUTE_DETAIL_MAX_ITERATIONS != ""} {lappend incr_route_detail_cmd -max_number_iterations $INCR_ROUTE_DETAIL_MAX_ITERATIONS}
	if { [string equal -nocase $INCR_ROUTE_DETAIL_MODE "true"] } {
		puts "RM-info : INCR_ROUTE_DETAIL_MODE = true. Running $incr_route_detail_cmd"	
		eval $incr_route_detail_cmd
	} elseif { [string equal -nocase $INCR_ROUTE_DETAIL_MODE "false"] } {
		puts "RM-info : INCR_ROUTE_DETAIL_MODE = false. Skipping $incr_route_detail_cmd"
	} elseif {[string equal -nocase $INCR_ROUTE_DETAIL_MODE "auto"]} {
		if { ($rm_drc_after_corecmd > $rm_drc_before_corecmd) && \
		     ($rm_drc_before_corecmd < $INCR_ROUTE_DETAIL_DRC_THRESHOLD_MAX) && \
		     ($rm_drc_after_corecmd > $INCR_ROUTE_DETAIL_DRC_THRESHOLD_MIN) && \
		     ([expr (${rm_drc_after_corecmd}-${rm_drc_before_corecmd})] > [expr (${INCR_ROUTE_DETAIL_DRC_INCREASE_THRESHOLD_MIN}*${rm_drc_before_corecmd})]) } {
			puts "RM-info : INCR_ROUTE_DETAIL_MODE = auto and conditions are met. Running $incr_route_detail_cmd"	
			eval $incr_route_detail_cmd
		}
	}
}

##########################################################################################
## Post-command customizations
##########################################################################################
rm_source -file $TCL_USER_ENDPOINT_OPT_POST_SCRIPT -optional -print "TCL_USER_ENDPOINT_OPT_POST_SCRIPT" 

##########################################################################################
## connect_pg_net
##########################################################################################
if {![rm_source -file $TCL_USER_CONNECT_PG_NET_SCRIPT -optional -print "TCL_USER_CONNECT_PG_NET_SCRIPT"]} {
## Note : the following executes if TCL_USER_CONNECT_PG_NET_SCRIPT is not sourced
	connect_pg_net
        # For non-MV designs with more than one PG, you should use connect_pg_net in manual mode.
}

## Run check_routes to save updated routing DRC to the block
redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_routes {check_routes}

## Re-enable power analysis if disabled for set_qor_strategy -metric timing
if {[info exists rm_dynamic_scenarios] && [llength $rm_dynamic_scenarios] > 0} {
   puts "RM-info: Reenabling dynamic power analysis for $rm_dynamic_scenarios"
   set_scenario_status -dynamic_power true [get_scenarios $rm_dynamic_scenarios]
}

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
                derive_hier_antenna_property -design ${DESIGN_NAME}/${ENDPOINT_OPT_BLOCK_NAME}
                save_block ${DESIGN_NAME}/${ENDPOINT_OPT_BLOCK_NAME}.frame
	} elseif { $PHYSICAL_HIERARCHY_LEVEL == "intermediate"} {
		if { $ABSTRACT_TYPE_FOR_MPH_BLOCKS == "nested"} {
			## Create nested abstract for the intermediate level of physical hierarchy
			create_abstract -read_only
		} elseif { $ABSTRACT_TYPE_FOR_MPH_BLOCKS == "flattened"} {
			## Create flattened abstract for the intermediate level of physical hierarchy
			create_abstract -read_only -preserve_block_instances false
		}
                create_frame -block_all true
                derive_hier_antenna_property -design ${DESIGN_NAME}/${ENDPOINT_OPT_BLOCK_NAME}
		save_block ${DESIGN_NAME}/${ENDPOINT_OPT_BLOCK_NAME}.frame
	}
}

##########################################################################################
## Report and output
##########################################################################################
if {$REPORT_QOR} {
        set REPORT_STAGE post_route
        set REPORT_ACTIVE_SCENARIOS $REPORT_ENDPOINT_OPT_ACTIVE_SCENARIO_LIST
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
rm_logparse $LOGS_DIR/endpoint_opt.log
echo [date] > endpoint_opt

exit 
