##########################################################################################
# Script: route_opt.tcl
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################

source ./rm_utilities/procs_global.tcl 
source ./rm_utilities/procs_icc2.tcl 
rm_source -file ./rm_setup/design_setup.tcl
rm_source -file ./rm_setup/icc2_pnr_setup.tcl
rm_source -file ./rm_setup/header_icc2_pnr.tcl
rm_source -file sidefile_setup.tcl -after_file technology_override.tcl
set PREVIOUS_STEP $ROUTE_AUTO_BLOCK_NAME
set CURRENT_STEP $ROUTE_OPT_BLOCK_NAME
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
## Swap abstracts if abstracts specified for route_auto and route_opt are different
if {$DESIGN_STYLE == "hier"} {
	if {$USE_ABSTRACTS_FOR_BLOCKS != "" && ($BLOCK_ABSTRACT_FOR_ROUTE_OPT != $BLOCK_ABSTRACT_FOR_ROUTE_AUTO)} {
		puts "RM-info: Swapping from [lindex $BLOCK_ABSTRACT_FOR_ROUTE_AUTO 0] to [lindex $BLOCK_ABSTRACT_FOR_ROUTE_OPT 0] abstracts for all blocks."
		change_abstract -references $USE_ABSTRACTS_FOR_BLOCKS -label [lindex $BLOCK_ABSTRACT_FOR_ROUTE_OPT 0] -view [lindex $BLOCK_ABSTRACT_FOR_ROUTE_OPT 1]
		report_abstracts
	}
}

if {$ROUTE_OPT_ACTIVE_SCENARIO_LIST != ""} {
	set_scenario_status -active false [get_scenarios -filter active]
	set_scenario_status -active true $ROUTE_OPT_ACTIVE_SCENARIO_LIST
}

## Adjustment file for modes/corners/scenarios/models to applied to each step (optional)
rm_source -file $TCL_MODE_CORNER_SCENARIO_MODEL_ADJUSTMENT_FILE -optional -print "TCL_MODE_CORNER_SCENARIO_MODEL_ADJUSTMENT_FILE"

rm_source -file $TCL_LIB_CELL_PURPOSE_FILE -optional -print "TCL_LIB_CELL_PURPOSE_FILE"


## Non-persistent settings to be applied in each step (optional)
rm_source -file $TCL_USER_NON_PERSISTENT_SCRIPT -optional -print "TCL_USER_NON_PERSISTENT_SCRIPT"

## Multi Vt constraint file to be applied in each step (optional)
rm_source -file $TCL_MULTI_VT_CONSTRAINT_FILE -optional -print "TCL_MULTI_VT_CONSTRAINT_FILE"

##########################################################################################
## Settings
##########################################################################################
## set_stage : a command to apply stage-based application options; intended to be used after set_qor_strategy within RM scripts.
set_stage -step post_route

## Prefix
set_app_options -name opt.common.user_instance_name_prefix -value route_opt_
set_app_options -name cts.common.user_instance_name_prefix -value route_opt_cts_

rm_source -file $SIDEFILE_ROUTE_OPT -optional -print "SIDEFILE_ROUTE_OPT"

## For set_qor_strategy -metric leakage, disabling the dynamic power analysis in active scenarios for optimization
# Scenario power analysis will be renabled after optimization for reporting
if {$SET_QOR_STRATEGY_METRIC == "leakage_power" || $SET_QOR_STRATEGY_METRIC == "timing"} {
   set rm_dynamic_scenarios [get_object_name [get_scenarios -filter active==true&&dynamic_power==true]]

   if {[llength $rm_dynamic_scenarios] > 0} {
      puts "RM-info: Disabling dynamic analysis for $rm_dynamic_scenarios"
      set_scenario_status -dynamic_power false [get_scenarios $rm_dynamic_scenarios]
  }
}

## StarRC in-design extraction (optional) : a config file is required to set up a proper StarRC run
## If a config file is not provided, route_opt reverts to the tool's native extraction. Example : route_opt.starrc_config_example.txt
if {[file exists [which $ROUTE_OPT_STARRC_CONFIG_FILE]]} {
	if {$REPORT_PARALLEL_SUBMIT_COMMAND != ""} {set ROUTE_OPT_STARRC_CONFIG_FILE [file normalize $ROUTE_OPT_STARRC_CONFIG_FILE]}
	set set_starrc_in_design_cmd "set_starrc_in_design -config $ROUTE_OPT_STARRC_CONFIG_FILE $SET_STARRC_IN_DESIGN_OPTIONS"
	puts "RM-info: running $set_starrc_in_design_cmd"
	eval $set_starrc_in_design_cmd
} elseif {$ROUTE_OPT_STARRC_CONFIG_FILE != ""} {
	puts "RM-error: ROUTE_OPT_STARRC_CONFIG_FILE($ROUTE_OPT_STARRC_CONFIG_FILE) is invalid. Please correct it."
}

## StarRC in-design extraction validation flow
## Discover potential setup issues of StarRC in-design extraction before running route_opt.
## Low effort performs setup checks for config file path, StarRC path, layer mapping file path, and corner mapping;
## medium effort creates StarRC command file in your local dir; high effort invokes StarRC. 
#	check_starrc_in_design -effort <low|medium|high>

## Virtual Metal Fill
if {[file exists [which $VMF_PARAMETER_FILE]]} {
	if {$ENABLE_ADVANCED_VMF} {set_app_options -name extract.apply_vmf_all -value true}
	if {$REPORT_PARALLEL_SUBMIT_COMMAND != ""} {set VMF_PARAMETER_FILE [file normalize $VMF_PARAMETER_FILE]}
	set set_extraction_vmf_cmd "set_extraction_options -virtual_metalfill_parameter_file $VMF_PARAMETER_FILE $SET_VMF_EXTRACTION_OPTIONS"
	puts "RM-info: running $set_extraction_vmf_cmd"
	eval $set_extraction_vmf_cmd
} elseif {$VMF_PARAMETER_FILE != ""} {
	puts "RM-error: VMF_PARAMETER_FILE($VMF_PARAMETER_FILE) is invalid. Please correct it."
}


##########################################################################################
## Pre-route_opt customizations
##########################################################################################
rm_source -file $TCL_USER_ROUTE_OPT_PRE_SCRIPT -optional -print "TCL_USER_ROUTE_OPT_PRE_SCRIPT"

redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_app_options.start {report_app_options -non_default *}
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_lib_cell_purpose {report_lib_cell -objects [get_lib_cells] -column {full_name:20 valid_purposes}}

if {$ENABLE_INLINE_REPORT_QOR} {
   redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_qor.start {report_qor -scenarios [all_scenarios] -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit}
   redirect -append -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_qor.start {report_qor -summary -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit}
   redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_global_timing.start {report_global_timing -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit}
}

set check_stage_settings_cmd "check_stage_settings -stage pnr -metric \"${SET_QOR_STRATEGY_METRIC}\" -step post_route"
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
## route_opt flow
##########################################################################################
if {[get_drc_error_data -quiet zroute.err] == ""} {open_drc_error_data zroute.err}
set rm_drc_before_corecmd [sizeof_collection [get_drc_errors -quiet -error_data zroute.err]]

compute_clock_latency

if {![rm_source -file $TCL_USER_ROUTE_OPT_SCRIPT -optional -print "TCL_USER_ROUTE_OPT_SCRIPT"]} {
## Note : the following executes if TCL_USER_ROUTE_OPT_SCRIPT is not sourced

	if {!$ENABLE_ROUTE_OPT_PBA} {
		set_app_options -name time.pba_optimization_mode -value none
	}

	if {$ENABLE_IRDCCD} {
		rm_source -file $TCL_IRDCCD_CONFIG_FILE -print "IRD-CCD requires a proper TCL_IRDCCD_CONFIG_FILE"
	}

	##########################################################################
	## hyper_route_opt
	##########################################################################
	
	## A proc for hyper_route_opt. The incldued commands will be performed during hyper_route_opt after phase2 and before phase3
	## 	- add_redundant_vias is an optional feature
	## 	- TCL_USER_ROUTE_OPT_1_POST_SCRIPT and TCL_USER_ROUTE_OPT_2_POST_SCRIPT allow you to specify optional Tcl files to be sourced.
	##	- In the future, the two variables will be consolidated into one. RIght now, they both will be sourced one after the other. 
	proc snps_hyper_route_opt_post_eco {} {
	
		global ENABLE_REDUNDANT_VIA_INSERTION TCL_USER_ROUTE_OPT_1_POST_SCRIPT TCL_USER_ROUTE_OPT_2_POST_SCRIPT TCL_USER_REDUNDANT_VIA_SCRIPT
		
		## Redundant via insertion
		if {$ENABLE_REDUNDANT_VIA_INSERTION} {
			if {![rm_source -file $TCL_USER_REDUNDANT_VIA_SCRIPT -optional -print "TCL_USER_REDUNDANT_VIA_SCRIPT"]} {
			puts "RM-info: Running add_redundant_vias."
			add_redundant_vias -timing_preserve_setup_slack_threshold 0
			}
		}	
		rm_source -file $TCL_USER_ROUTE_OPT_1_POST_SCRIPT -optional -print "TCL_USER_ROUTE_OPT_1_POST_SCRIPT"
		rm_source -file $TCL_USER_ROUTE_OPT_2_POST_SCRIPT -optional -print "TCL_USER_ROUTE_OPT_2_POST_SCRIPT"
	
	}
	
	puts "RM-info: Running hyper_route_opt."
	hyper_route_opt
} 

## Redundant via insertion, command execution
## For designs with advanced nodes where DRC convergence could be a concern, it is recommended to be done after route_auto/route_opt
if {$ENABLE_POST_ROUTE_OPT_REDUNDANT_VIA_INSERTION} {
	if {![rm_source -file $TCL_USER_REDUNDANT_VIA_SCRIPT -optional -print "TCL_USER_REDUNDANT_VIA_SCRIPT"]} {
		add_redundant_vias
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
## FuSa Setup
##########################################################################################
## insert taps if defined in rules
if {[sizeof_collection [get_safety_register_groups -quiet]]} {
	create_safety_tap_cells 
}


##########################################################################################
## Post-route_opt customizations
##########################################################################################
rm_source -file $TCL_USER_ROUTE_OPT_POST_SCRIPT -optional -print "TCL_USER_ROUTE_OPT_POST_SCRIPT" 

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
### Indesign PrimePower 
##########################################################################################
if {([check_license -quiet "ICCompilerII-4"] || [check_license -quiet "ICCompilerII"]) && [llength $TCL_PRIMEPOWER_CONFIG_FILE]> 0  && [lsearch $INDESIGN_PRIMEPOWER_STAGES "AFTER_ROUTE_OPT"] >= 0} {
        ## Specify Indesign PrimePower confguration needed per your design
        ## Example for Indesign PrimePower config :             examples/TCL_PRIMEPOWER_CONFIG_FILE.indesign_options.tcl
        rm_source -file $TCL_PRIMEPOWER_CONFIG_FILE -print "ENABLE_PRIMEPOWER requires a proper TCL_PRIMEPOWER_CONFIG_FILE"
        set update_indesign_cmd "update_indesign_activity -power"
        if {$KEEP_INDESIGN_SAIF_FILE} {lappend update_indesign_cmd -keep_saif -saif_suffix route_opt}
        puts "RM-info: Running ${update_indesign_cmd}"
  	eval ${update_indesign_cmd}
}

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
	set REPORT_STAGE post_route
        set REPORT_ACTIVE_SCENARIOS $REPORT_ROUTE_OPT_ACTIVE_SCENARIO_LIST
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
rm_logparse $LOGS_DIR/route_opt.log
echo [date] > route_opt

exit 
