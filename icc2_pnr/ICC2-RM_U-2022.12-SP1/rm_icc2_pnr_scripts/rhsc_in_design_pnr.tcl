##########################################################################################
# Script: rhsc_in_design_pnr.tcl
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################

source ./rm_utilities/procs_global.tcl 
source ./rm_utilities/procs_icc2.tcl 
rm_source -file ./rm_setup/design_setup.tcl
rm_source -file ./rm_setup/icc2_pnr_setup.tcl
rm_source -file ./rm_setup/header_icc2_pnr.tcl
rm_source -file sidefile_setup.tcl -after_file technology_override.tcl
set PREVIOUS_STEP $REDHAWK_IN_DESIGN_FROM_BLOCK_NAME
set CURRENT_STEP $REDHAWK_IN_DESIGN_BLOCK_NAME
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

## Non-persistent settings to be applied in each step (optional)
rm_source -file $TCL_USER_NON_PERSISTENT_SCRIPT -optional -print "TCL_USER_NON_PERSISTENT_SCRIPT"

puts "RM-info: Running RedHawk-SC"
set_app_options -name rail.enable_redhawk -value false
set_app_options -name rail.enable_redhawk_sc -value true

if {[which $REDHAWK_SC_DIR] == "" } {
	puts "RM-info: Setting rail.redhawk_path to $REDHAWK_SC_DIR"
	set_app_options -name rail.redhawk_path -value $REDHAWK_SC_DIR
} elseif {[file dirname [exec which redhawk_sc]] != ""} {
	set redhawk_sc_dir_exec [file dirname [exec which redhawk_sc]]
	puts "RM-info: Setting rail.redhawk_sc_path to $redhawk_sc_dir_exec"
	set_app_options -name rail.redhawk_path -value $redhawk_sc_dir_exec
} else {
        puts "RM-error: Unable to find RedHawk-SC binary.  Exiting...."

	exit

}

if {$REDHAWK_GRID_FARM == "" } {
        puts "RM-info: Run RH/RHSC on single machine"
        remove_host_options -all
        set_host_options -submit_command {local} -max_cores $SET_HOST_OPTIONS_MAX_CORES
} else {
        puts "RM-info: Submit RH/RHSC into GRID farm system "
        set_host_options -submit_command $REDHAWK_GRID_FARM
}

if {![check_license -quiet "SNPS_INDESIGN_RH_RAIL"]} {
        puts "RM-error: Unable to find SNPS_INDESIGN_RH_RAIL license. Exiting...."

	exit

}

if {[file exists [which $REDHAWK_LAYER_MAP_FILE]]} {
        set_app_options -name rail.layer_map_file -value $REDHAWK_LAYER_MAP_FILE
}

if {[which $REDHAWK_TECH_FILE] == ""} {
        puts "RM-error: Unable to find redhawk tech file at \"$REDHAWK_TECH_FILE\".  Exiting...."

	exit

} else {
	puts "RM-info: Setting rail.tech_file to $REDHAWK_TECH_FILE"
	set_app_options -name rail.tech_file -value $REDHAWK_TECH_FILE
}

if {$REDHAWK_LIB_FILES == ""} {
        puts "RM-warning: No .lib files are provided.  Make sure your .gsr include the lib otherwise RedHawk will error...."
} elseif {[file exists [which $REDHAWK_LIB_FILES]]   } {
	rm_source -file $REDHAWK_LIB_FILES
} else {
        ## Re-format tcl var to tolerate specific app option format
	set lib_files ""
	foreach fl $REDHAWK_LIB_FILES {
		set lib_files "$lib_files \n$fl"
	}
	puts "RM-info: Setting rail.lib_files to $lib_files"
	set_app_options -name rail.lib_files -value $lib_files
}

if {$REDHAWK_APL_FILES == "" && ($REDHAWK_ANALYSIS == "dynamic_vectorless" || $REDHAWK_ANALYSIS == "dynamic_vcd" || $REDHAWK_ANALYSIS == "dynamic" )} {
        puts "RM-warning: No APL files provided for the dynamic analysis.  Run dynamic with .lib "
} else {
        puts "RM-info: Setting rail.apl_files to $REDHAWK_APL_FILES"
        set_app_options -name rail.apl_files -value $REDHAWK_APL_FILES
}

if {[file exists [which $REDHAWK_PAD_FILE_NDM]]} {
	puts "RM-info: Run create_taps with a file that include coordinates and metal layer from NDM "
	create_taps -import $REDHAWK_PAD_FILE_NDM
} elseif { [file exists [ which $REDHAWK_PAD_FILE_PLOC ]] } {
	puts "RM-info: Pass Redhawk ploc file to RedHawk "
	set_app_options -name rail.pad_files  -value $REDHAWK_PAD_FILE_PLOC
} elseif { [file exists [which $REDHAWK_PAD_CUSTOMIZED_SCRIPT]] }  { 
	rm_source -file $REDHAWK_PAD_CUSTOMIZED_SCRIPT
} else {
	puts "RM-info: Run create_taps -top_pg "
	create_taps -top_pg
}

if {$REDHAWK_FREQUENCY != ""} {
	puts "RM-info: Setup Frequency for RedHawk "
        set_app_options -name rail.frequency -value $REDHAWK_FREQUENCY
}

if {$REDHAWK_TEMPERATURE != ""} {
        puts "RM-info: Setup TEMPERATURE for RedHawk "
        set_app_options -name rail.temperature -value $REDHAWK_TEMPERATURE
}

if {$REDHAWK_SCENARIO != ""} {
        puts "RM-info: Setup specified rail scenario for RedHawk"
        set_scenario_status $REDHAWK_SCENARIO -active true -setup true
        set_app_options -name rail.scenario_name -value $REDHAWK_SCENARIO
} else {
	puts "RM-info: Setup current scenario for RedHawk"
	set REDHAWK_SCENARIO [get_scenario [current_scenario]]
	set_app_options -name rail.scenario_name -value $REDHAWK_SCENARIO
}

if {$REDHAWK_MACROS != ""} {
	puts "RM-info: Setup Macro Model to top design "
        set_app_options -name rail.macro_models -value $REDHAWK_MACROS
}

if {$REDHAWK_SWITCH_MODEL_FILES != ""} {
        set_app_options -name rail.switch_model_files -value $REDHAWK_SWITCH_MODEL_FILES
}

set_missing_via_check_options -exclude_stack_via -threshold -1

set_app_options -name rail.database -value $REDHAWK_RAIL_DATABASE

if {$REDHAWK_MISSING_VIA_POS_THRESHOLD != ""} {
	set_missing_via_check_options -exclude_stack_via -threshold $REDHAWK_MISSING_VIA_POS_THRESHOLD
}

if {$REDHAWK_EXTRA_GSR == ""} {
} else {
	puts "RM-info: GSR is not needed for running RHSC"
}

## Change block .abstract views to .design for analysis.
set block_refs [ filter_collection [ get_designs -filter "view_name==abstract" ] "name!=$DESIGN_NAME" ]
set block_ref_list [ list ]
if { [ sizeof_collection $block_refs ] > 0 } {
	foreach_in_collection block $block_refs {
		set block_name [ get_object_name $block ]
		lappend block_ref_list $block_name
	}
	change_abstract -view design -references $block_ref_list
	list_blocks
}

if {$RHSC_PYTHON_SCRIPT_FILE == "" && $REDHAWK_MCMM_SCENARIO_CONFIG == ""} {
	if {$REDHAWK_SWITCHING_ACTIVITY_FILE == ""} {
		if {$REDHAWK_USE_FC_POWER} {
			if {($REDHAWK_ANALYSIS == "static" || $REDHAWK_ANALYSIS == "dynamic_vcd" || $REDHAWK_ANALYSIS == "dynamic_vectorless" || $REDHAWK_ANALYSIS == "dynamic" ) && !$REDHAWK_EM_ANALYSIS} {
				puts "RM-info: The variable REDHAWK_USE_FC_POWER in ./rm_setup/design_setup.tcl is $REDHAWK_USE_FC_POWER, to use FC POWER"
                                analyze_rail -nets $REDHAWK_ANALYSIS_NETS -voltage_drop $REDHAWK_ANALYSIS -power_analysis icc2
			} elseif {($REDHAWK_ANALYSIS == "static" || $REDHAWK_ANALYSIS == "dynamic_vcd" || $REDHAWK_ANALYSIS == "dynamic_vectorless" || $REDHAWK_ANALYSIS == "dynamic" ) && $REDHAWK_EM_ANALYSIS} {
				puts "The variable REDHAWK_USE_FC_POWER in./rm_setup/design_setup.tcl is $REDHAWK_USE_FC_POWER, to use FC POWER"
				analyze_rail -nets $REDHAWK_ANALYSIS_NETS -voltage_drop $REDHAWK_ANALYSIS -electromigration  -power_analysis icc2
			} elseif {$REDHAWK_ANALYSIS == "effective_resistance" } {
				analyze_rail -nets $REDHAWK_ANALYSIS_NETS -effective_resistance
			} elseif {$REDHAWK_ANALYSIS == "min_path_resistance" } {
				analyze_rail -nets $REDHAWK_ANALYSIS_NETS  -min_path_resistance
			} elseif {$REDHAWK_ANALYSIS == "check_missing_via" && $REDHAWK_MISSING_VIA_POS_THRESHOLD == ""} {
				analyze_rail -nets $REDHAWK_ANALYSIS_NETS -check_missing_via
			} elseif {$REDHAWK_ANALYSIS == "check_missing_via" && $REDHAWK_MISSING_VIA_POS_THRESHOLD != ""} {
				analyze_rail -nets $REDHAWK_ANALYSIS_NETS -voltage_drop static -check_missing_via
			} else {
				puts "RM-error: Please enable at least one analysis. Exiting ..."

				exit

			}
		} else {
			if {($REDHAWK_ANALYSIS == "static" || $REDHAWK_ANALYSIS == "dynamic_vcd" || $REDHAWK_ANALYSIS == "dynamic_vectorless" || $REDHAWK_ANALYSIS == "dynamic" ) && !$REDHAWK_EM_ANALYSIS} {
			        analyze_rail -nets $REDHAWK_ANALYSIS_NETS -voltage_drop $REDHAWK_ANALYSIS
			} elseif {($REDHAWK_ANALYSIS == "static" || $REDHAWK_ANALYSIS == "dynamic_vcd" || $REDHAWK_ANALYSIS == "dynamic_vectorless" || $REDHAWK_ANALYSIS == "dynamic" ) && $REDHAWK_EM_ANALYSIS} {
			        analyze_rail -nets $REDHAWK_ANALYSIS_NETS -voltage_drop $REDHAWK_ANALYSIS -electromigration
			} elseif {$REDHAWK_ANALYSIS == "effective_resistance" } {
			        analyze_rail -nets $REDHAWK_ANALYSIS_NETS -effective_resistance
			} elseif {$REDHAWK_ANALYSIS == "min_path_resistance" } {
			        analyze_rail -nets $REDHAWK_ANALYSIS_NETS  -min_path_resistance
			} elseif {$REDHAWK_ANALYSIS == "check_missing_via" && $REDHAWK_MISSING_VIA_POS_THRESHOLD == ""} {
			        analyze_rail -nets $REDHAWK_ANALYSIS_NETS -check_missing_via
			} elseif {$REDHAWK_ANALYSIS == "check_missing_via" && $REDHAWK_MISSING_VIA_POS_THRESHOLD != ""} {
			        analyze_rail -nets $REDHAWK_ANALYSIS_NETS -voltage_drop static -check_missing_via
			} else {
			        puts "RM-error: Please enable at least one analysis. Exiting ..."

				exit

			}
		}
	} else {
                if {($REDHAWK_ANALYSIS == "static" || $REDHAWK_ANALYSIS == "dynamic_vcd" || $REDHAWK_ANALYSIS == "dynamic_vectorless" || $REDHAWK_ANALYSIS == "dynamic" ) && !$REDHAWK_EM_ANALYSIS} {
			analyze_rail -nets $REDHAWK_ANALYSIS_NETS -voltage_drop $REDHAWK_ANALYSIS -switching_activity $REDHAWK_SWITCHING_ACTIVITY_FILE
                } elseif {($REDHAWK_ANALYSIS == "static" || $REDHAWK_ANALYSIS == "dynamic_vcd" || $REDHAWK_ANALYSIS == "dynamic_vectorless" || $REDHAWK_ANALYSIS == "dynamic" ) && $REDHAWK_EM_ANALYSIS} {
			analyze_rail -nets $REDHAWK_ANALYSIS_NETS -voltage_drop $REDHAWK_ANALYSIS -electromigration  -switching_activity $REDHAWK_SWITCHING_ACTIVITY_FILE
                } elseif {$REDHAWK_ANALYSIS == "effective_resistance" } {
			analyze_rail -nets $REDHAWK_ANALYSIS_NETS -effective_resistance
                } elseif {$REDHAWK_ANALYSIS == "min_path_resistance" } {
			analyze_rail -nets $REDHAWK_ANALYSIS_NETS  -min_path_resistance
                } elseif {$REDHAWK_ANALYSIS == "check_missing_via" && $REDHAWK_MISSING_VIA_POS_THRESHOLD == ""} {
			analyze_rail -nets $REDHAWK_ANALYSIS_NETS -check_missing_via
                } elseif {$REDHAWK_ANALYSIS == "check_missing_via" && $REDHAWK_MISSING_VIA_POS_THRESHOLD != ""} {
			analyze_rail -nets $REDHAWK_ANALYSIS_NETS -voltage_drop static -check_missing_via
                } else {
			puts "RM-error: Please enable at least one analysis. Exiting ..."

			exit

                }
        }
} else {
        if {$REDHAWK_MCMM_SCENARIO_CONFIG != ""} {
		puts "RM-info: Setup MCMM for RedHawk Fusion "
		reset_app_options rail.scenario_name
		
		puts "RM-info: Setup parallel run rail sceneario"
		set_app_options -name rail.generate_file_type -value python
		set_app_options -name rail.enable_new_rail_scenario -value true
		set_app_options -name rail.enable_parallel_run_rail_scenario -value true

        	rm_source -file $REDHAWK_MCMM_SCENARIO_CONFIG
        } else {
		analyze_rail -redhawk_script_file $RHSC_PYTHON_SCRIPT_FILE
	}
}

## Change blocks back to .abstract views.
if { [ llength $block_ref_list ] > 0 } {
	change_abstract -view abstract -references $block_ref_list
}

if {$REDHAWK_FIX_MISSING_VIAS} {
        foreach_in_collection err_file [get_drc_error_data -all *miss_via*] {
                set errdm [open_drc_error_data $err_file]
                set errs [get_drc_errors -error_data $errdm]
                fix_pg_missing_vias -error_data $errdm $errs
        }
}

if {$REDHAWK_ANALYSIS == "static" || $REDHAWK_ANALYSIS == "dynamic_vcd" || $REDHAWK_ANALYSIS == "dynamic_vectorless" || $REDHAWK_ANALYSIS == "dynamic"} {
        report_rail_result -type effective_voltage  -supply_nets $REDHAWK_ANALYSIS_NETS $REDHAWK_OUTPUT_REPORT
}

if {$REDHAWK_EM_ANALYSIS && $REDHAWK_EM_REPORT != ""} {
        set fileName $REDHAWK_EM_REPORT
        set fd [open $fileName w]
        foreach_in_collection em_err_file [get_drc_error_data -all *em*] {
                set dm [open_drc_error_data $em_err_file]
                set all_errs [get_drc_errors -error_data $dm *]
                foreach_in_collection err $all_errs {
                        set info [get_attribute $err error_info];
                        puts $fd $info
                }
        }
        close $fd
}

if {$REDHAWK_ANALYSIS == "min_path_resistance"} {
        report_rail_result -type minimum_path_resistance  -supply_nets $REDHAWK_ANALYSIS_NETS $REDHAWK_OUTPUT_REPORT
}

if {$REDHAWK_ANALYSIS == "effective_resistance"} {
        report_rail_result -type effective_resistance  -supply_nets $REDHAWK_ANALYSIS_NETS $REDHAWK_OUTPUT_REPORT
}

if {$REDHAWK_ANALYSIS == "check_missing_via"} {
        report_rail_result -type missing_vias  -supply_nets $REDHAWK_ANALYSIS_NETS $REDHAWK_OUTPUT_REPORT
}

if {$REDHAWK_PGA_NODE != ""} {
	puts "RM-info: PGA NODE: $REDHAWK_PGA_NODE"
	if {[which $REDHAWK_PGA_ICV_DIR/bin/LINUX.64/icv] == "" } {
        	puts "RM-error: Unable to find icv at \"$REDHAWK_PGA_ICV_DIR/bin/LINUX.64\". Exiting...."

		exit

	} else {
        	puts "RM-info: Setting ICV binary path"
		setenv ICV_HOME_DIR $REDHAWK_PGA_ICV_DIR
	        setenv ICV_INCLUDES [getenv ICV_HOME_DIR]/include/
        	setenv PATH [getenv ICV_HOME_DIR]/bin/LINUX.64:[getenv PATH]

	}

	# ---------------------------------------------------------------------------
	# QOR Reports Pre PGA
	# ---------------------------------------------------------------------------
	if {$REPORT_QOR} {
		set REPORT_PREFIX pre_pga
		redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_qor {report_qor -scenarios [all_scenarios] -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit}
		redirect -tee -append -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_qor {report_qor -summary -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit}
		redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_routes {check_routes}
	}

	# ---------------------------------------------------------------------------
	# Run Power Grid Augmentation
	# ---------------------------------------------------------------------------

	if {$REDHAWK_PGA_GROUND_NET == "" || $REDHAWK_PGA_POWER_NET == ""} {
	        puts "RM-error: Please specify one ground net and one power net for PGA.  Exiting...."

		exit

	}

	remove_host_options -all
        set_host_options -max_cores $SET_HOST_OPTIONS_MAX_CORES
        set_app_option -name signoff.create_pg_augmentation.ir_aware -value true ;# enables PGA
        set_app_option -name signoff.create_pg_augmentation.ground_net_name -value $REDHAWK_PGA_GROUND_NET
        set_app_option -name signoff.create_pg_augmentation.power_net_name -value $REDHAWK_PGA_POWER_NET
        signoff_create_pg_augmentation -node $REDHAWK_PGA_NODE -mode remove
        signoff_create_pg_augmentation -node $REDHAWK_PGA_NODE -mode add
        rm_source -file $REDHAWK_PGA_CUSTOMIZED_SCRIPT -optional -print "REDHAWK_PGA_CUSTOMIZED_SCRIPT"
	save_lib -all

	# ---------------------------------------------------------------------------
	# QOR Reports Post PGA
	# ---------------------------------------------------------------------------
	if {$REPORT_QOR} {
		set REPORT_PREFIX post_pga
		redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_qor {report_qor -scenarios [all_scenarios] -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit}
		redirect -tee -append -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_qor {report_qor -summary -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit}
		redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_routes {check_routes}
	}
}
redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/run_end.rpt {run_end}

report_msg -summary
print_message_info -ids * -summary
rm_logparse $LOGS_DIR/rhsc_in_design_pnr.log
echo [date] > rhsc_in_design_pnr

exit 
