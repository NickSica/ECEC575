##########################################################################################
# Tool: IC Compiler II 
# Script: place_pins.tcl
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################

source ./rm_utilities/procs_global.tcl 
source ./rm_utilities/procs_icc2.tcl 
rm_source -file ./rm_setup/design_setup.tcl
rm_source -file ./rm_setup/icc2_dp_setup.tcl
rm_source -file ./rm_setup/header_icc2_dp.tcl
rm_source -file sidefile_setup.tcl -after_file technology_override.tcl

set PREVIOUS_STEP $CREATE_POWER_FLAT_BLOCK_NAME
set CURRENT_STEP $PLACE_PINS_FLAT_BLOCK_NAME

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
# Open design
####################################
open_lib $DESIGN_LIBRARY
copy_block -from ${DESIGN_NAME}/${PREVIOUS_STEP} -to ${DESIGN_NAME}/${CURRENT_STEP}
current_block ${DESIGN_NAME}/${CURRENT_STEP}

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

## Performing design checks prior to proceding to PNR.
set RM_FAILURE [rm_check_design -step init_design] 

save_block

redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/run_end.rpt {run_end}

write_qor_data -report_list "performance host_machine report_app_options" -label $REPORT_PREFIX -output $WRITE_QOR_DATA_DIR

report_msg -summary
print_message_info -ids * -summary
if {!$RM_FAILURE} {
	echo [date] > place_pins
} else {
	puts "RM-info: place_pins touch file was not created due to potential issues found in \"Basic floorplan and design checks\" section. Please check RM-error messages in the log."
}
exit

