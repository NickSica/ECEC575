##########################################################################################
# Script: create_power.tcl
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################

source ./rm_utilities/procs_global.tcl 
source ./rm_utilities/procs_icc2.tcl 
rm_source -file ./rm_setup/design_setup.tcl
rm_source -file ./rm_setup/icc2_dp_setup.tcl
rm_source -file ./rm_setup/header_icc2_dp.tcl
rm_source -file sidefile_setup.tcl -after_file technology_override.tcl

set PREVIOUS_STEP $CREATE_FLOORPLAN_FLAT_BLOCK_NAME
set CURRENT_STEP $CREATE_POWER_FLAT_BLOCK_NAME

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
# Open design
####################################
open_lib $DESIGN_LIBRARY
copy_block -from ${DESIGN_NAME}/${PREVIOUS_STEP} -to ${DESIGN_NAME}/${CURRENT_STEP}
current_block ${DESIGN_NAME}/${CURRENT_STEP}

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

save_block -as ${DESIGN_NAME}/${CURRENT_STEP}

redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/run_end.rpt {run_end}

write_qor_data -report_list "performance host_machine report_app_options" -label $REPORT_PREFIX -output $WRITE_QOR_DATA_DIR

report_msg -summary
print_message_info -ids * -summary
echo [date] > create_power

exit 

