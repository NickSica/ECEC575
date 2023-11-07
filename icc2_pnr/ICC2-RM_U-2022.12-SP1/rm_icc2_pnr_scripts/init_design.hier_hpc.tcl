##########################################################################################
# Script: init_design_hpc.tcl
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################

source ./rm_utilities/procs_global.tcl 
source ./rm_utilities/procs_icc2.tcl 
rm_source -file ./rm_setup/design_setup.tcl
rm_source -file ./rm_setup/icc2_pnr_setup.tcl
rm_source -file ./rm_setup/header_icc2_pnr.tcl
rm_source -file sidefile_setup.tcl -after_file technology_override.tcl

set CURRENT_STEP ${INIT_DESIGN_BLOCK_NAME} 

if { [info exists env(RM_VARFILE)] } { 
  if { [file exists $env(RM_VARFILE)] } { 
    rm_source -file $env(RM_VARFILE)
  } else {
    puts "RM-error: env(RM_VARFILE) specified but not found"
  }
}

set REPORT_PREFIX ${CURRENT_STEP}
file mkdir ${REPORTS_DIR}/${REPORT_PREFIX}
puts "RM-info: CURRENT_STEP  = $CURRENT_STEP"
puts "RM-info: REPORT_PREFIX = $REPORT_PREFIX"
redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/run_start.rpt {run_start}

## Non-persistent settings to be applied in each step (optional)
rm_source -file $TCL_USER_NON_PERSISTENT_SCRIPT -optional -print "TCL_USER_NON_PERSISTENT_SCRIPT"

rm_source -file $TCL_USER_INIT_DESIGN_PRE_SCRIPT -optional -print "TCL_USER_INIT_DESIGN_PRE_SCRIPT"

########################################################################
## Design library creation/import
########################################################################
if {$INIT_DESIGN_INPUT == "NDM"} {
	if {[file exists $INIT_DESIGN_INPUT_LIBRARY] && $INIT_DESIGN_INPUT_BLOCK_NAME != ""} {
        	if {[file exists $DESIGN_LIBRARY]} {
			file delete -force $DESIGN_LIBRARY
		}
		## Copy the library and final label from DP RM output
		open_lib -read ${INIT_DESIGN_INPUT_LIBRARY}
		copy_lib -from_lib ${INIT_DESIGN_INPUT_LIBRARY} -to_lib ${DESIGN_LIBRARY} -no_design
		copy_block -from ${INIT_DESIGN_INPUT_LIBRARY}:${DESIGN_NAME}/${INIT_DESIGN_INPUT_BLOCK_NAME} -to ${DESIGN_LIBRARY}:${DESIGN_NAME}/${INIT_DESIGN_BLOCK_NAME}
		close_lib ${INIT_DESIGN_INPUT_LIBRARY}
		current_lib ${DESIGN_LIBRARY}
		current_block ${DESIGN_NAME}/${INIT_DESIGN_BLOCK_NAME}
		
		if {$SET_QOR_STRATEGY_MODE == "early_design"} {
			## Automatically enable lenient policy for early_design mode 
			set_early_data_check_policy -policy lenient -if_not_exist
		} elseif {$EARLY_DATA_CHECK_POLICY != "none"} {
			## Design check manager
			set_early_data_check_policy -policy $EARLY_DATA_CHECK_POLICY -if_not_exist
		}
		
		if {$DESIGN_STYLE == "hier" && $PHYSICAL_HIERARCHY_LEVEL != "bottom"} {
			## For top or intermediate level of hier designs:
			## - Copy the library and final label from hier DP RM output
			## - Change block reference libraries and abstracts to PNR RM output
			if {$USE_ABSTRACTS_FOR_BLOCKS != ""} {
				set label_name $BLOCK_ABSTRACT_FOR_PLACE_OPT 
				set top_block [current_block]
				foreach BLOCK $SUB_BLOCK_REFS {
					if {[lsearch $SUB_BLOCK_LIBRARIES *${BLOCK}${LIBRARY_SUFFIX}] >= 0} {
						set library [lindex $SUB_BLOCK_LIBRARIES [lsearch $SUB_BLOCK_LIBRARIES *${BLOCK}${LIBRARY_SUFFIX}]]
						puts "RM-info: Swap abstract for $BLOCK to PNR block library and block label $BLOCK_ABSTRACT_FOR_COMPILE."
						open_lib -read $library
						current_block $top_block
						change_abstract -lib [get_libs -explicit ${BLOCK}${LIBRARY_SUFFIX}] -references ${BLOCK} -label [lindex $BLOCK_ABSTRACT_FOR_COMPILE 0] -view [lindex $BLOCK_ABSTRACT_FOR_COMPILE 1] -update_ref_libs
						close_lib $library
						current_block $top_block
					} else {
						puts "RM-error: Library does not exist for ${BLOCK}${LIBRARY_SUFFIX}. Exiting"
						exit
					}
				}
				report_abstracts
			}

			## Set the editability of the sub-blocks to false
       			set_editability -blocks [get_blocks -hierarchical] -value false
        		report_editability -blocks [get_blocks -hierarchical]

        		## Ignore the sub-blocks internal timing paths
        		if {$USE_ABSTRACTS_FOR_BLOCKS != ""} {
              			set_timing_paths_disabled_blocks -all_sub_blocks
        		}		
		}
	} else {
		puts "RM-error: INIT_DESIGN_INPUT is set to NDM but either INIT_DESIGN_INPUT_LIBRARY or INIT_DESIGN_INPUT_BLOCK_NAME is invalid. Please fix it before you continue."
		exit
	}
} else {
	puts "RM-error: The HPC flow only supports INIT_DESIGN_INPUT==NDM.   Please fix...exiting."
	exit
} ;# INIT_DESIGN_INPUT == NDM

########################################################################
## Load Node Specific Settings 
########################################################################
if {$TECHNOLOGY_NODE != ""} {
  set_technology -node $TECHNOLOGY_NODE
}

################################################################
## Via ladder
################################################################
## (Optional) source user provided via ladder definitions, if not defined in your technology file
## 20220429: Not needed as sourced in DP flow.
##rm_source -file $TCL_VIA_LADDER_DEFINITION_FILE -optional -print "TCL_VIA_LADDER_DEFINITION_FILE"

## (Optional) source user provided library specific via ladder constraints
## For ex, set_via_ladder_candidate [get_lib_pins */AIOI/ZN] -ladder_name "VP"
## For ex, set_attribute -quiet [get_lib_pins */AIOI/ZN] is_em_via_ladder_required true
## 20220429: Not needed as sourced in DP flow.
##rm_source -file $TCL_SET_VIA_LADDER_CANDIDATE_FILE -optional -print "TCL_SET_VIA_LADDER_CANDIDATE_FILE"

########################################################################
## Basic floorplan and design checks
########################################################################
set RM_FAILURE 0 ;# flag for critical issues

## Check for existence of site rows
if {[sizeof_collection [get_site_rows -quiet]] == 0 && [sizeof_collection [get_site_arrays -quiet]] == 0} {
	set RM_FAILURE 1
	puts "RM-error: Design has no site rows or site arrays. Please fix it before you continue!"
}
## Check for existence of terminals
if {[sizeof_collection [get_terminals -filter "port.port_type==signal" -quiet]] == 0} {
	set RM_FAILURE 1
	puts "RM-error: Design has no signal terminals. Please fix it before you continue!"
}
## Check for existence of tracks
if {[sizeof_collection [get_tracks -quiet]] == 0} {
	set RM_FAILURE 1
	puts "RM-error: Design has no tracks. Please fix it before you continue!"
}
## Check for existence of PG
if {[sizeof_collection [get_shapes -filter "net_type==power"]] == 0 || [sizeof_collection [get_shapes -filter "net_type==ground"]] == 0} {
	#set RM_FAILURE 1
	puts "RM-warning: Design does not contain any PG shapes. You do not have proper PG structure. If this is unexpected, please double check before you continue!"
}
## Check for unplaced macro placement
if {[sizeof_collection [get_cells -hier -filter "is_hard_macro&&!is_placed"]]} {
	set RM_FAILURE 1
	puts "RM-error: Design has unplaced hard macros. Please fix it before you continue!"
}
## Check for boundary and tap cells
if {[sizeof_collection [get_cells -hier -filter "is_physical_only&&(design_type=~*cap||design_type=~*tap)"]] == 0} {
	puts "RM-warning: Design has no boundary or tap cells. If this is unexpected, please double check before you continue!"
}
## Check for unplaced or unfixed boundary and tap cells
if {[sizeof_collection [get_cells -hier -filter "is_physical_only&&(design_type=~*cap||design_type=~*tap)&&(!is_placed||!is_fixed)"]]} {
	#set RM_FAILURE 1
	puts "RM-error: Design has unplaced boundary or tap cells. Please fix it before you continue!"
}
## check_floorplan_rules : pls check the report for potential issues
rm_source -file $TCL_FLOORPLAN_RULE_SCRIPT -optional -print "TCL_FLOORPLAN_RULE_SCRIPT"
redirect -var x {catch {report_floorplan_rules}}
if {![regexp "^.*No floorplan rules exist" $x]} {
	redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_floorplan_rules.rpt {check_floorplan_rules}
}

########################################################################
## Additional constraints
########################################################################

## Remove all propagated clocks
set cur_mode [current_mode]
foreach_in_collection mode [all_modes] {
	current_mode $mode
        remove_propagated_clocks [all_clocks]
	remove_propagated_clocks [get_ports]
	remove_propagated_clocks [get_pins -hierarchical]
}
current_mode $cur_mode

## Clock NDR
## Specify TCL_CTS_NDR_RULE_FILE with your script to create and associate your clock NDR rules.
## RM default is ./examples/cts_ndr.tcl which is an RM provided example. Refer to the script for setup and details.
## You need to also specify CTS_NDR_RULE_NAME, CTS_INTERNAL_NDR_RULE_NAME, or CTS_LEAF_NDR_RULE_NAME for it to take effect.
rm_source -file $TCL_CTS_NDR_RULE_FILE -optional -print "TCL_CTS_NDR_RULE_FILE"
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_routing_rules {report_routing_rules -verbose}
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_clock_routing_rules {report_clock_routing_rules}
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_clock_settings {report_clock_settings}

##########################################################################################################################
## HPC related
#########################################################################################################################

## Reset CCD application options to true after setting to false for budgeting.
set_app_options -name ccd.adjust_io_clock_latency  -value true ; # Allow CCD to adjust I/O virtual clock latencies
set_app_options -name ccd.optimize_boundary_timing -value true ; # Allow CCD to adjust clock latencies of boundary flops

#################################
# Create Path groups
#################################
puts "RM-info: Creating path groups in all modes. This will trigger a timing update and will take some time."
set orig_mode [current_mode]
foreach_in_collection mo [get_modes] {
  puts "RM-info: Working on mode: [get_object_name $mo]"
  current_mode $mo
  puts "RM-info:   Number of path groups (Original)         : [ sizeof_collection [ get_path_groups -quiet ] ]"
  rm_source -file $PATH_GROUPS_SCRIPT -print PATH_GROUPS_SCRIPT
  puts "RM-info:   Number of path groups (After the removal): [ sizeof_collection [ get_path_groups -quiet ] ]"
}
current_mode $orig_mode

## Source power strategy HPC sidefile.
rm_source -file $HPC_POWER_STRATEGY -optional -print "HPC_POWER_STRATEGY"

#################################
# Create Bounds
#################################
if {![info exists RECREATE_BOUNDS_IN_COMPILE] || $RECREATE_BOUNDS_IN_COMPILE == 0} {
  puts "RM-info: Not recreating bounds for $DESIGN_NAME"
} else {
  puts "RM-info: Recreating bounds for $DESIGN_NAME"
  rm_source -file $CREATE_BLOCK_BOUNDS_SCRIPT($DESIGN_NAME) -print CREATE_BLOCK_BOUNDS_SCRIPT
}

###########################################################################################
## Read_saif
###########################################################################################
if {$SAIF_FILE_LIST != "" && $saif_inst_name($DESIGN_NAME) != ""} {
	if {$SAIF_FILE_POWER_SCENARIO != ""} {
		set read_saif_cmd "read_saif \"$SAIF_FILE_LIST\" -scenarios \"$SAIF_FILE_POWER_SCENARIO\""
	} else {
		set read_saif_cmd "read_saif \"$SAIF_FILE_LIST\""
	}
	if {$saif_inst_name($DESIGN_NAME) != ""} {lappend read_saif_cmd -strip_path $saif_inst_name($DESIGN_NAME)}
	if {$SAIF_FILE_TARGET_INSTANCE != ""} {lappend read_saif_cmd -path $SAIF_FILE_TARGET_INSTANCE}
	puts "RM-info: Running $read_saif_cmd"
    	eval ${read_saif_cmd}
	if {$SAIF_FILE_POWER_SCENARIO != ""} {
          redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_activity {report_activity -driver -show_zeros -verbose -scenarios $SAIF_FILE_POWER_SCENARIO}
	} else {
          redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_activity {report_activity -driver -show_zeros -verbose}
	}
}

####################################
## Post-init_design customizations
####################################
rm_source -file $TCL_USER_INIT_DESIGN_POST_SCRIPT -optional -print "TCL_USER_INIT_DESIGN_POST_SCRIPT"

save_upf ${OUTPUTS_DIR}/${INIT_DESIGN_BLOCK_NAME}.save_upf
save_block
save_block -as ${DESIGN_NAME}/${INIT_DESIGN_BLOCK_NAME}

####################################
## Sanity checks and QoR Report	
####################################
if {$REPORT_QOR} {
	set REPORT_STAGE init_design
	if {$REPORT_PARALLEL_SUBMIT_COMMAND != ""} {
		## Generate a file to pass necessary RM variables for running report_qor.tcl to the report_parallel command
		rm_generate_variables_for_report_parallel -work_directory ${REPORTS_DIR}/${REPORT_PREFIX} -file_name rm_tcl_var.tcl

		## Parallel reporting using the report_parallel command (requires a valid REPORT_PARALLEL_SUBMIT_COMMAND)
		report_parallel -work_directory ${REPORTS_DIR}/${REPORT_PREFIX} -submit_command ${REPORT_PARALLEL_SUBMIT_COMMAND} -max_cores ${REPORT_PARALLEL_MAX_CORES} -user_scripts [list "${REPORTS_DIR}/${REPORT_PREFIX}/rm_tcl_var.tcl" "[which report_qor.tcl]"]
	} else {
		## Classic reporting
		rm_source -file report_qor.tcl
	}
	write_tech_file ${REPORTS_DIR}/${REPORT_PREFIX}/tech_file.dump
}

redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/run_end.rpt {run_end}

write_qor_data -report_list "performance host_machine report_app_options" -label $REPORT_PREFIX -output $WRITE_QOR_DATA_DIR

report_msg -summary
print_message_info -ids * -summary
if {!$RM_FAILURE} {
	echo [date] > init_design
} else {
	puts "RM-info: init_design touch file was not created due to potential issues found in \"Basic floorplan and design checks\" section. Please check RM-error messages in the log."
}
exit
