##########################################################################################
# Tool: IC Compiler II
# Script: expand_outline.tcl
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################


source ./rm_utilities/procs_global.tcl 
source ./rm_utilities/procs_icc2.tcl 
rm_source -file ./rm_setup/design_setup.tcl
rm_source -file ./rm_setup/icc2_dp_setup.tcl
rm_source -file ./rm_setup/header_icc2_dp.tcl
rm_source -file sidefile_setup.tcl -after_file technology_override.tcl

set PREVIOUS_STEP $COMMIT_BLOCK_BLOCK_NAME
set CURRENT_STEP  $EXPAND_OUTLINE_BLOCK_NAME

if { [info exists env(RM_VARFILE)] } { 
  if { [file exists $env(RM_VARFILE)] } { 
    rm_source -file $env(RM_VARFILE)
  } else {
    puts "RM-error: env(RM_VARFILE) specified but not found"
  }
}

set REPORT_PREFIX ${CURRENT_STEP}
file mkdir ${REPORTS_DIR}/${REPORT_PREFIX}
puts "RM-info: PREVIOUS_STEP = $PREVIOUS_STEP"
puts "RM-info: CURRENT_STEP  = $CURRENT_STEP"
puts "RM-info: REPORT_PREFIX = $REPORT_PREFIX"

redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/run_start.rpt {run_start}

################################################################################
# Create and read the design	
################################################################################
if {$DP_HIGH_CAPACITY_MODE} {
  set DESIGN_VIEW "outline"
} else {
  set DESIGN_VIEW "design"
}

rm_open_design -from_lib      ${WORK_DIR}/${DESIGN_LIBRARY} \
               -block_name    $DESIGN_NAME \
               -from_label    $PREVIOUS_STEP \
               -to_label      $CURRENT_STEP \
               -view          $DESIGN_VIEW \
	       -dp_block_refs $DP_BLOCK_REFS

## Setup distributed processing options
set HOST_OPTIONS ""
if {$DISTRIBUTED} {
   ## Set host options for all blocks.
   set_host_options -name block_script -submit_command $BLOCK_DIST_JOB_COMMAND
   set HOST_OPTIONS "-host_options block_script"

   ## This is an advanced capability which enables custom resourcing for specific blocks.
   ## It is not needed if all blocks have the same resource requirements.  See the
   ## comments embedded for the BLOCK_DIST_JOB_FILE variable definition to setup.
   rm_source -file $BLOCK_DIST_JOB_FILE -optional -print "BLOCK_DIST_JOB_FILE"

   report_host_options
}

## Get block names for references defined by DP_BLOCK_REFS.  This list is used in some hier DP commands.
set child_blocks [ list ]
foreach block $DP_BLOCK_REFS {lappend child_blocks [get_object_name [get_blocks -hier -filter block_name==$block]]}
set all_blocks "$child_blocks [get_object_name [current_block]]"

####################################
## PRE-expand_outline customizations
####################################
rm_source -file $TCL_USER_EXPAND_OUTLINE_PRE_SCRIPT -optional -print "TCL_USER_EXPAND_OUTLINE_PRE_SCRIPT"

################################################################################
# 1) Define the constraint mapping file.
# 2) High Capacity mode (true; default): 1) Expand the outline view 2) Load UPF only.  SDC loading is deferred until
#    timing info is needed.  This is done for capacity and runtime reasons.
# 3) High Capacity mode (false): Load UPF and SDC constraints.
################################################################################
if {$CONSTRAINT_MAPPING_FILE != ""} {
   set_constraint_mapping_file $CONSTRAINT_MAPPING_FILE
} else {
   set default_mapfile "./split/mapfile" 
   puts "RM-warning : CONSTRAINT_MAPPING_FILE was not set, setting the constraint mapping file to the default $default_mapfile"
   set_constraint_mapping_file $default_mapfile
}
report_constraint_mapping_file

if {$DP_HIGH_CAPACITY_MODE == "true"} {
  puts "RM-info : Expanding top level outline"
  expand_outline
  ## Loading top-level separately as expand_outline has created the "design" view.
  eval load_block_constraints -type UPF -type CLKNET -blocks [get_blocks $child_blocks] ${HOST_OPTIONS}
  eval load_block_constraints -type UPF -type CLKNET -blocks [get_blocks [current_block]] ${HOST_OPTIONS}
} else {
  eval load_block_constraints -type SDC -type UPF -type CLKNET -blocks [get_blocks $all_blocks] ${HOST_OPTIONS}
}

puts "RM-info : Running connect_pg_net -automatic on all blocks"
connect_pg_net -automatic -all_blocks

if {$BOTTOM_BLOCK_VIEW == "abstract"} {
   ####################################
   # Check Design: Pre-Placement Abstract
   ####################################
   if {$CHECK_DESIGN} { 
      redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_design.pre_create_placement_abstract \
       {check_design -ems_database check_design.pre_create_placement_abstract.ems -checks dp_pre_create_placement_abstract}
   }

   ####################################
   # Create block placement abstracts in preparation for shaping.
   ####################################
   puts "RM-info : Creating Placement Abstracts for all blocks"
   eval create_abstract -force_recreate -placement -blocks [get_blocks $child_blocks] ${HOST_OPTIONS}
}

# It is expected that check_mv_design will complain about two items:
# ---------- Power domain rule ----------
# Error: Power domain '<domain name>' does not have any primary voltage area. (MV-019)
# This is because at this point in the flow the VA has not been created.  It will be created
# during block shaping.
#
# ---------- PG net rule ----------
# Error: PG net '<switched PG Net name>' has no valid PG source(s) or driver(s). (MV-007)
# At this point in the flow the PG switch has not been implemented so the switched power supplies
# do not have a driver.  This will be fixed during PG creation.

# check_mv_design -erc_mode and -power_connectivity
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_mv_design.erc_mode {check_mv_design -erc_mode}
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_mv_design.power_connectivity {check_mv_design -power_connectivity}

rm_source -file $TCL_TIMING_RULER_SETUP_FILE -optional -print "Warning: TCL_TIMING_RULER_SETUP_FILE not specified. Timing ruler will not work accurately if it is not defined."

########################################################################
## Place IO cells for chip level design (if IOs are not placed). 
########################################################################
if {[rm_detect_fp_valid_operations -operations {io_placement}] == "io_placement"} {
  if {[file exists [which $TCL_PAD_CONSTRAINTS_FILE]]} {
    puts "RM-info : Running place_io..."
    rm_source -optional -file $TCL_USER_PLACE_IO_PRE_SCRIPT -print TCL_USER_PLACE_IO_PRE_SCRIPT ;
    rm_source -file $TCL_PAD_CONSTRAINTS_FILE -print TCL_USER_PLACE_IO_PRE_SCRIPT ;
    place_io ;
    rm_source -file $TCL_RDL_FILE -optional -print "TCL_RDL_FILE"
    set_attribute -objects [get_cells -quiet -filter is_io==true -hier]    -name status -value fixed
    set_attribute -objects [get_cells -quiet -filter pad_cell==true -hier] -name status -value fixed
    rm_source -optional -file $TCL_USER_PLACE_IO_POST_SCRIPT -print TCL_USER_PLACE_IO_POST_SCRIPT ; 
  } else {
    puts "RM-error: [sizeof_collection $unplaced_ios] unplaced io cells found." ;
  }
}

########################################################################
## Place top-level ports for hierarchical design (e.g. not chip level). 
########################################################################

## Determine if top-level port placement is provided in input DEF/TCL floorplan file.
define_user_attribute -type string -classes design -name top_pin_placement
if {[rm_detect_fp_valid_operations -operations {top_pin_placement}] == "top_pin_placement"} {
  set_attribute [current_block] top_pin_placement "0"
} else {
  set_attribute [current_block] top_pin_placement "1"
}

## Perform pin placement when both conditions below are met:
## 1) Pin placement is enabled for this task 
## 2) User wants to run even though pin placement was detected in input DEF/TCL
if {($PLACE_PINS_SELF == "expand_outline" || $PLACE_PINS_SELF == "both") && (![get_attribute [current_block] top_pin_placement] || $PLACE_PINS_SELF != "none")} {
  ## This file contains the pin constraints in TCL format (i.e. set_*_pin_constraints)
  rm_source -file $TCL_PIN_CONSTRAINT_FILE_SELF -optional -print "TCL_PIN_CONSTRAINT_FILE_SELF"

  ## This file contains the pin constraints in pin constraint format.
  if {[file exists [which $CUSTOM_PIN_CONSTRAINT_FILE_SELF]]} {
    read_pin_constraints -file_name $CUSTOM_PIN_CONSTRAINT_FILE_SELF
  }

  ## Place pins
  place_pins -self

  ## Write top-level port constraint file based on actual port locations.
  write_pin_constraints -self \
    -file_name $OUTPUTS_DIR/preferred_port_locations.tcl \
    -physical_pin_constraint {side | offset | layer} \
    -from_existing_pins

  ## Verify Top-level Port Placement Results
  redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_pin_placement {check_pin_placement -self -pre_route true -pin_spacing true -sides true -layers true -stacking true}

  ## Generate Top-level Port Placement Report
  redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_pin_placement {report_pin_placement -self}
}

####################################
## Post-expand_outline customizations
####################################
rm_source -file $TCL_USER_EXPAND_OUTLINE_POST_SCRIPT -optional -print "TCL_USER_EXPAND_OUTLINE_POST_SCRIPT"

save_lib -all

redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/run_end.rpt {run_end}

write_qor_data -report_list "performance host_machine report_app_options" -label $REPORT_PREFIX -output $WRITE_QOR_DATA_DIR

report_msg -summary
print_message_info -ids * -summary
echo [date] > expand_outline

exit 
