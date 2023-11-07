##########################################################################################
# Script: floorplan.tcl
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################

source ./rm_utilities/procs_global.tcl 
source ./rm_utilities/procs_icc2.tcl 
rm_source -file ./rm_setup/design_setup.tcl
rm_source -file ./rm_setup/icc2_dp_setup.tcl
rm_source -file ./rm_setup/header_icc2_dp.tcl
rm_source -file sidefile_setup.tcl -after_file technology_override.tcl

set PREVIOUS_STEP ${COMPILE_BLOCK_NAME}_logic_opto
set CURRENT_STEP ${FLOORPLAN_BLOCK_NAME}

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

####################################
## Open design
####################################
open_lib $DESIGN_LIBRARY
copy_block -from ${DESIGN_NAME}/${PREVIOUS_STEP} -to ${DESIGN_NAME}/${CURRENT_STEP}
current_block ${DESIGN_NAME}/${CURRENT_STEP}

####################################
## Pre-floorplan customizations
####################################
rm_source -file $TCL_USER_FLOORPLAN_PRE_SCRIPT -optional -print "TCL_USER_FLOORPLAN_PRE_SCRIPT"

####################################
## Error check operation setup
####################################
set valid_operations {INITIALIZE_FLOORPLAN PLACE_PINS MACRO_PLACEMENT BOUNDARY_CELL TAP_CELL NODE_SUPPLEMENT}
set operations [list ]
if { $CREATE_FLOORPLAN_OPERATIONS == "ALL" } {
  set operations $valid_operations
} else {
  foreach operation $CREATE_FLOORPLAN_OPERATIONS {
    if { [lsearch $operations $operation] >=0} {
      puts "RM-warning: Skipping duplicate \"$operation\" specification in CREATE_FLOORPLAN_OPERATIONS."
    } elseif { [lsearch $valid_operations $operation] >=0} {
      lappend operations $operation
    } else {
      puts "RM-error: Skipping operation \"$operation\" as it is not valid.  See CREATE_FLOORPLAN_OPERATIONS comments for valid values."
    }
  }
}
puts "RM-info: Performing the following operations: \"$operations\""
####################################
## Source floorplan rules file.
####################################
rm_source -file $TCL_FLOORPLAN_RULE_SCRIPT -optional -print "TCL_FLOORPLAN_RULE_SCRIPT"

####################################
## Pre-floorplan customizations
####################################
rm_source -file $TCL_USER_CREATE_FLOORPLAN_FLAT_PRE_SCRIPT -optional -print "TCL_USER_CREATE_FLOORPLAN_FLAT_PRE_SCRIPT"

if { [lsearch $operations "INITIALIZE_FLOORPLAN"] >=0 } {

  ################################################################################
  ## Floorplanning : initialize_floorplan
  ## - Establish floorplan after auto_floorplanning.
  ################################################################################

  rm_source -file $TCL_USER_INITIALIZE_FLOORPLAN_PRE_SCRIPT -optional -print "TCL_USER_INITIALIZE_FLOORPLAN_PRE_SCRIPT"

  ## Floorplan initialization (node specific file)
  rm_source -file $SIDEFILE_CREATE_FLOORPLAN_FLAT_FLOORPLANNING
  
  ## Source track creation file if provided.
  rm_source -file $TCL_TRACK_CREATION_FILE -optional -print "TCL_TRACK_CREATION_FILE"
 
  ## Checks design prior to floorplanning.  This looks for tech info, layer directions, etc.
  if {$CHECK_DESIGN} { 
    redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_design.pre_floorplanning \
    {check_design -ems_database check_design.pre_floorplanning.ems -checks dp_pre_floorplan}
  }

  rm_source -file $TCL_USER_INITIALIZE_FLOORPLAN_POST_SCRIPT -optional -print "TCL_USER_INITIALIZE_FLOORPLAN_POST_SCRIPT"

  save_block -as ${DESIGN_NAME}/${CURRENT_STEP}_initialize_floorplan

} elseif { $TCL_TRACK_CREATION_FILE != "" } {
  ## Track creation file when floorplan initialization skipped (DEF input, refine flow, etc.) 
  rm_source -file $TCL_TRACK_CREATION_FILE
}

## set_technology for nodes requiring set_technology to be done after floorplan initialization 
if {$TECHNOLOGY_NODE != "" && ($SET_TECHNOLOGY_AFTER_FLOORPLAN || [get_attribute [current_block] technology_node -quiet] == "")} {
  set_technology -node $TECHNOLOGY_NODE
}
rm_source -file $SIDEFILE_INIT_DESIGN -optional -print "SIDEFILE_INIT_DESIGN"

## Check floorplan post initialization.  Located after track creation.
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_floorplan_rules.floorplan_init {check_floorplan_rules -error_view floorplan_rules_floorplan_init}

## Custom floorplanning (e.g. macro placement, blockages, voltage area creation, etc.)
## - Note that auto placement may move pre-placed macros.  Set to fixed if this is not desired.
rm_source -file $TCL_PHYSICAL_CONSTRAINTS_FILE -optional -print "TCL_PHYSICAL_CONSTRAINTS_FILE"

if { [lsearch $operations "PLACE_PINS"] >=0 } {

  ################################################################################
  ## Place design ports
  ################################################################################

  rm_source -file $TCL_USER_PLACE_PINS_INIT_PRE_SCRIPT -optional -print "TCL_USER_PLACE_PINS_INIT_PRE_SCRIPT"
  
  ## This file contains the pin constraints in TCL format (i.e. set_*_pin_constraints)
  rm_source -file $TCL_PIN_CONSTRAINT_FILE -optional -print "TCL_PIN_CONSTRAINT_FILE"

  ## This file contains the pin constraints in pin constraint format.
  if {[file exists [which $CUSTOM_PIN_CONSTRAINT_FILE]]} {
    read_pin_constraints -file_name $CUSTOM_PIN_CONSTRAINT_FILE
  }

  ## Check Design: Pre-Pin Placement
  if {$CHECK_DESIGN} { 
    redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_design.pre_pin_placement \
    {check_design -ems_database check_design.pre_pin_placement.ems -checks dp_pre_pin_placement}
  }

  ## Place pins
  place_pins -self

  ## Check and report unplaced ports.
  set unplaced_ports [get_ports -quiet -filter "port_type!=power && port_type!=ground && physical_status==unplaced"]
  foreach_in_collection port $unplaced_ports {
    set port_name [get_object_name $port]
    puts "RM-warning: Port \"$port_name\" is unplaced."
  }

  ## Write top-level port constraint file based on actual port locations.
  write_pin_constraints -self \
    -file_name $OUTPUTS_DIR/preferred_port_locations.tcl \
    -physical_pin_constraint {side | offset | layer} \
    -from_existing_pins

  ## Verify Top-level Port Placement Results
  redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_pin_placement {check_pin_placement -self -pre_route true -pin_spacing true -sides true -layers true -stacking true}

  ## Generate Top-level Port Placement Report
  redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_pin_placement {report_pin_placement -self}

  rm_source -file $TCL_USER_PLACE_PINS_INIT_POST_SCRIPT -optional -print "TCL_USER_PLACE_PINS_INIT_POST_SCRIPT"
  
  ## Export pin locations via write_floorplan and create a file pointer.
  ## - The ports will get reset in create_power, and restored & legalized during place_pins.
  set port_list [get_terminals -quiet -filter "physical_status==unrestricted"]
  write_floorplan -force -objects $port_list -def_version 5.8 -output $OUTPUTS_DIR/write_floorplan_top_pins
  define_user_attribute -type string -classes design -name port_placement_export_file
  set_attribute [current_block] port_placement_export_file "[file normalize $OUTPUTS_DIR/write_floorplan_top_pins/floorplan.tcl]"

  save_block -as ${DESIGN_NAME}/${CURRENT_STEP}_place_pins
}

####################################
## Floorplan fixing (if MACRO_PLACEMENT is skipped)
## - Floorplan rules must be pre-defined in the library. 
## - This can be done via TCL_FLOORPLAN_RULE_SCRIPT, sidefiles, etc.
####################################
if {[lsearch $operations "MACRO_PLACEMENT"] < 0} {
  redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_floorplan_rules.macro \
    {check_floorplan_rules -error_view floorplan_rules_macro}
  if {$FIX_FLOORPLAN_RULES} {
    redirect -var x {catch {report_floorplan_rules}}
    if {[regexp "^.*No floorplan rules exist" $x]} {
      puts "RM-error: FIX_FLOORPLAN_RULES is set true but no floorplan rules exist.  Fixing is being skipped..."
    } else {
      if {![rm_source -file $TCL_FIX_FLOORPLAN_RULES_CUSTOM_SCRIPT  -optional -print "TCL_FIX_FLOORPLAN_RULES_CUSTOM_SCRIPT"]} {
        fix_floorplan_rules
      }
      redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_floorplan_rules.macro.post_fix \
        {check_floorplan_rules -error_view floorplan_rules_macro_post_fix}
    }
  }
}

if { [lsearch $operations "MACRO_PLACEMENT"] >=0 } {

  ################################################################################
  ## Auto place macros (places non-fixed macros)
  ################################################################################

  rm_source -file $TCL_USER_MACRO_PLACEMENT_PRE_SCRIPT -optional -print "TCL_USER_MACRO_PLACEMENT_PRE_SCRIPT"

  ## Source auto-placement constraints file.
  ## - Include any macro planning application options in this file (i.e. plan.macro*)
  ## - Note "plan.macro.style" which controls how macros can be placed.  By default macros are placed
  ## - along edges of the partition.  This behavior can be adjusted via this option (e.g. freeform).
  rm_source -file $TCL_AUTO_PLACEMENT_CONSTRAINTS_FILE -optional -print "TCL_AUTO_PLACEMENT_CONSTRAINTS_FILE"

  set all_macros [get_cells -hier -filter is_hard_macro==true -quiet]
  if {[sizeof_collection $all_macros] > 0} {
    report_macro_constraints -allowed_orientations -preferred_location -alignment_grid -align_pins_to_tracks $all_macros > ${REPORTS_DIR}/${REPORT_PREFIX}/report_macro_constraints.rpt
  }

  ## To support incremental macro placement constraints, enable it and write out the preferred locations file
  if {$USE_INCREMENTAL_DATA && [file exists $OUTPUTS_DIR/preferred_macro_locations.tcl]} {
    rm_source -file $OUTPUTS_DIR/preferred_macro_locations.tcl
  }

  ####################################
  ## Check Design: Pre-Placement
  ####################################
  if {$CHECK_DESIGN} { 
    redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_design.pre_macro_placement \
    {check_design -ems_database check_design.pre_macro_placement.ems -checks dp_pre_macro_placement}
  }
  redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_app_options.plan.macro.rpt {report_app_options plan.macro*}

  ####################################
  ## Configure macro auto placement
  ## - Note that stdcell placement is demphasized here, but can be enabled
  ## - after power insertion in create_power.tcl
  ####################################
  set_app_option -name plan.macro.macro_place_only -value "true"

  set CMD_OPTIONS "-floorplan"

  if {[info exist CONGESTION_DRIVEN_PLACEMENT] && $CONGESTION_DRIVEN_PLACEMENT != ""} {
    set_app_option -name plan.place.congestion_driven_mode -value $CONGESTION_DRIVEN_PLACEMENT
    set CMD_OPTIONS "$CMD_OPTIONS -congestion"
  }

  if {[info exist TIMING_DRIVEN_PLACEMENT] && $TIMING_DRIVEN_PLACEMENT != ""} {
    set CMD_OPTIONS "$CMD_OPTIONS -timing_driven"
    set_app_option -name plan.place.timing_driven_mode -value $TIMING_DRIVEN_PLACEMENT
  }

  puts "RM-info : Running create_placement $CMD_OPTIONS"
  eval create_placement $CMD_OPTIONS

  report_placement \
    -physical_hierarchy_violations all \
    -wirelength all -hard_macro_overlap \
    -verbose high > ${REPORTS_DIR}/${REPORT_PREFIX}/report_placement.rpt

  ## write out macro preferred locations based on latest placement
  ## If this file exists on subsequent runs it will be used to drive the macro placement
  set all_macros [get_cells -hier -filter is_hard_macro==true -quiet]
  if {[sizeof_collection $all_macros] > 0} {
    file delete -force $OUTPUTS_DIR/preferred_macro_locations.tcl
    derive_preferred_macro_locations $all_macros -file $OUTPUTS_DIR/preferred_macro_locations.tcl
  }

  ####################################
  ## Floorplan fixing
  ## - Floorplan rules must be pre-defined in the library. 
  ## - This can be done via TCL_FLOORPLAN_RULE_SCRIPT, sidefiles, etc.
  ####################################
  redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_floorplan_rules.macro \
    {check_floorplan_rules -error_view floorplan_rules_macro}
  if {$FIX_FLOORPLAN_RULES} {
    redirect -var x {catch {report_floorplan_rules}}
    if {[regexp "^.*No floorplan rules exist" $x]} {
      puts "RM-error: FIX_FLOORPLAN_RULES is set true but no floorplan rules exist.  Fixing is being skipped..."
    } else {
      if {![rm_source -file $TCL_FIX_FLOORPLAN_RULES_CUSTOM_SCRIPT  -optional -print "TCL_FIX_FLOORPLAN_RULES_CUSTOM_SCRIPT"]} {
        fix_floorplan_rules
      }
      redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_floorplan_rules.macro.post_fix \
        {check_floorplan_rules -error_view floorplan_rules_macro_post_fix}
    }
  }

  ####################################
  ## Fix all macros
  ####################################
  set all_macros [get_cells -hier -filter is_hard_macro==true -quiet]
  if {[sizeof_collection $all_macros] > 0} {
    set_attribute $all_macros status "fixed"
  }

  ####################################
  ## Reset stdcell placement.
  ## - Stdcells can conflict with PG, boundary cell, and tap cell insertion.
  ####################################
  reset_placement

  rm_source -file $TCL_USER_MACRO_PLACEMENT_POST_SCRIPT -optional -print "TCL_USER_MACRO_PLACEMENT_POST_SCRIPT"

  save_block -as ${DESIGN_NAME}/${CURRENT_STEP}_macro_placement
}

if { [lsearch $operations "BOUNDARY_CELL"] >=0 } {
  ####################################
  ## Boundary cell insertion (node specific file)
  ## - Inspect the floorplan technology sidefile you received to see if node specific floorplan 
  ## - checking is needed.  This is typically done prior to boundary cell insertion. 
  ####################################
  rm_source -file $SIDEFILE_CREATE_FLOORPLAN_FLAT_BOUNDARY_CELLS -optional -print "SIDEFILE_CREATE_FLOORPLAN_FLAT_BOUNDARY_CELLS"
  redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_floorplan_rules.boundary_cell \
    {check_floorplan_rules -error_view floorplan_rules_boundary_cell}
}

####################################
## MV setup : provide a customized MV script	
####################################
## A Tcl script placeholder for your MV setup commands,such as power switch creation and level shifter insertion, etc
## Insert, assign, and connect power switches: Refer to examples/init_design.power_switch_example.tcl for sample commands 
rm_source -file $TCL_MV_SETUP_FILE -optional -print "TCL_MV_SETUP_FILE"

## Source Switch Connectivity file.  This is separate from TCL_MV_SETUP_FILE as it is also sourced in PNR init_design.
if {[rm_source -file $SWITCH_CONNECTIVITY_FILE -optional -print "SWITCH_CONNECTIVITY_FILE"]} {
        associate_mv_cell -power_switches
}

if { [lsearch $operations "TAP_CELL"] >=0 } {
  ####################################
  ## Tap cell insertion (node specific file)
  ####################################
  rm_source -file $SIDEFILE_CREATE_FLOORPLAN_FLAT_TAP_CELLS -optional -print "SIDEFILE_CREATE_FLOORPLAN_FLAT_TAP_CELLS"
  redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_floorplan_rules.tap_cell \
    {check_floorplan_rules -error_view floorplan_rules_tap_cell}
}

if { [lsearch $operations "NODE_SUPPLEMENT"] >=0 } {
  ####################################
  ## Foundry/node supplemental file.
  ####################################
  rm_source -file $SIDEFILE_CREATE_FLOORPLAN_FLAT_NODE_SUPPLEMENT -optional -print "SIDEFILE_CREATE_FLOORPLAN_FLAT_NODE_SUPPLEMENT"
  redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_floorplan_rules.node_supplement \
    {check_floorplan_rules -error_view floorplan_rules_node_supplement}
}

####################################
## Check Design: dp_floorplan_rules
####################################
if {$CHECK_DESIGN} { 
  redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_design.dp_floorplan_rules \
  {check_design -ems_database check_design.dp_floorplan_rules.ems -checks dp_floorplan_rules}
}

####################################
## Post-floorplan customizations
####################################
rm_source -file $TCL_USER_CREATE_FLOORPLAN_FLAT_POST_SCRIPT -optional -print "TCL_USER_CREATE_FLOORPLAN_FLAT_POST_SCRIPT"
####################################
## Error check operation setup
####################################
set valid_operations {PNS STDCELL_PLACEMENT}
set operations [list ]
if { $CREATE_POWER_OPERATIONS == "ALL" } {
  set operations $valid_operations
} else {
  foreach operation $CREATE_POWER_OPERATIONS {
    if { [lsearch $operations $operation] >=0} {
      puts "RM-warning: Skipping duplicate \"$operation\" specification in CREATE_POWER_OPERATIONS."
    } elseif { [lsearch $valid_operations $operation] >=0} {
      lappend operations $operation
    } else {
      puts "RM-error: Skipping operation \"$operation\" as it is not valid.  See CREATE_POWER_OPERATIONS comments for valid values."
    }
  }
}
puts "RM-info: Performing the following operations: \"$operations\""

####################################
## Pre-create_power customizations
####################################
rm_source -file $TCL_USER_CREATE_POWER_FLAT_PRE_SCRIPT -optional -print "TCL_USER_CREATE_POWER_FLAT_PRE_SCRIPT"

if { [lsearch $operations "PNS"] >=0 } {

  ################################################################################
  ## Power Insertion
  ################################################################################

  rm_source -file $TCL_USER_PNS_PRE_SCRIPT -optional -print "TCL_USER_PNS_PRE_SCRIPT"

  ####################################
  ## Check Design: Pre-Power Insertion
  ####################################
  if {$CHECK_DESIGN} { 
    redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_design.pre_power_insertion \
    {check_design -ems_database check_design.pre_power_insertion.ems -checks dp_pre_power_insertion}
  }

  ####################################
  ## Reset top-level pins prior to PG insertion if previously placed in create_floorplan.
  ## - The primary concern is collision with PG straps.
  ## - The ports are restored and legalized in place_pins.
  ####################################
  if {[get_attribute -quiet [current_block] port_placement_export_file] != ""} {
    set port_list [get_terminals -quiet -filter "physical_status==unrestricted"]
    if {[sizeof_collection $port_list] > 0} {
      set origin [lindex [get_attribute [current_design] boundary] 0]
      move_objects -to $origin $port_list
    }
  }

  ####################################
  ## PNS/PNA 
  ####################################
  rm_source -file $TCL_PNS_FILE -optional -print "TCL_PNS_FILE"
  rm_source -file $TCL_COMPILE_PG_FILE
  rm_source -file $TCL_POST_PNS_FILE -optional -print "TCL_POST_PNS_FILE"

  rm_source -file $TCL_USER_PNS_POST_SCRIPT -optional -print "TCL_USER_PNS_POST_SCRIPT"

  save_block -as ${DESIGN_NAME}/${CURRENT_STEP}_pns
}

####################################
## Check Design: pre_placement_stage
####################################
if {$CHECK_DESIGN} { 
  redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_design.pre_placement_stage \
  {check_design -ems_database check_design.pre_placement_stage.ems -checks pre_placement_stage}
}

if { [lsearch $operations "STDCELL_PLACEMENT"] >=0 } {

  ####################################
  ## Place and legalize stdcells.
  ## - Supports robust analysis (e.g. PG, PV, IR drop, etc.) of floorplan prior to PNR.
  ####################################

  rm_source -file $TCL_USER_STDCELL_PLACEMENT_PRE_SCRIPT -optional -print "TCL_USER_STDCELL_PLACEMENT_PRE_SCRIPT"

  ## Place and legalize stdcells
  ## - Disable scan_def checks and reset afterwards.
  set_app_options -name place.coarse.continue_on_missing_scandef -value true
  create_placement -effort low
  reset_app_options place.coarse.continue_on_missing_scandef
  connect_pg_net

  rm_source -file $TCL_USER_STDCELL_PLACEMENT_POST_SCRIPT -optional -print "TCL_USER_STDCELL_PLACEMENT_POST_SCRIPT"

  save_block -as ${DESIGN_NAME}/${CURRENT_STEP}_stdcell_placement

  ## Legalize placement
  rm_legalize_placement

  ## Check legality
  redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_legality {check_legality}
  
  ## Check phyiscal connectivity
  redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_pg_connectivity {check_pg_connectivity}

  ## Create DRC error report for PG
  redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_pg_drc {check_pg_drc}

  ## For some nodes, roll back to discard potential netlist changes
  if { [get_attribute -quiet [current_design] rm_fp_bf_attr] != "" } {
    close_block -force 
    open_block ${DESIGN_NAME}/${CURRENT_STEP}_stdcell_placement
  }

} else {

  ## Check phyiscal connectivity
  redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_pg_connectivity {check_pg_connectivity -check_std_cell_pins none}
  ## Create error report for PG ignoring std cells because they are not legalized
  redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_pg_drc {check_pg_drc -ignore_std_cells}

}

## check_mv_design -erc_mode and -power_connectivity
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_mv_design.erc_mode {check_mv_design -erc_mode}
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_mv_design.power_connectivity {check_mv_design -power_connectivity}

####################################
## Post-create_power customizations
####################################
rm_source -file $TCL_USER_CREATE_POWER_FLAT_POST_SCRIPT -optional -print "TCL_USER_CREATE_POWER_FLAT_POST_SCRIPT"
####################################
## Error check operation setup
####################################
set valid_operations {PLACE_PINS}
set operations [list ]
if { $PLACE_PINS_OPERATIONS == "ALL" } {
  set operations $valid_operations
} else {
  foreach operation $PLACE_PINS_OPERATIONS {
    if { [lsearch $operations $operation] >=0} {
      puts "RM-warning: Skipping duplicate \"$operation\" specification in PLACE_PINS_OPERATIONS."
    } elseif { [lsearch $valid_operations $operation] >=0} {
      lappend operations $operation
    } else {
      puts "RM-error: Skipping operation \"$operation\" as it is not valid.  See PLACE_PINS_OPERATIONS comments for valid values."
    }
  }
}
if {[llength $operations] > 0} {
  puts "RM-info: Performing the following operations: \"$operations\""
} else {
  puts "RM-warning: No valid operations were specified: PLACE_PINS_OPERATIONS == $PLACE_PINS_OPERATIONS.  This task is effectively being skipped."
}

####################################
## Pre-place_pins User Customizations
####################################
rm_source -file $TCL_USER_PLACE_PINS_FLAT_PRE_SCRIPT -optional -print "TCL_USER_PLACE_PINS_FLAT_PRE_SCRIPT"

if { [lsearch $operations "PLACE_PINS"] >=0 } {

  ################################################################################
  ## Place design pins
  ################################################################################
  
  ## This file contains the pin constraints in TCL format (i.e. set_*_pin_constraints)
  rm_source -file $TCL_PIN_CONSTRAINT_FILE -optional -print "TCL_PIN_CONSTRAINT_FILE"

  ## This file contains the pin constraints in pin constraint format.
  if {[file exists [which $CUSTOM_PIN_CONSTRAINT_FILE]]} {
    read_pin_constraints -file_name $CUSTOM_PIN_CONSTRAINT_FILE
  }

  ## Check Design: Pre-Pin Placement
  if {$CHECK_DESIGN} { 
    redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_design.pre_pin_placement \
    {check_design -ems_database check_design.pre_pin_placement.ems -checks dp_pre_pin_placement}
  }

  ## Detect if pin placement was performed in the create_floorplan task (i.e. port_placement_export_file exists).
  ## - If so, restore and legalize the pins where were reset during the create_power task.
  ## - Otherwise, run full pin placement.
  if {[get_attribute -quiet [current_block] port_placement_export_file] != ""} {
    ## Redirecting output and catching errors.  The exported floorplan file contains commands which remove & recreate design
    ## terminals.  These terminals are moved to the origin in create_power and are seen by the tool as duplicate shapes.
    ## In cases where duplicate shapes have been removed, the remove_shape command in the floorplan file will create "benign" errors.
    puts "RM-info: Sourcing the port placement export file: [get_attribute [current_block] port_placement_export_file]."
    redirect -var x {catch {rm_source -file [get_attribute [current_block] port_placement_export_file]}}
    set fout [open ${REPORTS_DIR}/${REPORT_PREFIX}/port_placement_export_file.log w]
    puts $fout $x
    close $fout
    if {[regexp "^.*Error:" $x]} {
      puts "RM-error: Error messages detected when loading ${REPORTS_DIR}/${REPORT_PREFIX}/port_placement_export_file.log.  Please inspect..."
    }
    place_pins -self -legalize
  } else {
    ## Place pins
    place_pins -self
  }

  ## Optionally fix place ports to prevent movement by downstream commands (i.e. compile_fusion).
  ## - This will fix ports/terminals whether they were placed above or prior to macro placement in create_floorplan.tcl.
  if {$FIX_PORT_PLACEMENT} {
    set port_list [get_ports -quiet -filter "port_type!=power && port_type!=ground && physical_status==placed"]
    if {[sizeof_collection $port_list] > 0} {
      set_attribute $port_list physical_status "fixed"
    }
  }

  ## Check and report unplaced ports.
  set unplaced_ports [get_ports -quiet -filter "port_type!=power && port_type!=ground && physical_status==unplaced"]
  foreach_in_collection port $unplaced_ports {
    set port_name [get_object_name $port]
    puts "RM-warning: Port \"$port_name\" is unplaced."
  }

  ## Write top-level port constraint file based on actual port locations in the design for reuse during incremental run.
  write_pin_constraints -self \
    -file_name $OUTPUTS_DIR/preferred_port_locations.tcl \
    -physical_pin_constraint {side | offset | layer} \
    -from_existing_pins

  ## Verify Top-level Port Placement Results
  redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_pin_placement {check_pin_placement -self -pre_route true -pin_spacing true -sides true -layers true -stacking true}

  ## Generate Top-level Port Placement Report
  redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_pin_placement {report_pin_placement -self}
}
  
## Post pin placement node specific file.
## - Typical uses are periphery routing blockages, port diode insertion, etc.
rm_source -file $SIDEFILE_PLACE_PINS -optional -print "SIDEFILE_PLACE_PINS"

####################################
## Post-place_pins customizations
####################################
rm_source -file $TCL_USER_PLACE_PINS_FLAT_POST_SCRIPT -optional -print "TCL_USER_PLACE_PINS_FLAT_POST_SCRIPT"

########################################################################
## Post-Design_planning User Customizations
########################################################################
rm_source -optional -file $TCL_USER_FLOORPLAN_POST_SCRIPT -print "TCL_USER_FLOORPLAN_POST_SCRIPT"

## Performing design checks prior to proceding to PNR.
set RM_FAILURE [rm_check_design -step init_design] 

save_block

redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/run_end.rpt {run_end}

write_qor_data -report_list "performance host_machine report_app_options" -label $REPORT_PREFIX -output $WRITE_QOR_DATA_DIR

report_msg -summary
print_message_info -ids * -summary
if {!$RM_FAILURE} {
	echo [date] > floorplan
} else {
	puts "RM-info: floorplan touch file was not created due to potential issues found in \"Basic floorplan and design checks\" section. Please check RM-error messages in the log."
}
exit

