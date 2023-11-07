##########################################################################################
# Script: chip_finish.tcl
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################

source ./rm_utilities/procs_global.tcl 
source ./rm_utilities/procs_icc2.tcl 
rm_source -file ./rm_setup/design_setup.tcl
rm_source -file ./rm_setup/icc2_pnr_setup.tcl
rm_source -file ./rm_setup/header_icc2_pnr.tcl
rm_source -file sidefile_setup.tcl -after_file technology_override.tcl
set PREVIOUS_STEP $CHIP_FINISH_FROM_BLOCK_NAME
set CURRENT_STEP  $CHIP_FINISH_BLOCK_NAME
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
## Swap abstracts if abstracts specified for route_opt and chip_finish are different
if {$DESIGN_STYLE == "hier"} {
   if {$USE_ABSTRACTS_FOR_BLOCKS != "" && ($BLOCK_ABSTRACT_FOR_CHIP_FINISH != $BLOCK_ABSTRACT_FOR_ROUTE_OPT)} {
      puts "RM-info: Swapping from [lindex $BLOCK_ABSTRACT_FOR_ROUTE_OPT 0] to [lindex $BLOCK_ABSTRACT_FOR_CHIP_FINISH 0] abstracts for all blocks."
      change_abstract -references $USE_ABSTRACTS_FOR_BLOCKS -label [lindex $BLOCK_ABSTRACT_FOR_CHIP_FINISH 0] -view [lindex $BLOCK_ABSTRACT_FOR_CHIP_FINISH 1]
      report_abstracts
   }
}

if {$CHIP_FINISH_ACTIVE_SCENARIO_LIST != ""} {
	set_scenario_status -active false [get_scenarios -filter active]
	set_scenario_status -active true $CHIP_FINISH_ACTIVE_SCENARIO_LIST
}

## Adjustment file for modes/corners/scenarios/models to applied to each step (optional)
rm_source -file $TCL_MODE_CORNER_SCENARIO_MODEL_ADJUSTMENT_FILE -optional -print "TCL_MODE_CORNER_SCENARIO_MODEL_ADJUSTMENT_FILE"

## Non-persistent settings to be applied in each step (optional)
rm_source -file $TCL_USER_NON_PERSISTENT_SCRIPT -optional -print "TCL_USER_NON_PERSISTENT_SCRIPT"

## Disable soft-rule-based timing optimization during ECO routing.
#  This is to limit spreading which can touch multiple nets and impact convergence.
set_app_options -name route.detail.eco_route_use_soft_spacing_for_timing_optimization -value false

####################################
## Pre-chip_finish customizations
####################################
rm_source -file $TCL_USER_CHIP_FINISH_PRE_SCRIPT -optional -print "TCL_USER_CHIP_FINISH_PRE_SCRIPT"

####################################
## report_app_options & report_lib_cell_purpose	
####################################
redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_app_options.start {report_app_options -non_default *}
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_lib_cell_purpose {report_lib_cell -objects [get_lib_cells] -column {full_name:20 valid_purposes}}

## The following only applies to designs with physical hierarchy
## Ignore the sub-blocks (bound to abstracts) internal timing paths
if {$DESIGN_STYLE == "hier" && $PHYSICAL_HIERARCHY_LEVEL != "bottom"} {
    set_timing_paths_disabled_blocks  -all_sub_blocks
}
if {$ENABLE_INLINE_REPORT_QOR} {
   redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_qor.start {report_qor -scenarios [all_scenarios] -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit}
   redirect -append -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_qor.start {report_qor -summary -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit}
   redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_global_timing.start {report_global_timing -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit}
}

####################################
## Filler cell insertion
####################################
if {[info exists rm_dp_flow] && [get_attribute -quiet [current_design] rm_fp_bf_attr] != ""} {
	rm_legalize_placement
}

## Below are the commands for creating standard cell metal and non-metal fillers.
#  For designs with a smallest cell size of 2 sites, to prevent 1x gaps,
#  append either the option -smallest_cell_size 2 or -rules {no_1x}
#  For designs with a smallest cell size of 3 sites, to prevent 1x and 2x gaps,
#  append the option -smallest_cell_size 3

rm_source -file $SIDEFILE_CHIP_FINISH_1 -optional -print "SIDEFILE_CHIP_FINISH_1"

## To remove filler cells in the design :
#	remove_cells [get your_filler_cells]

####################################
## Signal EM analysis and fix	
####################################
	## Loading EM constraint is required for EM analysis and fixing.
	if {[file exists [which $CHIP_FINISH_SIGNAL_EM_CONSTRAINT_FILE]]} {
		set read_signal_em_constraints_cmd "read_signal_em_constraints $CHIP_FINISH_SIGNAL_EM_CONSTRAINT_FILE"
		switch -regexp $CHIP_FINISH_SIGNAL_EM_CONSTRAINT_FORMAT {
			"ITF"      {lappend read_signal_em_constraints_cmd -format ITF}
			"ALF"      {lappend read_signal_em_constraints_cmd -format ALF}
		}
		puts "RM-info: $read_signal_em_constraints_cmd"
		eval $read_signal_em_constraints_cmd
  
		## Loading and setting switching activity is optional
		#  ex, set_switching_activity -rise_toggle_rate <positive number> -fall_toggle_rate -static_probability <0to1> [get_nets -hier *]
		if {[file exists [which $CHIP_FINISH_SIGNAL_EM_SAIF]]} {
			read_saif $CHIP_FINISH_SIGNAL_EM_SAIF
		} elseif {$CHIP_FINISH_SIGNAL_EM_SAIF != ""} {
			puts "RM-error: CHIP_FINISH_SIGNAL_EM_SAIF($CHIP_FINISH_SIGNAL_EM_SAIF) is invalid. Please correct it."
		}

		## Signal EM analysis and fixing require CHIP_FINISH_SIGNAL_EM_SCENARIO to be specified, active, and enabled for setup and hold
		if {$CHIP_FINISH_SIGNAL_EM_SCENARIO != ""} {
			if {[regexp $CHIP_FINISH_SIGNAL_EM_SCENARIO [get_object_name [get_scenarios -filter "setup&&hold&&active"]]]} {
				## Recommended to have SI enabled so delta transition and coupling capacitance are considered in signal EM analysis
				if {![get_app_option_value -name time.si_enable_analysis]} {
					set RM_current_value_enable_si false
					set_app_options -name time.si_enable_analysis -value true
				}

				set RM_current_value_scenario [current_scenario]
				current_scenario $CHIP_FINISH_SIGNAL_EM_SCENARIO
				redirect -tee -file ${REPORTS_DIR}/chip_finish.report_signal_em {report_signal_em -violated}

				if {$CHIP_FINISH_SIGNAL_EM_FIXING} {
				## Fix all EM violations in the whole design including clock and signal nets.
				#  The command uses information from the current mode and corner. 
					fix_signal_em
					redirect -tee -file ${REPORTS_DIR}/chip_finish.report_signal_em.post {report_signal_em -violated}
				}
				current_scenario ${RM_current_value_scenario}

				## Restore user default of time.si_enable_analysis
				if {[info exists RM_current_value_enable_si] && !${RM_current_value_enable_si}} {
					set_app_options -name time.si_enable_analysis -value false
				}
			} else {
				puts "RM-error: CHIP_FINISH_SIGNAL_EM_SCENARIO must be active and enabled for setup and hold. Signal EM analysis and fixing are skipped."
			}
		} else {
			puts "RM-error: CHIP_FINISH_SIGNAL_EM_SCENARIO is not specified. Signal EM analysis and fixing are skipped."
		}
	} elseif {$CHIP_FINISH_SIGNAL_EM_CONSTRAINT_FILE != ""} {
		puts "RM-error: CHIP_FINISH_SIGNAL_EM_CONSTRAINT_FILE($CHIP_FINISH_SIGNAL_EM_CONSTRAINT_FILE) is invalid. Please correct it."
	}

rm_source -file $SIDEFILE_CHIP_FINISH_2 -optional -print "SIDEFILE_CHIP_FINISH_2"

####################################
## Post-chip_finish customizations
####################################
rm_source -file $TCL_USER_CHIP_FINISH_POST_SCRIPT -optional -print "TCL_USER_CHIP_FINISH_POST_SCRIPT"

if {![rm_source -file $TCL_USER_CONNECT_PG_NET_SCRIPT -optional -print "TCL_USER_CONNECT_PG_NET_SCRIPT"]} {
## Note : the following executes only if TCL_USER_CONNECT_PG_NET_SCRIPT is not sourced
	connect_pg_net
        # For non-MV designs with more than one PG, you should use connect_pg_net in manual mode.
}

## Run check_routes to save updated routing DRC to the block
redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_routes {check_routes}

save_block

####################################
## Create abstract and frame
####################################
## Enabled for hierarchical designs; for bottom and intermediate levels of physical hierarchy
if {$DESIGN_STYLE == "hier" && $PHYSICAL_HIERARCHY_LEVEL != "top" && !$SKIP_ABSTRACT_GENERATION} {
        if {$USE_ABSTRACTS_FOR_POWER_ANALYSIS == "true"} {
                set_app_options -name abstract.annotate_power -value true
        }
        if {$USE_ABSTRACTS_FOR_SIGNAL_EM_ANALYSIS == "true"} {
                set_app_options -name abstract.enable_signal_em_analysis -value true
        }
        if { $PHYSICAL_HIERARCHY_LEVEL == "bottom" } {
                create_abstract -read_only
                create_frame -block_all true
                derive_hier_antenna_property -design ${DESIGN_NAME}/${CHIP_FINISH_BLOCK_NAME}
                save_block ${DESIGN_NAME}/${CHIP_FINISH_BLOCK_NAME}.frame

        } elseif { $PHYSICAL_HIERARCHY_LEVEL == "intermediate"} {
            if { $ABSTRACT_TYPE_FOR_MPH_BLOCKS == "nested"} {
                ## Create nested abstract for the intermediate level of physical hierarchy
                create_abstract -read_only
            } elseif { $ABSTRACT_TYPE_FOR_MPH_BLOCKS == "flattened"} {
                ## Create flattened abstract for the intermediate level of physical hierarchy
                create_abstract -read_only -preserve_block_instances false
            }
            create_frame -block_all true
            derive_hier_antenna_property -design ${DESIGN_NAME}/${CHIP_FINISH_BLOCK_NAME}
	    save_block ${DESIGN_NAME}/${CHIP_FINISH_BLOCK_NAME}.frame
        }
}

####################################
## Report and output
####################################
if {$REPORT_QOR} {
	set REPORT_STAGE post_route
        set REPORT_ACTIVE_SCENARIOS $REPORT_CHIP_FINISH_ACTIVE_SCENARIO_LIST
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
rm_logparse $LOGS_DIR/chip_finish.log
echo [date] > chip_finish

exit 
