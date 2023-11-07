##########################################################################################
# Script: write_data.tcl
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################

source ./rm_utilities/procs_global.tcl 
source ./rm_utilities/procs_icc2.tcl 
rm_source -file ./rm_setup/design_setup.tcl
rm_source -file ./rm_setup/icc2_dp_setup.tcl
rm_source -file ./rm_setup/icc2_pnr_setup.tcl
rm_source -file ./rm_setup/header_icc2_pnr.tcl
rm_source -file sidefile_setup.tcl -after_file technology_override.tcl

set PREVIOUS_STEP $WRITE_DATA_FROM_BLOCK_NAME
set CURRENT_STEP $WRITE_DATA_BLOCK_NAME
if { [info exists env(RM_VARFILE)] } {
	if { [file exists $env(RM_VARFILE)] } {
		rm_source -file $env(RM_VARFILE)
	} else {
		puts "RM-error: env(RM_VARFILE) specified but not found"
	}
}

if {[info exist INCREMENTAL_INIT_DESIGN]} {rm_source -file ./rm_setup/incremental_design_setup.tcl}

set REPORT_PREFIX $CURRENT_STEP
file mkdir ${REPORTS_DIR}/${REPORT_PREFIX}
puts "RM-info: PREVIOUS_STEP = $PREVIOUS_STEP"
puts "RM-info: CURRENT_STEP  = $CURRENT_STEP"
puts "RM-info: REPORT_PREFIX = $REPORT_PREFIX"
redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/run_start.rpt {run_start}
   
## This is a common file used in both the DP and PNR flows.  The variable "rm_dp_flow" is passed from the DP Makefile to indicate
## that the DP flow is being run.
if {[info exists rm_dp_flow] && ($DP_FLOW == "hier")} {
    rm_open_design -from_lib      ${WORK_DIR}/${DESIGN_LIBRARY} \
                   -block_name    $DESIGN_NAME \
                   -from_label    $PREVIOUS_STEP \
                   -to_label      $CURRENT_STEP \
	           -dp_block_refs $DP_BLOCK_REFS
} else {
  open_lib $DESIGN_LIBRARY
  copy_block -from ${DESIGN_NAME}/${PREVIOUS_STEP} -to ${DESIGN_NAME}/${CURRENT_STEP}
  current_block ${DESIGN_NAME}/${CURRENT_STEP}
  link_block
}

## Non-persistent settings to be applied in each step (optional)
rm_source -file $TCL_USER_NON_PERSISTENT_SCRIPT -optional -print "TCL_USER_NON_PERSISTENT_SCRIPT"

########################################################################
## Pre-write_data customizations
########################################################################
rm_source -optional -file $TCL_USER_WRITE_DATA_PRE_SCRIPT -print TCL_USER_WRITE_DATA_PRE_SCRIPT

########################################################################
## change_names
########################################################################
## Purpose : change the names of ports, cells, and nets in a design, in order to make the output netlist, 
##  DEF, SPEF, ... etc conform to specified name rules
##  Note : 
##  - If the current block is a sub cell of another block, make sure no port names are changed during change_names;
##    if there is, you either modify your naming rule to avoid the name change, re-setup the connection between
##    the renamed port and the net at the parent level, or if the blocks are from commit_block then you can run 
##    the same change_names command before commit_block at the parent level.
##  - To preview whether there is any potential port name changes, check the report_names log first
if {$DEFINE_NAME_RULES_OPTIONS != ""} {
	eval define_name_rules verilog $DEFINE_NAME_RULES_OPTIONS
}
redirect -tee -file ${REPORTS_DIR}/${WRITE_DATA_BLOCK_NAME}.report_name_rules.log {report_name_rules}
redirect -tee -file ${REPORTS_DIR}/${WRITE_DATA_BLOCK_NAME}.report_names.log {report_names -rules verilog}

change_names -rules verilog -hierarchy

save_block

######################################################################## 
## write_verilog for logic only, DC, PT, FM, and VC LP 
######################################################################## 
## write_verilog (no pg, and no physical only cells)
set write_verilog_logic_only_cmd_root "write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations pg_objects end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells} -hierarchy all"
set write_verilog_logic_only_cmd "$write_verilog_logic_only_cmd_root ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}.v" 

## write_verilog for comparison with a DC netlist (no pg, no physical only cells, and no diodes)
set write_verilog_dc_cmd_root "write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations pg_objects end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells diode_cells} -hierarchy all"
set write_verilog_dc_cmd "$write_verilog_dc_cmd_root ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}.dc.v" 

## write_verilog for PrimeTime (no pg, no physical only cells but with diodes and DCAP for leakage power analysis)
set write_verilog_pt_cmd_root "write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations pg_objects end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells flip_chip_pad_cells} -hierarchy all"
if {$CHIP_FINISH_METAL_FILLER_LIB_CELL_LIST != ""} {
	lappend write_verilog_pt_cmd_root -force_reference $CHIP_FINISH_METAL_FILLER_LIB_CELL_LIST
}
set write_verilog_pt_cmd "$write_verilog_pt_cmd_root ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}.pt.v" 

## write_verilog for Formality (with pg, no physical only cells, and no supply statements) 
set write_verilog_fm_cmd_root "write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells supply_statements} -hierarchy all" 
set write_verilog_fm_cmd "$write_verilog_fm_cmd_root ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME},fm.v" 
 
## write_verilog for VC LP (with pg, no physical_only cells, no diodes, and no supply statements)
set write_verilog_vclp_cmd_root "write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells diode_cells supply_statements} -hierarchy all"
set write_verilog_vclp_cmd "$write_verilog_vclp_cmd_root ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}.vc_lp.v"

set output_group_1_list "write_verilog_logic_only_cmd write_verilog_dc_cmd write_verilog_pt_cmd write_verilog_fm_cmd write_verilog_vclp_cmd"
## Override provided for future customization
if { [info exists output_group_1_list_override ] } {
  puts "RM-info: Using override for group_1 outputs"
  puts "RM-info:        default group_1: $output_group_1_list"
  set output_group_1_list $output_group_1_list_override
  puts "RM-info:            new group_1: $output_group_1_list"
}

set parallel_execute_cmd "parallel_execute -commands_only \[list\n"
foreach cmd $output_group_1_list {
  puts "RM-info: running [subst $$cmd]"
  set parallel_execute_cmd "${parallel_execute_cmd}[subst $$cmd]\n"
}
set parallel_execute_cmd "${parallel_execute_cmd}\]"

puts "RM-info: RUN - ${parallel_execute_cmd}"

eval ${parallel_execute_cmd}

########################################################################
## write_verilog for LVS, write_gds & write_oasis
########################################################################
## write_verilog for LVS (with pg, and with physical only cells)
set write_verilog_lvs_cmd_root "write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations empty_modules} -hierarchy all"
set write_verilog_lvs_cmd "$write_verilog_lvs_cmd_root ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}.lvs.v" 

## write_gds
set_app_options -name file.gds.allow_incompatible_units -value $WRITE_GDS_ALLOW_INCOMPATIBLE_UNITS
set write_gds_cmd_root "write_gds -compress -hierarchy all -long_names -keep_data_type"
if {[file exists $WRITE_GDS_LAYER_MAP_FILE]} {lappend write_gds_cmd_root -layer_map $WRITE_GDS_LAYER_MAP_FILE}
set write_gds_cmd "$write_gds_cmd_root ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}.gds" 

set write_oasis_cmd_root "write_oasis -compress 6 -hierarchy all -keep_data_type"
if {[file exists $WRITE_OASIS_LAYER_MAP_FILE]} {lappend write_oasis_cmd_root -layer_map $WRITE_OASIS_LAYER_MAP_FILE}
set write_oasis_cmd "$write_oasis_cmd_root ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}.oasis" 

rm_source -file $SIDEFILE_WRITE_DATA -optional -print "SIDEFILE_WRITE_DATA"


set output_group_2_list "write_verilog_lvs_cmd write_gds_cmd write_oasis_cmd"
## Override provided for future customization
if { [info exists output_group_2_list_override ] } {
  puts "RM-info: Using override for group_2 outputs"
  puts "RM-info:        default group_2: $output_group_2_list"
  set output_group_2_list $output_group_2_list_override
  puts "RM-info:            new group_2: $output_group_2_list"
}

set parallel_execute_cmd "parallel_execute -commands_only \[list\n"
foreach cmd $output_group_2_list {
  puts "RM-info: running [subst $$cmd]"
  set parallel_execute_cmd "${parallel_execute_cmd}[subst $$cmd]\n"
}
set parallel_execute_cmd "${parallel_execute_cmd}\]"

puts "RM-info: RUN - ${parallel_execute_cmd}"

eval ${parallel_execute_cmd}


########################################################################
## save_upf
########################################################################
## Write out UPF
if {$UPF_SUPPLEMENTAL_FILE != ""} {

	## For golden UPF flow
	## write supplemental UPF with supply exceptions
	save_upf ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}.supplemental.pg.upf
	## write supplemental UPF without supply exceptions
	set_app_options -name mv.upf.save_upf_include_supply_exceptions -value false
	save_upf ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}.supplemental.upf
	reset_app_options mv.upf.save_upf_include_supply_exceptions

} else {

	## For UPF prime flow
	save_upf ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}.upf

}
########################################################################
## write_script, write_routing_constraints, and write_parasitics
########################################################################
## write_script
#  writes multiple files to the specified directory. 
#  It writes mode_{mode_name}.tcl for mode specific info, corner_{corner_name}.tcl for corner specific info, 
#  design.tcl for non-mode or corner specific info, cts.tcl for cts options and top.tcl that sources all scripts. 
write_script -force -compress gzip -output ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}_wscript
#  -format pt generates PT compatible outputs 
write_script -force -compress gzip -format pt -output ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}_wscript_for_pt

## Writes routing constraints of the design in a Tcl script, such as :
## create_routing_rule, set_routing_rule, create_wire_matching, create_length_limit, create_differential_group, 
## create_net_shielding, create_net_priority, create_bus_routing_style and set_ignored_layers.
write_routing_constraints ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}_write_routing_constraints

## write_parasitics
update_timing
write_parasitics -compress -output ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}
########################################################################
## write_floorplan and write_def
########################################################################
set write_floorplan_cmd_root "write_floorplan \
  -format icc2 \
  -def_version 5.8 \
  -force \
  -read_def_options {-add_def_only_objects {all} -skip_pg_net_connections} \
  -exclude {scan_chains fills pg_metal_fills routing_rules} \
  -net_types {power ground} \
  -include_physical_status {fixed locked}"
set write_floorplan_cmd "$write_floorplan_cmd_root -output ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}_write_floorplan" 
puts "RM-info: running $write_floorplan_cmd"
eval ${write_floorplan_cmd}

## write_def : Enable the following for LEF/DEF based flow to StarRC if LEF is written from the tool,
#  since write_lef in the tool doesn't currently support WRONGDIRECTION syntax.
#  This is not needed if you are using LEF files which contain the WRONGDIRECTION syntax already.
#	set_app_options -name file.def.wrong_way_wiring_to_special_net -value true
set write_def_cmd_root "write_def -compress gzip -version 5.8 -include_tech_via_definitions"
set write_def_cmd "$write_def_cmd_root ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}.def"

puts "RM-info: running $write_def_cmd"
eval ${write_def_cmd}



  ####################################################################################################
## Used by hierarchical design planning flow to write out block data.
## - This can be done serially or distributed.
  ####################################################################################################
if {[info exists rm_dp_flow] && ($DP_FLOW == "hier")} {
   set write_data_script "./rm_icc2_pnr_scripts/write_data_files.tcl" 
   if {!$DISTRIBUTED} {
    set top_block [get_attribute [current_block] full_name]
    foreach block_ref ${DP_BLOCK_REFS} {
       set block [get_blocks -hier -filter block_name==$block_ref]
       rm_source -file $write_data_script
       current_block $top_block
    }
    current_block $top_block
   } else {
      ## Set host options for all blocks.
      set_host_options -name block_script -submit_command $BLOCK_DIST_JOB_COMMAND
      set HOST_OPTIONS "-host_options block_script"
      report_host_options

      ## Write block data via run_block_script
      eval run_block_script -script ${write_data_script} -blocks [list ${DP_BLOCK_REFS}] -work_dir ./work_dir/block_export ${HOST_OPTIONS}
   }

   ## Remove estimated corner from top-level.
   if {[llength [get_corners estimated_corner -quiet]] != 0} {
     remove_corners estimated_corner
   }

   ## Remove constraint mapping file.
   set_constraint_mapping_file -reset

   ## Set editablity false for all blocks
   set_editability -value false -blocks [get_block -hier]
   save_block
   report_editability -blocks [get_block -hier]
}

if { [ info exists rm_dp_flow ] } {
  ####################################################################################################
  ## Export handshake file between flat design planning & PNR flows.
  ## - Automation to aid in flat design planning flow.
  ####################################################################################################
  set fid [ open "./header_from_dprm.tcl" "w" ]
  puts $fid "## ----------------------------------------"
  puts $fid "##"
  puts $fid "## Created by RM with $synopsys_program_name on [date] "
  puts $fid "## - This file provides automation between the RM DP and PNR flows."
  puts $fid "## - Point to this file in the PNR init_design.tcl via variable \"header_from_dprm\"."
  puts $fid "##"
  puts $fid "## ----------------------------------------"
  puts $fid ""
  puts $fid "if {\$INIT_DESIGN_INPUT==\"ASCII\"} {"
  puts $fid "  set TCL_FLOORPLAN_FILE [file normalize ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}_write_floorplan/floorplan.tcl]"
  puts $fid "  ## Below are the input files used during design planning."
  puts $fid "  ## set VERILOG_NETLIST_FILES [list $VERILOG_NETLIST_FILES]"
  puts $fid "  ## set TCL_MCMM_SETUP_FILE [file normalize [which $TCL_MCMM_SETUP_FILE]]"
  puts $fid "  ## set UPF_FILE [file normalize [which $UPF_FILE]]"
  puts $fid "  if {!\[file exists ${DESIGN_LIBRARY}_dp\]} {"
  puts $fid "    file rename $DESIGN_LIBRARY ${DESIGN_LIBRARY}_dp"
  puts $fid "  }"
  puts $fid "}"
  puts $fid ""
  puts $fid "if {\$INIT_DESIGN_INPUT==\"DC_ASCII\"} {"
  puts $fid "  puts \"RM-warning : Resetting INIT_DESIGN_INPUT from \"DC_ASCII\" to \"NDM\" for input into PNR flow.\""
  puts $fid "  set INIT_DESIGN_INPUT \"NDM\""
  puts $fid "  if {!\[file exists ${DESIGN_LIBRARY}_dp\]} {"
  puts $fid "    file rename $DESIGN_LIBRARY ${DESIGN_LIBRARY}_dp"
  puts $fid "  }"
  puts $fid "  set INIT_DESIGN_INPUT_LIBRARY [file normalize ${DESIGN_LIBRARY}_dp]"
  puts $fid "  set INIT_DESIGN_INPUT_BLOCK_NAME $WRITE_DATA_BLOCK_NAME"
  puts $fid "}"
  puts $fid ""
  puts $fid "if {\$INIT_DESIGN_INPUT==\"NDM\"} {"
  puts $fid "  if {!\[file exists ${DESIGN_LIBRARY}_dp\]} {"
  puts $fid "    file rename $DESIGN_LIBRARY ${DESIGN_LIBRARY}_dp"
  puts $fid "  }"
  puts $fid "  set INIT_DESIGN_INPUT_LIBRARY [file normalize ${DESIGN_LIBRARY}_dp]"
  puts $fid "  set INIT_DESIGN_INPUT_BLOCK_NAME $WRITE_DATA_BLOCK_NAME"
  puts $fid "}"
  puts $fid ""
  close $fid
}

########################################################################
## Post-write_data customizations
########################################################################
rm_source -optional -file $TCL_USER_WRITE_DATA_POST_SCRIPT -print TCL_USER_WRITE_DATA_POST_SCRIPT

redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/run_end.rpt {run_end}
report_msg -summary
print_message_info -ids * -summary
if { [ info exists rm_dp_flow ] } {
  echo [date] > write_data_dp
} elseif {[info exists INCREMENTAL_INIT_DESIGN]} {
  echo [date] > write_data_for_init_design
  rm_logparse $LOGS_DIR/write_data.log
} else {
  echo [date] > write_data
  rm_logparse $LOGS_DIR/write_data.log
}

exit

