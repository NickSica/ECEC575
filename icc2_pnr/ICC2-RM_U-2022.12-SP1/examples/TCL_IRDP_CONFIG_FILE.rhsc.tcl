##########################################################################################
# Script: TCL_IRDP_CONFIG_FILE.rhsc.tcl
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################

## The is IRDP Streamline flow
## Disable place.coarse.ir_drop_aware for IR Driven Placement before clock_opt
## Enable opt.common.power_integrity streamline flow
set_app_options -name opt.common.power_integrity -value true
set_app_options -name place.coarse.ir_drop_aware -value false
set_app_options -name clock_opt.flow.skip_placement -value false ;# required to be set to false

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
} elseif { [file exists [which $REDHAWK_PAD_CUSTOMIZED_SCRIPT]] } {
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
	set REDHAWK_SCENARIO [get_scenario[current_scenario]]
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
