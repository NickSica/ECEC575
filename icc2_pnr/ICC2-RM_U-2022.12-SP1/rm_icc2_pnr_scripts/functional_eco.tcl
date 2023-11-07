##########################################################################################
# Script: functional_eco.tcl
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################

source ./rm_utilities/procs_global.tcl 
source ./rm_utilities/procs_icc2.tcl 
rm_source -file ./rm_setup/design_setup.tcl
rm_source -file ./rm_setup/icc2_pnr_setup.tcl
rm_source -file ./rm_setup/header_icc2_pnr.tcl
rm_source -file sidefile_setup.tcl -after_file technology_override.tcl

set PREVIOUS_STEP $FUNCTIONAL_ECO_FROM_BLOCK_NAME
set CURRENT_STEP  $FUNCTIONAL_ECO_BLOCK_NAME

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
copy_block -from ${DESIGN_NAME}/${FUNCTIONAL_ECO_FROM_BLOCK_NAME} -to ${DESIGN_NAME}/${FUNCTIONAL_ECO_BLOCK_NAME}
current_block ${DESIGN_NAME}/${FUNCTIONAL_ECO_BLOCK_NAME}
link_block

if {![file exists [which $FUNCTIONAL_ECO_VERILOG_FILE]]} {
        puts "RM-error: FUNCTIONAL_ECO_VERILOG_FILE is not specified or invalid. Exiting...."
        exit
}

if {$FUNCTIONAL_ECO_ACTIVE_SCENARIO_LIST != ""} {
	set_scenario_status -active false [get_scenarios -filter active]
	set_scenario_status -active true $FUNCTIONAL_ECO_ACTIVE_SCENARIO_LIST
}

## Adjustment file for modes/corners/scenarios/models to applied to each step (optional)
rm_source -file $TCL_MODE_CORNER_SCENARIO_MODEL_ADJUSTMENT_FILE -optional -print "TCL_MODE_CORNER_SCENARIO_MODEL_ADJUSTMENT_FILE"


rm_source -file $SIDEFILE_FUNCTIONAL_ECO -optional -print "SIDEFILE_FUNCTIONAL_ECO"

## Non-persistent settings to be applied in each step (optional)
rm_source -file $TCL_USER_NON_PERSISTENT_SCRIPT -optional -print "TCL_USER_NON_PERSISTENT_SCRIPT"

####################################
## Pre-Functional ECO customizations
####################################
rm_source -file $TCL_USER_FUNCTIONAL_ECO_PRE_SCRIPT -optional -print "TCL_USER_FUNCTIONAL_ECO_PRE_SCRIPT"

redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_app_options.start {report_app_options -non_default *}
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_lib_cell_purpose {report_lib_cell -objects [get_lib_cells] -column {full_name:20 valid_purposes}}

if {$ENABLE_INLINE_REPORT_QOR} {
   redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_qor.start {report_qor -scenarios [all_scenarios] -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit}
   redirect -append -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_qor.start {report_qor -summary -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit}
   redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_global_timing.start {report_global_timing -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit}
}

####################################
## Functional ECO
####################################
## Clear eco_change_status for all eco cells
#  -quiet used in case there is no cell with defined(eco_change_status) exists
remove_attribute [get_cell -quiet -hier -filter "defined(eco_change_status)"] eco_change_status

## Functional ECO - both Freeze Silicon and Non-Freeze Silicon ECO flows are supported 
if {$FUNCTIONAL_ECO_MODE == "freeze_silicon"} {

	## Programmable spare cell (PSC, or gate array cell) auto derive mapping rule
	## If PSC cells are inserted on the design, for running freeze silicon PSC flow, specify a auto derive mapping rule file
	rm_source -file $TCL_USER_PSC_AUTO_DERIVE_MAPPING_RULE_FILE -optional -print "TCL_USER_PSC_AUTO_DERIVE_MAPPING_RULE_FILE"

	puts "RM-info: Running freeze silicon Functional ECO flow"

	## Do netlist diff with the new verilog file to generate a change list
	eco_netlist -by_verilog_file $FUNCTIONAL_ECO_VERILOG_FILE -write_changes eco_changes.tcl

	## Enable freeze silicon ECO
	set_app_options -name design.eco_freeze_silicon_mode -value true

	rm_source -file eco_changes.tcl

	## Disable freeze silicon ECO
	set_app_options -name design.eco_freeze_silicon_mode -value false
	
	## Check freeze silicon availability
	redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_freeze_silicon {check_freeze_silicon}

	# Coarse placement
	place_freeze_silicon
	
} else {

	puts "RM-info: Running MPI Functional ECO flow"

	## Do netlist diff on the new verilog netlist to generate a change list
	eco_netlist -by_verilog_file $FUNCTIONAL_ECO_VERILOG_FILE -write_changes eco_changes.tcl

	rm_source -file eco_changes.tcl

	## The "report_eco_physical_changes" command reports the physical changes to the design after an ECO has been applied.
	## The actual & estimated cell displacement and net lengths can be reported.  The user can revert eco changes that have
	## large estimated cell displacement using "revert_eco_changes -cells".  This would however require an interactive approach
	## to running the ECO.  See the MAN page for additional details.
	redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_eco_physical_changes.pre_eco_place.rpt {report_eco_physical_changes -type all}

	# Coarse placement
	place_eco_cells -eco_changed_cells -no_legalize

	## ECO legalization (MPI mode)
	set place_eco_cells_cmd "place_eco_cells -eco_changed_cells -legalize_only -legalize_mode minimum_physical_impact -displacement_threshold $FUNCTIONAL_ECO_DISPLACEMENT_THRESHOLD"
	if {$CHIP_FINISH_METAL_FILLER_LIB_CELL_LIST != "" || $CHIP_FINISH_NON_METAL_FILLER_LIB_CELL_LIST != ""} {
		lappend place_eco_cells_cmd -remove_filler_references "$CHIP_FINISH_METAL_FILLER_LIB_CELL_LIST $CHIP_FINISH_NON_METAL_FILLER_LIB_CELL_LIST"
	}
	puts "RM-info: $place_eco_cells_cmd"
	eval ${place_eco_cells_cmd}

	redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_eco_physical_changes.post_eco_place.rpt {report_eco_physical_changes -type all}
}

connect_pg_net
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_legality {check_legality -verbose}

## route_eco will by default attempt to close DRC for the entire design.  The option "route.common.eco_route_fix_existing_drc" controls whether the
## router works on prior DRCs (i.e. those stored in the error cell), or only new DRCs found during post-eco DRC checking.  Setting the option below
## to false should result in quicker ECO TAT (but higher final DRCs).  This should be used for ECO feasibility purposes only.
## - Uncomment to instruct router to only work on new DRCs.
##	set_app_options -name route.common.eco_route_fix_existing_drc -value false 

## We are disabling the following OBD option as we are seeing negative DRC impact.  Remove if needed for you design.
set_app_options -name route.detail.eco_route_use_soft_spacing_for_timing_optimization -value false

## ECO routing
#  Turn off timing-driven and crosstalk-driven for ECO routing 
set RM_route_global_timing_driven [get_app_option_value -name route.global.timing_driven]
set_app_options -name route.global.timing_driven    -value false
set RM_route_track_timing_driven [get_app_option_value -name route.track.timing_driven]
set_app_options -name route.track.timing_driven     -value false
set RM_route_detail_timing_driven [get_app_option_value -name route.detail.timing_driven]
set_app_options -name route.detail.timing_driven    -value false 
set RM_route_global_crosstalk_driven [get_app_option_value -name route.global.crosstalk_driven]
set_app_options -name route.global.crosstalk_driven -value false 
set RM_route_track_crosstalk_driven [get_app_option_value -name route.track.crosstalk_driven]
set_app_options -name route.track.crosstalk_driven  -value false 
	
set route_eco_cmd "route_eco -utilize_dangling_wires true -reroute modified_nets_first_then_others -open_net_driven true"
puts "RM-info: $route_eco_cmd"
eval ${route_eco_cmd}

## If there are remaining routing DRCs, you can use the following :
#	check_routes
#	route_detail -incremental true -initial_drc_from_input true 

## Restore pre-eco settings
set_app_options -name route.global.timing_driven -value $RM_route_global_timing_driven
set_app_options -name route.track.timing_driven -value $RM_route_track_timing_driven
set_app_options -name route.detail.timing_driven -value $RM_route_detail_timing_driven
set_app_options -name route.global.crosstalk_driven -value $RM_route_global_crosstalk_driven
set_app_options -name route.track.crosstalk_driven -value $RM_route_track_crosstalk_driven

redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_eco_physical_changes.post_eco_route.rpt {report_eco_physical_changes -type all}

########################################
## Reinsert filler cells  if they previously existed in the design and not running "freeze_silicon".
########################################
if {([sizeof_collection [get_cells -quiet ${CHIP_FINISH_METAL_FILLER_PREFIX}*]] > 0) && ($PT_ECO_MODE!="freeze_silicon")} {
	puts "RM-info: Filler cells were detected in the source design.  Performing refill..."
	## Metal filler (decap cells)
	if {$CHIP_FINISH_METAL_FILLER_LIB_CELL_LIST != ""} {
		set create_stdcell_filler_metal_lib_cell_sorted [get_object_name [sort_collection -descending [get_lib_cells $CHIP_FINISH_METAL_FILLER_LIB_CELL_LIST] area]]
		set create_stdcell_filler_metal_cmd "create_stdcell_filler -lib_cell [list $create_stdcell_filler_metal_lib_cell_sorted] -post_eco"
		if {$CHIP_FINISH_METAL_FILLER_PREFIX != ""} {
			lappend create_stdcell_filler_metal_cmd -prefix $CHIP_FINISH_METAL_FILLER_PREFIX
		}
		puts "RM-info: Running $create_stdcell_filler_metal_cmd"
		eval ${create_stdcell_filler_metal_cmd}
		connect_pg_net
		remove_stdcell_fillers_with_violation -post_eco true ;# -post_eco true option is required in PT-ECO flow
	}

	## Non-metal filler
	if {$CHIP_FINISH_NON_METAL_FILLER_LIB_CELL_LIST != ""} {
		set create_stdcell_filler_non_metal_lib_cell_sorted [get_object_name [sort_collection -descending [get_lib_cells $CHIP_FINISH_NON_METAL_FILLER_LIB_CELL_LIST] area]]
		set create_stdcell_filler_non_metal_cmd "create_stdcell_filler -lib_cell [list $create_stdcell_filler_non_metal_lib_cell_sorted]"
		if {$CHIP_FINISH_NON_METAL_FILLER_PREFIX != ""} {
			lappend create_stdcell_filler_non_metal_cmd -prefix $CHIP_FINISH_NON_METAL_FILLER_PREFIX
		}
		puts "RM-info: Running $create_stdcell_filler_non_metal_cmd"
		eval ${create_stdcell_filler_non_metal_cmd}
		connect_pg_net
	}
} else {
	puts "RM-info: Skipping filler cell reinsertion as none detected in source design."
}

########################################
## Reinsert metal fill if it pre-existed in the design.  Use ICV_IN_DESIGN_METAL_FILL_ECO_THRESHOLD to set the max
## threshold for incremental fill.  Setting it to "0" will cause full removal & reinsertion.
## - Note: This relies on previous full metal fill insertion using the "icv_in_design.tcl" file.  Application options 
##   get set during the icv_in_design flow target that are reused here (i.e. signoff.create_metal_fill.runset).
########################################
if {!([compare_collections [get_shapes -hier -quiet] [get_shapes -hier -include_fill -quiet]]=="0")} {
	puts "RM-info: Metal fill was detected in the source design.  Performing refill..."
	save_block

	# Metal fill options set during full metal fill insertion (i.e. icv_in_design.tcl) should still be relevant. Update if needed.
	redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}.report_app_options.signoff.create_metal_fill.rpt {report_app_options signoff.create_metal_fill*}
	
	if {$ICV_IN_DESIGN_METAL_FILL_ECO_THRESHOLD!=""} {
        	 set_app_options   -name  signoff.create_metal_fill.auto_eco_threshold_value -value $ICV_IN_DESIGN_METAL_FILL_ECO_THRESHOLD
	}
	
	## Building a signoff_metal_fill command line that should work for most. Update if needed.
	set create_metal_fill_cmd "signoff_create_metal_fill"
	
	if {$ICV_IN_DESIGN_METAL_FILL_TRACK_BASED != "off"} {
	
		## For track-based metal fill creation, it is recommended to specify foundry node for -track_fill in order to use -fill_all_track
		if {$ICV_IN_DESIGN_METAL_FILL_TRACK_BASED != "generic"} {
			lappend create_metal_fill_cmd "-track_fill $ICV_IN_DESIGN_METAL_FILL_TRACK_BASED -fill_all_tracks true"
		} else {
			lappend create_metal_fill_cmd "-track_fill $ICV_IN_DESIGN_METAL_FILL_TRACK_BASED"
		}
	
		## Track-based metal fill creation: optionally specify a ICV_IN_DESIGN_METAL_FILL_TRACK_BASED_PARAMETER_FILE  
		if {$ICV_IN_DESIGN_METAL_FILL_TRACK_BASED_PARAMETER_FILE != "auto" && [file exists [which $ICV_IN_DESIGN_METAL_FILL_TRACK_BASED_PARAMETER_FILE]]} {
			lappend create_metal_fill_cmd -track_fill_parameter_file $ICV_IN_DESIGN_METAL_FILL_TRACK_BASED_PARAMETER_FILE
		}
	}
	
	## Remove and refill if threshold set to 0, otherwise performing incremental fill.
	if {$ICV_IN_DESIGN_METAL_FILL_ECO_THRESHOLD!="0"} {
		lappend create_metal_fill_cmd -auto_eco true
	}
	
	puts "RM-info: Running $create_metal_fill_cmd"
	eval $create_metal_fill_cmd
} else {
	puts "RM-info: Skipping metal fill reinsertion as none detected in source design."
}

####################################
## Post-Functional ECO customizations
####################################
rm_source -file $TCL_USER_FUNCTIONAL_ECO_POST_SCRIPT -optional -print "TCL_USER_FUNCTIONAL_ECO_POST_SCRIPT"

if {![rm_source -file $TCL_USER_CONNECT_PG_NET_SCRIPT -optional -print "TCL_USER_CONNECT_PG_NET_SCRIPT"]} {
## Note : the following executes only if TCL_USER_CONNECT_PG_NET_SCRIPT is not sourced
	connect_pg_net
        # For non-MV designs with more than one PG, you should use connect_pg_net in manual mode.
}

save_block
save_lib

####################################
## Report and output
####################################
if {$REPORT_PARALLEL_SUBMIT_COMMAND != ""} {
        set REPORT_STAGE post_route
        set REPORT_ACTIVE_SCENARIOS $REPORT_FUNCTIONAL_ECO_ACTIVE_SCENARIO_LIST
	## Generate a file to pass necessary RM variables for running report_qor.tcl to the report_parallel command
	rm_generate_variables_for_report_parallel -work_directory ${REPORTS_DIR}/${REPORT_PREFIX} -file_name rm_tcl_var.tcl

	## Parallel reporting using the report_parallel command (requires a valid REPORT_PARALLEL_SUBMIT_COMMAND)
	report_parallel -work_directory ${REPORTS_DIR}/${REPORT_PREFIX} -submit_command ${REPORT_PARALLEL_SUBMIT_COMMAND} -max_cores ${REPORT_PARALLEL_MAX_CORES} -user_scripts [list "${REPORTS_DIR}/${REPORT_PREFIX}/rm_tcl_var.tcl" "[which report_qor.tcl]"]
} else {
	## Classic reporting
	rm_source -file report_qor.tcl
}
redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/run_end.rpt {run_end}

report_msg -summary
print_message_info -ids * -summary
rm_logparse $LOGS_DIR/functional_eco.log
echo [date] > functional_eco

exit

