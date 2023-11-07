##########################################################################################
# Tool: IC Compiler II 
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

set PREVIOUS_STEP $PLACEMENT_BLOCK_NAME
set CURRENT_STEP  $CREATE_POWER_BLOCK_NAME

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

########################################################################
# Open design
########################################################################
rm_open_design -from_lib      ${WORK_DIR}/${DESIGN_LIBRARY} \
               -block_name    $DESIGN_NAME \
               -from_label    $PREVIOUS_STEP \
               -to_label      $CURRENT_STEP \
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

## Non-persistent settings to be applied in each step (optional)
rm_source -file $TCL_USER_NON_PERSISTENT_SCRIPT -optional -print "TCL_USER_NON_PERSISTENT_SCRIPT"

####################################
## Pre-create_power User Customizations
####################################
rm_source -file $TCL_USER_CREATE_POWER_PRE_SCRIPT -optional -print "TCL_USER_CREATE_POWER_PRE_SCRIPT"

####################################
# GLOBAL PLANNING
####################################
rm_source -file $TCL_GLOBAL_PLANNING_FILE -optional -print "TCL_GLOBAL_PLANNING_FILE"

####################################
# Check Design: Pre-Power Insertion
####################################
if {$CHECK_DESIGN} { 
   redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_design.pre_power_insertion \
    {check_design -ems_database check_design.pre_power_insertion.ems -checks dp_pre_power_insertion}
}

####################################
## Optionally reset top-level pins prior to PG insertion.
## - The primary concern is collision with PG straps.
####################################
## - Reset pin placement when both conditions are met:
## 1) PLACE_PINS_SELF is set to "both"
## 2) Pin placement was ran in create_floorplan even though pin placement was detected in input DEF/TCL
## - Final top pin placement is performed in the place_pins task based on pin placement output below.
if {($PLACE_PINS_SELF == "both") && (![get_attribute [current_block] top_pin_placement] || $PLACE_PINS_SELF != "none")} {
  set top_pin_list [get_terminals -quiet -filter "physical_status==unrestricted && port.port_type!=power && port.port_type!=ground"]
  define_user_attribute -type string -classes design -name top_pin_placement_export
  set_attribute [current_block] top_pin_placement_export ""
  if {[sizeof_collection $top_pin_list]} {
    write_floorplan -force -objects $top_pin_list -def_version 5.8 -output $OUTPUTS_DIR/write_floorplan_top_pins
    set_attribute [current_block] top_pin_placement_export "[file normalize $OUTPUTS_DIR/write_floorplan_top_pins/floorplan.tcl]"
    set origin [lindex [get_attribute [current_design] boundary] 0]
    move_objects -to $origin $top_pin_list
  }
}

####################################
# PNS/PNA 
####################################
rm_source -file $TCL_PNS_FILE -optional -print "TCL_PNS_FILE"

if {$PNS_CHARACTERIZE_FLOW == "true" && $TCL_COMPILE_PG_FILE != ""} {
   puts "RM-info : RUNNING PNS CHARACTERIZATION FLOW because \$PNS_CHARACTERIZE_FLOW == true"
   characterize_block_pg -output block_pg -compile_pg_script [which $TCL_COMPILE_PG_FILE]
   set_constraint_mapping_file ./block_pg/pg_mapfile
   ## run_block_compile_pg will honor the set_editability settings by default
   puts "RM-info : Running run_block_compile_pg $HOST_OPTIONS"
   eval run_block_compile_pg ${HOST_OPTIONS}

} else {
   if {[file exists [which $TCL_COMPILE_PG_FILE]]} {
     rm_source -file $TCL_COMPILE_PG_FILE
   } else {
     puts "RM-warning: No Power Networks Implemented as TCL_COMPILE_PG_FILE does not exist."
   }
   if {[file exists [which $TCL_PG_PUSHDOWN_FILE]]} {
      puts "RM-info : Souring TCL_PG_PUSHDOWN_FILE ($TCL_PG_PUSHDOWN_FILE)"
      rm_source -file $TCL_PG_PUSHDOWN_FILE
   } else {
      puts "RM-info : Automatic pushdown of PG geometries enabled. Pushing down into all blocks"
      set pg [get_nets * -filter "net_type == power || net_type == ground" -quiet]

      if {[sizeof_collection $pg] > 0} {
         set_push_down_object_options \
            -object_type           {pg_routing} \
            -top_action            remove \
            -block_action          {copy create_pin_shape}
         push_down_objects $pg
      } else {
        puts "RM-warning: No PG objects found, skipping PG push-down."
      }
   }
}

########################################################################
## Apply post-pns-file
########################################################################
rm_source -file $TCL_POST_PNS_FILE -optional -print "TCL_POST_PNS_FILE"

########################################################################
##  Check PG-DRC/Connectivity and MV design
########################################################################
## Check phyiscal connectivity
check_pg_connectivity -check_std_cell_pins none

## Create error report for PG ignoring std cells because they are not legalized
check_pg_drc -ignore_std_cells

## check_mv_design -erc_mode and -power_connectivity
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_mv_design.erc_mode {check_mv_design -erc_mode}
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_mv_design.power_connectivity {check_mv_design -power_connectivity}

####################################
## Post-create_power customizations
####################################
rm_source -file $TCL_USER_CREATE_POWER_POST_SCRIPT -optional -print "TCL_USER_CREATE_POWER_POST_SCRIPT"

save_lib -all

redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/run_end.rpt {run_end}

write_qor_data -report_list "performance host_machine report_app_options" -label $REPORT_PREFIX -output $WRITE_QOR_DATA_DIR

report_msg -summary
print_message_info -ids * -summary
echo [date] > create_power

exit 
