########################################################################################
# Script: TCL_IRDCCD_CONFIG_FILE.rh.tcl
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
########################################################################################

puts "RM-info: Running RedHawk  "
set_app_options -name rail.enable_redhawk -value true
set_app_options -name rail.redhawk_path -value $REDHAWK_DIR

if {[which $REDHAWK_DIR] != "" } {
	puts "RM-info: Setting rail.redhawk_path to $REDHAWK_DIR"
	set_app_options -name rail.redhawk_path -value $REDHAWK_DIR
} elseif {[file dirname [exec which redhawk]] != ""} {
	set redhawk_dir_exec [file dirname [exec which redhawk]]
	puts "RM-info: Setting rail.redhawk_path to $redhawk_dir_exec"
	set_app_options -name rail.redhawk_path -value $redhawk_dir_exec
} else {
        puts "RM-error: Unable to find Redhawk binary. Exiting...."
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

if {$REDHAWK_EXTRA_GSR == ""} {
        exec touch extra.gsr
        set extra_gsr_file "extra.gsr"
} else {
	set extra_gsr_file $REDHAWK_EXTRA_GSR
        set_app_options -name rail.extra_gsr_option_file -value $REDHAWK_EXTRA_GSR
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

if {$REDHAWK_MCMM_SCENARIO_CONFIG != ""} {
        	puts "RM-info: Setup MCMM for RedHawk Fusion "
        	reset_app_options rail.scenario_name

        	puts "RM-info: Setup parallel run rail sceneario"
		set_app_options -name rail.enable_new_rail_scenario -value true
		set_app_options -name rail.enable_parallel_run_rail_scenario -value true

        	rm_source -file $REDHAWK_MCMM_SCENARIO_CONFIG
        } 

set_app_options -name opt.common.power_integrity -value true

