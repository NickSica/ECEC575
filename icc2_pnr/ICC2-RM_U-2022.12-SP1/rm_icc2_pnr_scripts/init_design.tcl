##########################################################################################
# Script: init_design.tcl
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################

source ./rm_utilities/procs_global.tcl 
source ./rm_utilities/procs_icc2.tcl 
rm_source -file ./rm_setup/design_setup.tcl
rm_source -file ./rm_setup/icc2_pnr_setup.tcl
rm_source -file ./rm_setup/header_icc2_pnr.tcl
rm_source -file sidefile_setup.tcl -after_file technology_override.tcl
if {[file exists header_from_dprm.tcl]} {rm_source -file header_from_dprm.tcl}
set CURRENT_STEP  $INIT_DESIGN_BLOCK_NAME
if { [info exists env(RM_VARFILE)] } {
	if { [file exists $env(RM_VARFILE)] } {
		rm_source -file $env(RM_VARFILE)
	} else {
		puts "RM-error: env(RM_VARFILE) specified but not found"
	}
}

set REPORT_PREFIX $CURRENT_STEP
file mkdir ${REPORTS_DIR}/${REPORT_PREFIX}
puts "RM-info: CURRENT_STEP  = $CURRENT_STEP"
puts "RM-info: REPORT_PREFIX = $REPORT_PREFIX"

redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/run_start.rpt {run_start}

rm_source -file $TCL_USER_LIBRARY_SETUP_SCRIPT -optional -print "TCL_USER_LIBRARY_SETUP_SCRIPT"

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
		copy_block -from ${INIT_DESIGN_INPUT_LIBRARY}:${INIT_DESIGN_INPUT_BLOCK_NAME} -to ${DESIGN_LIBRARY}:${DESIGN_NAME}/${INIT_DESIGN_BLOCK_NAME}
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
						puts "RM-info: Swap abstract for $BLOCK to PNR block library and block label [lindex $label_name 0]."
						open_lib -read $library
						current_block $top_block
						change_abstract -lib [get_libs -explicit ${BLOCK}${LIBRARY_SUFFIX}] -references ${BLOCK} -label [lindex $label_name 0] -view [lindex $label_name 1] -update_ref_libs
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

			## Ignore the sub-blocks (bound to abstracts) internal timing paths
			if {$USE_ABSTRACTS_FOR_BLOCKS != ""} {
              			set_timing_paths_disabled_blocks -all_sub_blocks
			}		
		}
	} else {
		puts "RM-error: INIT_DESIGN_INPUT is set to NDM but either INIT_DESIGN_INPUT_LIBRARY or INIT_DESIGN_INPUT_BLOCK_NAME is invalid. Please fix it before you continue."
		exit
	}
if {$TECHNOLOGY_NODE != "" && [get_attribute [current_block] technology_node -quiet] == ""} {
	set_technology -node $TECHNOLOGY_NODE
}
} ;# INIT_DESIGN_INPUT == NDM

if {$INIT_DESIGN_INPUT == "DC_ASCII" || $INIT_DESIGN_INPUT == "ASCII"} {
	if {[file exists $DESIGN_LIBRARY]} {
		file delete -force $DESIGN_LIBRARY
	}
	set create_lib_cmd "create_lib $DESIGN_LIBRARY"
	if {[file exists [which $TECH_FILE]]} {
		lappend create_lib_cmd -tech $TECH_FILE ;# recommended
	} elseif {$TECH_LIB != ""} {
		lappend create_lib_cmd -use_technology_lib $TECH_LIB ;# optional
	}
	if {$DESIGN_LIBRARY_SCALE_FACTOR != ""} {lappend create_lib_cmd -scale_factor $DESIGN_LIBRARY_SCALE_FACTOR}

        if {$PARASITIC_TECH_LIB != "" } {
		lappend create_lib_cmd -use_parasitic_tech_lib $PARASITIC_TECH_LIB ;# optional
        }

	## Construct a list for fusion libraries created on the fly by using RM's Makefile create_fusion_reference_library target
	## This is only applicable if you use RM's Makefile to create the fusion libraries which outputs $FUSION_REFERENCE_LIBRARY_DIR 
	set rm_fusion_reference_library_list ""
	if {[file exists $FUSION_REFERENCE_LIBRARY_DIR]} {
		foreach lib [glob $FUSION_REFERENCE_LIBRARY_DIR/*] {
			puts "RM-info: adding $lib to the reference library list"
			lappend rm_fusion_reference_library_list $lib	
		}
	} elseif {$FUSION_REFERENCE_LIBRARY_DIR != "" && [file exists create_fusion_reference_library]} {
		puts "RM-error: $FUSION_REFERENCE_LIBRARY_DIR is specified but not found, please correct it!"
	}

        ## Enable CLIB on the fly creation (library configuration flow)
	## create_lib when executed will call library manager under the hood to generate CLIB for correspnding fames/dbs, store, and link them
	## Specify CLIB_REFERENCE_LIBRARY_CONFIGURATION_FLOW_FRAME_LIST and CLIB_REFERENCE_LIBRARY_CONFIGURATION_FLOW_DB_LIST in design_setup.tcl to enable it
	if {$CLIB_REFERENCE_LIBRARY_CONFIGURATION_FLOW_FRAME_LIST != "" && $CLIB_REFERENCE_LIBRARY_CONFIGURATION_FLOW_DB_LIST != ""} {
		set link_library $CLIB_REFERENCE_LIBRARY_CONFIGURATION_FLOW_DB_LIST
	}

	## Add all relevant reference libraries to the design library 
	lappend create_lib_cmd -ref_libs "\
	$rm_fusion_reference_library_list \
	$REFERENCE_LIBRARY \
	$CLIB_REFERENCE_LIBRARY_CONFIGURATION_FLOW_FRAME_LIST \
	$SUB_BLOCK_LIBRARIES \
	$PARASITIC_TECH_LIB"

	puts "RM-info: $create_lib_cmd"
	eval ${create_lib_cmd}
	redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_ref_libs {report_ref_libs}
}

if {$INIT_DESIGN_INPUT == "DC_ASCII"} {
	################################################################
	## source write_icc2_files outputs from DC and commit UPF  
	################################################################
	if {[file exists ${DCRM_RESULTS_DIR}/${DCRM_FINAL_DESIGN_ICC2}/${DESIGN_NAME}.icc2_script.tcl]} {
		## Read in design output files from Design Compiler's write_icc2_files command
		puts "RM-info: Sourcing [which ${DCRM_RESULTS_DIR}/${DCRM_FINAL_DESIGN_ICC2}/${DESIGN_NAME}.icc2_script.tcl]"
		rm_source -file ${DCRM_RESULTS_DIR}/${DCRM_FINAL_DESIGN_ICC2}/${DESIGN_NAME}.icc2_script.tcl

		if {$SET_QOR_STRATEGY_MODE == "early_design"} {
			## Automatically enable lenient policy for early_design mode 
			set_early_data_check_policy -policy lenient -if_not_exist
		} elseif {$EARLY_DATA_CHECK_POLICY != "none"} {
			## Design check manager
			set_early_data_check_policy -policy $EARLY_DATA_CHECK_POLICY -if_not_exist
		}

		puts "RM-info: Running commit_upf"
		commit_upf
	} else {
		puts "RM-error : ${DCRM_RESULTS_DIR}/${DCRM_FINAL_DESIGN_ICC2}/${DESIGN_NAME}.icc2_script.tcl is not found." 
		puts "RM-warning : ${DCRM_RESULTS_DIR}/${DCRM_FINAL_DESIGN_ICC2}/${DESIGN_NAME}.icc2_script.tcl is required for DC_ASCII flow." 
	}
} ;# INIT_DESIGN_INPUT == DC_ASCII

if {$INIT_DESIGN_INPUT == "ASCII"} {
	########################################################################
	## Design creation : read the verilog
	########################################################################
	if {$DESIGN_STYLE == "hier" && $PHYSICAL_HIERARCHY_LEVEL != "bottom"} {
		## Specify the label to be used for the created design
		## Specifying the following application option will enable the tool to link to the sub-blocks of the same label
		set_app_options -name file.verilog.default_user_label -value $INIT_DESIGN_BLOCK_NAME
	
		read_verilog -top ${DESIGN_NAME} $VERILOG_NETLIST_FILES
		current_block ${DESIGN_NAME}/${INIT_DESIGN_BLOCK_NAME}
		if {$SET_QOR_STRATEGY_MODE == "early_design"} {
			## Automatically enable lenient policy for early_design mode 
			set_early_data_check_policy -policy lenient -if_not_exist
		} elseif {$EARLY_DATA_CHECK_POLICY != "none"} {
			## Design check manager
			set_early_data_check_policy -policy $EARLY_DATA_CHECK_POLICY -if_not_exist
		}
		link_block
		save_lib
	
		## In the link performed above, the tool tries to link to sub-blocks with the same label as the current_block.
		## In the following step, change_abstract is used to link to the sub-blocks specified for place_opt step
		if {$USE_ABSTRACTS_FOR_BLOCKS != ""} {
	 		puts "RM-info: Swap abstracts to [lindex $BLOCK_ABSTRACT_FOR_PLACE_OPT 0] abstracts for all blocks."
	 		change_abstract -view [lindex $BLOCK_ABSTRACT_FOR_PLACE_OPT 1] -references $USE_ABSTRACTS_FOR_BLOCKS -label [lindex $BLOCK_ABSTRACT_FOR_PLACE_OPT 0]
	 		report_abstracts
		}
	} else {
                read_verilog -top $DESIGN_NAME $VERILOG_NETLIST_FILES
                current_block $DESIGN_NAME
		if {$SET_QOR_STRATEGY_MODE == "early_design"} {
			## Automatically enable lenient policy for early_design mode 
			set_early_data_check_policy -policy lenient -if_not_exist
		} elseif {$EARLY_DATA_CHECK_POLICY != "none"} {
			## Design check manager
			set_early_data_check_policy -policy $EARLY_DATA_CHECK_POLICY -if_not_exist
		}
                link_block
                save_lib
	}

	################################################################
	## Design creation : Read UPF file(s)  
	################################################################
	## For golden UPF flow only (if supplemental UPF is provided): enable golden UPF flow before reading UPF
	if {[file exists [which $UPF_SUPPLEMENTAL_FILE]]} {set_app_options -name mv.upf.enable_golden_upf -value true}
	if {[file exists [which $UPF_FILE]]} {
		load_upf $UPF_FILE

		## For golden UPF flow only (if supplemental UPF is provided): read supplemental UPF file
		if {[file exists [which $UPF_SUPPLEMENTAL_FILE]]} { 
			load_upf -supplemental $UPF_SUPPLEMENTAL_FILE
		} elseif {$UPF_SUPPLEMENTAL_FILE != ""} {
			puts "RM-error: UPF_SUPPLEMENTAL_FILE($UPF_SUPPLEMENTAL_FILE) is invalid. Please correct it."
		}

		## Read the supply set file
		if {[file exists [which $UPF_UPDATE_SUPPLY_SET_FILE]]} {
			load_upf $UPF_UPDATE_SUPPLY_SET_FILE
		} elseif {$UPF_UPDATE_SUPPLY_SET_FILE != ""} {
			puts "RM-error: UPF_UPDATE_SUPPLY_SET_FILE($UPF_UPDATE_SUPPLY_SET_FILE) is invalid. Please correct it."
		}

		puts "RM-info: Running commit_upf"
		commit_upf
	} elseif {$UPF_FILE != ""} {
		puts "RM-error: UPF file($UPF_FILE) is invalid. Please correct it."
	}
        if {$TECHNOLOGY_NODE != "" && !$SET_TECHNOLOGY_AFTER_FLOORPLAN} {
                set_technology -node $TECHNOLOGY_NODE
        }

	################################################################################################################################
	## Floorplan input from TCL_FLOORPLAN_FILE (from write_floorplan) or DEF_FLOORPLAN_FILES (supports multiple DEF)
	################################################################################################################################
	if {$TCL_FLOORPLAN_FILE != ""} {
		rm_source -file $TCL_FLOORPLAN_FILE
	} elseif {$DEF_FLOORPLAN_FILES != ""} {
	#  Script first checks if all the specified DEF files are valid, if not, read_def is skipped
		set RM_DEF_FLOORPLAN_FILE_is_not_found FALSE
		foreach def_file $DEF_FLOORPLAN_FILES {
	      		if {![file exists [which $def_file]]} {
	      			puts "RM-error: DEF floorplan file ($def_file) is invalid."
	      			set RM_DEF_FLOORPLAN_FILE_is_not_found TRUE
	      		}
		}
	      	if {!$RM_DEF_FLOORPLAN_FILE_is_not_found} {
			set read_def_cmd "read_def $DEF_READ_OPTIONS [list $DEF_FLOORPLAN_FILES]"
	      		#set read_def_cmd "read_def -add_def_only_objects $DEF_OBJECTS_TO_ADD [list $DEF_FLOORPLAN_FILES]" 
	      		#if {$DEF_SITE_NAME_PAIRS != ""} {lappend read_def_cmd -convert $DEF_SITE_NAME_PAIRS}
	      		puts "RM-info: Creating floorplan from DEF file DEF_FLOORPLAN_FILES ($DEF_FLOORPLAN_FILES)"
			puts "RM-info: $read_def_cmd"
			eval ${read_def_cmd}

			if {$DEF_RESOLVE_PG_NETS} {
				redirect -var x {catch {resolve_pg_nets}} ;# workaround in case resolve_pg_nets returns warning that causes conditional to exit unexpectedly 
				puts $x
				if {[regexp ".*NDMUI-096.*" $x]} {
					puts "RM-error: UPF may have an issue. Please review and correct it."
				}
			}
	      	} else {
	      		puts "RM-error: At least one of the DEF_FLOORPLAN_FILES specified is invalid. Please correct it."
	      		puts "RM-info: Skipped reading of DEF_FLOORPLAN_FILES"
	      	}
	}

	## Source Switch Connectivity file 
	if {[rm_source -file $SWITCH_CONNECTIVITY_FILE -optional -print "SWITCH_CONNECTIVITY_FILE"]} {
	        associate_mv_cell -power_switches
	}

	################################################################
	## SCANDEF  
	################################################################	
	if {[file exists [which $DEF_SCAN_FILE]]} {
		read_def $DEF_SCAN_FILE
	} elseif {$DEF_SCAN_FILE != ""} {
		puts "RM-error: DEF_SCAN_FILE($DEF_SCAN_FILE) is invalid. Please correct it."
	}

} ;# INIT_DESIGN_INPUT == ASCII

################################################################
## Additional floorplan constraints plugin for anything not yet covered 
################################################################
rm_source -file $TCL_ADDITIONAL_FLOORPLAN_FILE -optional -print "TCL_ADDITIONAL_FLOORPLAN_FILE"

################################################################
## Technology & settings  
################################################################
if {$RESET_CHECK_STAGE_SETTINGS == "all"} {
	reset_app_options place.coarse*
        reset_app_options place_opt*
        reset_app_options refine*
        reset_app_options clock_opt*
        reset_app_options cts*
        reset_app_options multibit*
        reset_app_options extract*
        reset_app_options time*
        reset_app_options power*
        reset_app_options opt*
        reset_app_options route*
        reset_app_options ccd*
}
## set_technology for nodes requiring set_technology to be done after floorplanning or incoming designs without set_technology 
if {$TECHNOLOGY_NODE != "" && ($SET_TECHNOLOGY_AFTER_FLOORPLAN || [get_attribute [current_block] technology_node -quiet] == "")} {
	set_technology -node $TECHNOLOGY_NODE
}
rm_source -file $SIDEFILE_INIT_DESIGN -optional -print "SIDEFILE_INIT_DESIGN"


## Technology setup includes routing layer direction, offset, site default, and site symmetry
#  - If TECH_FILE is used, technology setup is required 
#  - If TECH_LIB is used while it does not contain the technology setup, then it is required
#  Specify your technology setup script through TCL_TECH_SETUP_FILE. RM default is init_design.tech_setup.tcl.
if {$TECH_FILE != "" || ($TECH_LIB != "" && !$TECH_LIB_INCLUDES_TECH_SETUP_INFO)} {
	rm_source -file $TCL_TECH_SETUP_FILE -optional -print "TCL_TECH_SETUP_FILE"
}

## Read a file in PRF format which specifies tech/library physical rules and attributes.
if {[file exists [which $PHYSICAL_RULES_FILE]]} {
	read_physical_rules $PHYSICAL_RULES_FILE
}

################################################################
## connect_pg_net
################################################################
if {![rm_source -file $TCL_USER_CONNECT_PG_NET_SCRIPT -optional -print "TCL_USER_CONNECT_PG_NET_SCRIPT"]} {
## Note : the following executes only if TCL_USER_CONNECT_PG_NET_SCRIPT is not sourced
	connect_pg_net
        # For non-MV designs with more than one PG, you should use connect_pg_net in manual mode.
}

################################################################
## Via ladder
################################################################
## (Optional) source user provided via ladder definitions, if not defined in your technology file
rm_source -file $TCL_VIA_LADDER_DEFINITION_FILE -optional -print "TCL_VIA_LADDER_DEFINITION_FILE"

## (Optional) source user provided library specific via ladder constraints
## For ex, set_via_ladder_candidate [get_lib_pins */AIOI/ZN] -ladder_name "VP"
## For ex, set_attribute -quiet [get_lib_pins */AIOI/ZN] is_em_via_ladder_required true
rm_source -file $TCL_SET_VIA_LADDER_CANDIDATE_FILE -optional -print "TCL_SET_VIA_LADDER_CANDIDATE_FILE"

########################################################################
## Basic floorplan and design checks
########################################################################
if {[info exists rm_fp_pnr_flow]} {
	puts "RM-info: Skipping checks as the floorplan is created later in the flow and checks are performed there.  See Makefile_fp_pnr for details."
	set RM_FAILURE 0
} elseif {$ENABLE_FLOORPLAN_CHECKS} {
	set RM_FAILURE [rm_check_design -step init_design] 

	## check_floorplan_rules : pls check the report for potential issues
	rm_source -file $TCL_FLOORPLAN_RULE_SCRIPT -optional -print "TCL_FLOORPLAN_RULE_SCRIPT"
	redirect -var x {catch {report_floorplan_rules}}
	if {![regexp "^.*No floorplan rules exist" $x]} {
		redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_floorplan_rules.rpt {check_floorplan_rules}
	}
}


########################################################################
## Timing and design constraints	
########################################################################
## Parasitics
if {$PARASITIC_TECH_LIB == "" } {
	## Specify a Tcl script to read in your TLU+ files by using the read_parasitic_tech command;
	## Refer to examples/TCL_PARASITIC_SETUP_FILE.tcl for sample commands
	## This is only sourced if PARASITIC_TECH_LIB is not specified  
	rm_source -file $TCL_PARASITIC_SETUP_FILE -optional -print "TCL_PARASITIC_SETUP_FILE"
}

## MCMM
#  Two examples are provided: 
#  - examples/TCL_MCMM_SETUP_FILE.explicit.tcl: provide mode, corner, and scenario constraints; create modes, corners, 
#    and scenarios; source mode, corner, and scenario constraints, respectively 
#  - examples/TCL_MCMM_SETUP_FILE.auto_expanded.tcl: provide constraints for the scenarios; create modes, corners, 
#    and scenarios; source scenario constraints which are then expanded to associated modes and corners
rm_source -file $TCL_MCMM_SETUP_FILE -optional -print "TCL_MCMM_SETUP_FILE"

## Following lines are applicable for designs with physical hierarchy : ignore the sub-blocks internal timing paths
if {$DESIGN_STYLE == "hier" && $PHYSICAL_HIERARCHY_LEVEL != "bottom"} {set_timing_paths_disabled_blocks  -all_sub_blocks}

## POCV
## Refer to examples/TCL_POCV_SETUP_FILE.tcl for sample commands
if {[rm_source -file $TCL_POCV_SETUP_FILE -optional -print "TCL_POCV_SETUP_FILE"]} {
## Note : The following executes if TCL_POCV_SETUP_FILE is sourced
	## Enable POCV analysis
	set_app_options -name time.pocvm_enable_analysis -value true ;# tool default false; enables POCV
	reset_app_options time.aocvm_enable_analysis ;# reset it to prevent POCV being overriden by AOCV
}

## AOCV (mutually exclusive with POCV)
## Refer to examples/TCL_AOCV_SETUP_FILE.tcl for sample commands
if {![get_app_option_value -name time.pocvm_enable_analysis] && $TCL_POCV_SETUP_FILE == ""} {
	rm_source -file $TCL_AOCV_SETUP_FILE -optional -print "TCL_AOCV_SETUP_FILE"
}

########################################################################
## Additional constraints
########################################################################
## Placement spacing labels, spacing rules, and abutment rules 
## Also sourced before tap cell insertion in rm_icc2_dp_flat_scripts/create_floorplan.tcl
if {$TCL_PLACEMENT_CONSTRAINT_FILE_LIST != ""} {
	foreach file $TCL_PLACEMENT_CONSTRAINT_FILE_LIST {
		rm_source -file $file
	}
}

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

## Lib cell usage restrictions (set_lib_cell_purpose)
## By default, RM sources set_lib_cell_purpose.tcl for dont use, tie cell, hold fixing, CTS and CTS-exclusive cell restrictions. 
## For advanced nodes, set_lib_cell_purpose.tcl sources node specific dont use sidefile for the corresponding node.
## You can replace it with your own script by specifying the TCL_LIB_CELL_PURPOSE_FILE variable.  
rm_source -file $TCL_LIB_CELL_PURPOSE_FILE -optional -print "TCL_LIB_CELL_PURPOSE_FILE"

## read_saif 
if {$SAIF_FILE_LIST != ""} {
	if {$SAIF_FILE_POWER_SCENARIO != ""} {
		set read_saif_cmd "read_saif \"$SAIF_FILE_LIST\" -scenarios \"$SAIF_FILE_POWER_SCENARIO\""
	} else {
		set read_saif_cmd "read_saif \"$SAIF_FILE_LIST\""
	}
	if {$SAIF_FILE_SOURCE_INSTANCE != ""} {lappend read_saif_cmd -strip_path $SAIF_FILE_SOURCE_INSTANCE}
	if {$SAIF_FILE_TARGET_INSTANCE != ""} {lappend read_saif_cmd -path $SAIF_FILE_TARGET_INSTANCE}
	puts "RM-info: Running $read_saif_cmd"
    	eval ${read_saif_cmd}
	if {$INIT_DESIGN_INPUT == "RTL"} {
		if {$SAIF_FILE_POWER_SCENARIO != ""} {
			reset_switching_activity -non_essential -scenarios $SAIF_FILE_POWER_SCENARIO
		} else {
			reset_switching_activity -non_essential
		}
	}
	if {$SAIF_FILE_POWER_SCENARIO != ""} {
		redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_activity {report_activity -driver -scenarios $SAIF_FILE_POWER_SCENARIO}
	} else {
		redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_activity {report_activity -driver}
	}
}

if {$SET_QOR_STRATEGY_METRIC == "total_power"} {
	foreach sce [get_object_name [get_scenarios -filter "dynamic_power"]] {
		puts "RM-info: Checking for simulated activities in the design for scenario $sce."
		report_activity -driver -scenario $sce > report_activity.tmp.rpt
		set line [sh grep ^simulated report_activity.tmp.rpt] 
		lappend table [list {*}[string map {( { } ) { } % { }} $line]]
		set total_simulated_perc [lindex [lindex $table 0] end]
		if {[string trim $total_simulated_perc] == 0} {
			puts "RM-info: There are no simulated activity in the design. Running infer_switching_activity"
			infer_switching_activity -apply -sci_based all -scenario $sce
		} else {
			puts "RM-info: Simulated activities found in the design. Will not run infer_switching_activity."
		}
		sh rm -rf report_activity.tmp.rpt
	}
}

## Refer to examples/init_design.additional_setup.tcl for additional examples on group_path, set_clock_gating_check, and set_power_derate
####################################
## Post-init_design customizations
####################################
rm_source -file $TCL_USER_INIT_DESIGN_POST_SCRIPT -optional -print "TCL_USER_INIT_DESIGN_POST_SCRIPT"

save_upf ${OUTPUTS_DIR}/${INIT_DESIGN_BLOCK_NAME}.save_upf

## Check to remove any duplicate shapes in the design
set duplicate_shapes [check_duplicates -return_as_collection]
if {[sizeof_collection $duplicate_shapes] > 0} {
   remove_shapes -force $duplicate_shapes
}

save_block
save_block -as ${DESIGN_NAME}/${INIT_DESIGN_BLOCK_NAME}


####################################
## Sanity checks and QoR Report	
####################################
if {$REPORT_QOR} {
	set REPORT_STAGE init_design
	set REPORT_ACTIVE_SCENARIOS $REPORT_INIT_DESIGN_ACTIVE_SCENARIO_LIST
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
rm_logparse $LOGS_DIR/init_design.log

if {!$RM_FAILURE} {
	echo [date] > init_design
} else {
	puts "RM-info: init_design touch file was not created due to potential issues found in \"Basic floorplan and design checks\" section. Please check RM-error messages in the log."
}
exit
