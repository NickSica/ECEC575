##########################################################################################
# Script: place_opt.tcl
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################

source ./rm_utilities/procs_global.tcl 
source ./rm_utilities/procs_icc2.tcl 
rm_source -file ./rm_setup/design_setup.tcl
rm_source -file ./rm_setup/icc2_pnr_setup.tcl
rm_source -file ./rm_setup/header_icc2_pnr.tcl
rm_source -file sidefile_setup.tcl -after_file technology_override.tcl
set PREVIOUS_STEP $INIT_DESIGN_BLOCK_NAME
set CURRENT_STEP $PLACE_OPT_BLOCK_NAME
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

if {$SET_QOR_STRATEGY_MODE == "early_design"} {
	## Automatically enable lenient policy for early_design mode 
	set_early_data_check_policy -policy lenient -if_not_exist
} elseif {$EARLY_DATA_CHECK_POLICY != "none"} {
	## Design check manager
	set_early_data_check_policy -policy $EARLY_DATA_CHECK_POLICY -if_not_exist
}

link_block

## For top and intermediate level of hierarchical designs, check the editability of the sub-blocks;
## if the editability is true for any sub-block, set it to false
## In RM, we are setting the editability of all the sub-blocks to false in the init_design.tcl script
## The following check is implemented to ensure that the editability of the sub-blocks is set to false in flows not running the init_design.tcl script
if {$USE_ABSTRACTS_FOR_BLOCKS != ""} {
      	foreach_in_collection c [get_blocks -hierarchical] {
	  	if {[get_editability -blocks ${c}] == true } {
			set_editability -blocks ${c} -value false
   	  	}
      	}
	report_editability -blocks [get_blocks -hierarchical]
}

## Set active scenarios for the step (please include CTS and hold scenarios for CCD)
if {$PLACE_OPT_ACTIVE_SCENARIO_LIST != ""} {
	set_scenario_status -active false [get_scenarios -filter active]
	set_scenario_status -active true $PLACE_OPT_ACTIVE_SCENARIO_LIST
}

## Adjustment file for modes/corners/scenarios/models to applied to each step (optional)
rm_source -file $TCL_MODE_CORNER_SCENARIO_MODEL_ADJUSTMENT_FILE -optional -print "TCL_MODE_CORNER_SCENARIO_MODEL_ADJUSTMENT_FILE"

if {[sizeof_collection [get_scenarios -filter "hold && active"]] == 0} {
	puts "RM-warning: No active hold scenario is found. Recommended to enable hold scenarios here such that CCD skewing can consider them." 
	puts "RM-info: Please activate hold scenarios for place_opt if they are available." 
}

#########################################################################################
## Settings
##########################################################################################
if {$MAX_ROUTING_LAYER != ""} {set_ignored_layers -max_routing_layer $MAX_ROUTING_LAYER}
if {$MIN_ROUTING_LAYER != ""} {set_ignored_layers -min_routing_layer $MIN_ROUTING_LAYER}

## Non-persistent settings to be applied in each step (optional)
rm_source -file $TCL_USER_NON_PERSISTENT_SCRIPT -optional -print "TCL_USER_NON_PERSISTENT_SCRIPT"

## Multi Vt constraint file to be applied in each step (optional)
rm_source -file $TCL_MULTI_VT_CONSTRAINT_FILE -optional -print "TCL_MULTI_VT_CONSTRAINT_FILE"


## set_qor_strategy : a commmand which folds various settings of placement, optimization, timing, CTS, and routing, etc.
## - To query the target metric being set, use the "get_attribute [current_design] metric_target" command
set set_qor_strategy_cmd "set_qor_strategy -stage pnr -metric \"${SET_QOR_STRATEGY_METRIC}\" -mode \"${SET_QOR_STRATEGY_MODE}\""
if {$ENABLE_REDUCED_EFFORT} {lappend set_qor_strategy_cmd -reduced_effort}
puts "RM-info: Running $set_qor_strategy_cmd" 
eval ${set_qor_strategy_cmd}

## set_stage : a command to apply stage-based application options; intended to be used after set_qor_strategy within RM scripts.
set set_stage_cmd "set_stage -step placement"
if {$ENABLE_HIGH_EFFORT_CONGESTION} {lappend set_stage_cmd -high_effort_congestion}
puts "RM-info: Running ${set_stage_cmd}"
eval ${set_stage_cmd}

set rm_lib_type [get_attribute -quiet [current_design] rm_lib_type]
if {$rm_lib_type != ""} {puts "RM-info: rm_lib_type = $rm_lib_type"}
if { [regexp {h$} $rm_lib_type] } {set_app_options -name place.coarse.congestion_driven_max_util -value 0.85}

## Prefix
set_app_options -name opt.common.user_instance_name_prefix -value place_opt_
set_app_options -name cts.common.user_instance_name_prefix -value place_opt_cts_

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

##########################################################################################
## Additional setup
##########################################################################################
## CTS primary corner
## CTS automatically picks a corner with worst delay as the primary corner for its compile stage, 
## which inserts buffers to balance clock delays in all modes of the corner; 
## this setting allows you to manually specify a corner for the tool to use instead
if {$PREROUTE_CTS_PRIMARY_CORNER != ""} {
	puts "RM-info: Setting cts.compile.primary_corner to $PREROUTE_CTS_PRIMARY_CORNER (tool default unspecified)"
	set_app_options -name cts.compile.primary_corner -value $PREROUTE_CTS_PRIMARY_CORNER
}

## Spare cell insertion before place_opt
rm_source -file $TCL_USER_SPARE_CELL_PRE_SCRIPT -optional -print "TCL_USER_SPARE_CELL_PRE_SCRIPT"

if {$OPTIMIZATION_FREEZE_PORT_LIST != ""} {
	puts "RM-info: Setting opt.dft.hier_preservation to true (tool default false)"
	set_app_options -name opt.dft.hier_preservation -value true ;# honors hierarchy port preservation during dft optimization
	set_freeze_port -all [get_cells $OPTIMIZATION_FREEZE_PORT_LIST] ;# sets freeze_clock_ports and freeze_data_ports attributes on the specified cells
}

##########################################################################################
## Pre-place_opt customizations
##########################################################################################
rm_source -file $TCL_USER_PLACE_OPT_PRE_SCRIPT -optional -print "TCL_USER_PLACE_OPT_PRE_SCRIPT"

redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_app_options.start {report_app_options -non_default *}
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_lib_cell_purpose {report_lib_cell -objects [get_lib_cells] -column {full_name:20 valid_purposes}}

set check_stage_settings_cmd "check_stage_settings -stage pnr -metric \"${SET_QOR_STRATEGY_METRIC}\" -step placement"
if {$ENABLE_REDUCED_EFFORT} {lappend check_stage_settings_cmd -reduced_effort}
if {$RESET_CHECK_STAGE_SETTINGS == "true"} {lappend check_stage_settings_cmd -reset_app_options}
if {$NON_DEFAULT_CHECK_STAGE_SETTINGS == "true"} {lappend check_stage_settings_cmd -all_non_default}
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_stage_settings {eval ${check_stage_settings_cmd}}

puts "RM-info: Marking clock network as ideal"
set currentMode [current_mode]
foreach_in_collection mode [all_modes] {
    current_mode $mode
    set clock_tree [all_fanout -flat -clock_tree]
    if { [sizeof_collection $clock_tree] > 0 } {
        set_ideal_network $clock_tree
        remove_propagated_clock [get_pins -hierarchical]
        remove_propagated_clock [get_ports]
        remove_propagated_clock [get_clocks -filter !is_virtual]
    }
}
current_mode $currentMode

## The following only applies to designs with physical hierarchy
## Ignore the sub-blocks (bound to abstracts) internal timing paths
if {$DESIGN_STYLE == "hier" && $PHYSICAL_HIERARCHY_LEVEL != "bottom"} {
	set_timing_paths_disabled_blocks -all_sub_blocks
}

## Clock NDR modeling 
## mark_clock_trees makes place_opt recognize clock NDR to model the congestion impact
puts "RM-info: Running mark_clock_trees -routing_rules to model clock NDR impact during place_opt"
mark_clock_trees -routing_rules

##########################################################################################
## place_opt flow
##########################################################################################
if {![rm_source -file $TCL_USER_PLACE_OPT_SCRIPT -optional -print "TCL_USER_PLACE_OPT_SCRIPT"]} {
## Note : The following executes if TCL_USER_PLACE_OPT_SCRIPT is not sourced

	##########################################################################
	## Non-SPG flow (ENABLE_SPG set to false)
	##########################################################################
	if {!$ENABLE_SPG} {

		if {$ENABLE_HIGH_UTILIZATION_FLOW} {
			puts "RM-info: Special feature ENABLE_HIGH_UTILIZATION_FLOW is true."
			puts "RM-info: Disabling AWP and running remove_buffer_trees -all, create_placement -buffering_aware_timing_driven, and place_opt initial_drc before place_opt commands."
			reset_app_options time.delay_calc_wareform_analysis_mode
			remove_buffer_trees -all
			create_placement -buffering_aware_timing_driven 
			place_opt -from initial_drc -to initial_drc
		}

		##########################################################################
		## Two pass place_opt: first pass
		##########################################################################
		puts "RM-info: Running place_opt -from initial_place -to initial_place" ;# initial_place phase is buffering-aware with CDR
		place_opt -from initial_place -to initial_place

	        ## Regular MSCTS at place_opt 
	        if {$CTS_STYLE == "MSCTS"} {
			if {[rm_source -file $TCL_REGULAR_MSCTS_FILE -optional -print "TCL_REGULAR_MSCTS_FILE"]} {
			## Note : The following executes only if TCL_USER_PLACE_OPT_SCRIPT is sourced

				save_block -as ${DESIGN_NAME}/${PLACE_OPT_BLOCK_NAME}_MSCTS

			}
	
	        } elseif {$CTS_STYLE != "standard"} {
			puts "RM-error: Specified CTS_STYLE($CTS_STYLE) is not supported, standard will be used." 
		}

		puts "RM-info: Running place_opt -from initial_drc -to initial_drc"
		place_opt -from initial_drc -to initial_drc
		puts "RM-info: Running update_timing -full"
		update_timing -full

		##########################################################################
		## Two pass place_opt: second pass
		##########################################################################
		puts "RM-info: Running create_placement -incremental -timing_driven -congestion"
		# Note: to increase the congestion alleviation effort, add -congestion_effort high
		create_placement -incremental -timing_driven -congestion

		save_block -as ${DESIGN_NAME}/${PLACE_OPT_BLOCK_NAME}_two_pass_placement

		
		rm_source -file $TCL_USER_PLACE_OPT_INCREMENTAL_PLACEMENT_POST_SCRIPT -optional -print "TCL_USER_PLACE_OPT_INCREMENTAL_PLACEMENT_POST_SCRIPT"

		puts "RM-info: Running place_opt -from initial_drc"
		place_opt -from initial_drc

		if {$ENABLE_HIGH_UTILIZATION_FLOW} {
			puts "RM-info: Special feature ENABLE_HIGH_UTILIZATION_FLOW is true. Running extra place_opt -from final_place after default place_opt commands."
			place_opt -from final_place
		}
	} 

	##########################################################################
	## SPG flow (ENABLE_SPG set to true)
	##########################################################################
	if {$ENABLE_SPG} {

	        ## Regular MSCTS at place_opt 
	        if {$CTS_STYLE == "MSCTS"} {
			if {[rm_source -file $TCL_REGULAR_MSCTS_FILE -optional -print "TCL_REGULAR_MSCTS_FILE"]} {
			## Note : The following executes if TCL_USER_PLACE_OPT_SCRIPT is sourced

				save_block -as ${DESIGN_NAME}/${PLACE_OPT_BLOCK_NAME}_MSCTS

			}
	
	        } elseif {$CTS_STYLE != "standard"} {
			puts "RM-error: Specified CTS_STYLE($CTS_STYLE) is not supported, standard will be used."
		}
 
		place_opt
	
	}
}

##########################################################################################
## Post-place_opt customizations
##########################################################################################
rm_source -file $TCL_USER_PLACE_OPT_POST_SCRIPT -optional -print "TCL_USER_PLACE_OPT_POST_SCRIPT"

## Spare cell insertion after place_opt
rm_source -file $TCL_USER_SPARE_CELL_POST_SCRIPT -optional -print "TCL_USER_SPARE_CELL_POST_SCRIPT"
##########################################################################################
#### Indesign PrimePower 
##########################################################################################
if {([check_license -quiet "ICCompilerII-4"] || [check_license -quiet "ICCompilerII"]) && [llength $TCL_PRIMEPOWER_CONFIG_FILE]> 0  && [lsearch $INDESIGN_PRIMEPOWER_STAGES "AFTER_PLACE_OPT"] >= 0} {
        ## Specify Indesign PrimePower confguration needed per your design
        ## Example for Indesign PrimePower config :             examples/TCL_PRIMEPOWER_CONFIG_FILE.indesign_options.tcl
        rm_source -file $TCL_PRIMEPOWER_CONFIG_FILE -print "ENABLE_PRIMEPOWER requires a proper TCL_PRIMEPOWER_CONFIG_FILE"
        set update_indesign_cmd "update_indesign_activity"
        if {$KEEP_INDESIGN_SAIF_FILE} {lappend update_indesign_cmd -keep_saif -saif_suffix place_opt}
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
 	set REPORT_STAGE placement
 	set REPORT_ACTIVE_SCENARIOS $REPORT_PLACE_OPT_ACTIVE_SCENARIO_LIST
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
rm_logparse $LOGS_DIR/place_opt.log
echo [date] > place_opt

exit 
