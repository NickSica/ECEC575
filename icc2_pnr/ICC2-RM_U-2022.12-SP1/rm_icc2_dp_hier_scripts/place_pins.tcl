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

set PREVIOUS_STEP $CREATE_POWER_BLOCK_NAME
set CURRENT_STEP  $PLACE_PINS_BLOCK_NAME

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

## Derive block references and instances
set DP_BLOCK_INSTS [list ]
foreach ref "$DP_BLOCK_REFS" {
   set DP_BLOCK_INSTS "$DP_BLOCK_INSTS [get_object_name [get_cells -hier -filter ref_name==$ref]]"
}

## Get block names for references defined by DP_BLOCK_REFS.  This list is used in some hier DP commands.
set child_blocks [ list ]
foreach block $DP_BLOCK_REFS {lappend child_blocks [get_object_name [get_blocks -hier -filter block_name==$block]]}
set all_blocks "$child_blocks [get_object_name [current_block]]"

## Non-persistent settings to be applied in each step (optional)
rm_source -file $TCL_USER_NON_PERSISTENT_SCRIPT -optional -print "TCL_USER_NON_PERSISTENT_SCRIPT"

####################################
## Pre-place_pins User Customizations
####################################
rm_source -file $TCL_USER_PLACE_PINS_PRE_SCRIPT -optional -print "TCL_USER_PLACE_PINS_PRE_SCRIPT"

########################################################################
## Set pin constraints if not PLACEMENT_PIN_CONSTRAINT_AWARE.
##   TCL_PIN_CONSTRAINT_FILE   : This file contains all the TCL set_*_pin_constraints.
##   CUSTOM_PIN_CONSTRAINT_FILE: This file contains the pin constraints in pin constraint format, not TCL.
##   not TCL.
## Note: Feedthroughs are not enabled by default; Enable feedthroughs either through the Tcl pin constraints command or through the pin constraints file
################################################################################
if {!$PLACEMENT_PIN_CONSTRAINT_AWARE} {
   rm_source -optional -file $TCL_PIN_CONSTRAINT_FILE -print TCL_PIN_CONSTRAINT_FILE ;

   if {[file exists [which $CUSTOM_PIN_CONSTRAINT_FILE]]} {
     read_pin_constraints -file_name $CUSTOM_PIN_CONSTRAINT_FILE ;
   }
}

################################################################################
## If incremental pin constraints exist and incremental mode is enabled, load them
################################################################################
if {$USE_INCREMENTAL_DATA && [file exists $OUTPUTS_DIR/preferred_pin_locations.tcl]} {
   read_pin_constraints -file_name $OUTPUTS_DIR/preferred_pin_locations.tcl
}

################################################################################
# Enable timing driven pin placement
################################################################################
if {$TIMING_PIN_PLACEMENT} {
   rm_source -file $TCL_TIMING_ESTIMATION_SETUP_FILE -optional -print "TCL_TIMING_ESTIMATION_SETUP_FILE"
  
   if {$DP_BB_BLOCK_REFS != ""} {
      if {$BOTTOM_BLOCK_VIEW == "abstract"} {
         ## Create timing estimation abstracts for non black boxes at lowest hierachy levels.
         set non_bb_blocks $DP_BLOCK_REFS
         foreach bb $DP_BB_BLOCK_REFS {
            set idx [lsearch -exact $non_bb_blocks $bb]
            set non_bb_blocks [lreplace $non_bb_blocks $idx $idx]
         }
         set non_bb_insts ""
         foreach ref $non_bb_blocks {
            set non_bb_insts "$non_bb_insts [get_object_name [get_cells -hier -filter ref_name==$ref]]"
         }
         set non_bb_for_abs [lsort -unique [get_attribute -objects [filter_collection [get_cells $non_bb_insts] "!has_child_physical_hierarchy"] -name ref_name]]
      
         set CMD_OPTIONS "-estimate_timing -timing_level $BLOCK_ABSTRACT_TIMING_LEVEL -blocks [list $non_bb_for_abs] $HOST_OPTIONS"
         puts "RM-info : Running create_abstract $CMD_OPTIONS"
         eval create_abstract $CMD_OPTIONS
      }
      
      ## Load constraints and create abstracts for black boxes.
      set CMD_OPTIONS "-blocks [list $DP_BB_BLOCK_REFS] -type SDC $HOST_OPTIONS"
      puts "RM-info : Running load_block_constraints $CMD_OPTIONS"
      eval load_block_constraints $CMD_OPTIONS
      
      set CMD_OPTIONS "-timing_level $BLOCK_ABSTRACT_TIMING_LEVEL -blocks [list $DP_BB_BLOCK_REFS] $HOST_OPTIONS"
      puts "RM-info : Running create_abstract $CMD_OPTIONS"
      eval create_abstract $CMD_OPTIONS
      
   } elseif {$DP_BLOCK_REFS != ""} {
      ## SDC loading is delayed until a timing driven operation when running high-capacity mode.  The UPF was previously loaded.
      if {$DP_HIGH_CAPACITY_MODE == "true"} {
         puts "RM-info : Running load_block_constraints -type SDC -blocks \"$all_blocks\" $HOST_OPTIONS"
         eval load_block_constraints -type SDC -blocks [get_blocks ${all_blocks}] ${HOST_OPTIONS}
      }
      if {$BOTTOM_BLOCK_VIEW == "abstract"} {
         puts "RM-info : Running create_abstract -estimate_timing -timing_level $BLOCK_ABSTRACT_TIMING_LEVEL -blocks \"$child_blocks\" $HOST_OPTIONS"
         eval create_abstract -estimate_timing -timing_level $BLOCK_ABSTRACT_TIMING_LEVEL -blocks [get_blocks $child_blocks] $HOST_OPTIONS
      }
   }
   ## Enable timing driven global routing
   set_app_options -as_user_default -list {route.global.timing_driven true}
}

####################################
## Check Design: Pre-Pin Placement
####################################
if {$CHECK_DESIGN} { 
   redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_design.pre_pin_placement \
    {check_design -ems_database check_design.pre_pin_placement.ems -checks dp_pre_pin_placement}
}

if [sizeof_collection [get_cells -quiet -hierarchical -filter "is_multiply_instantiated_block"]] { 
   check_mib_alignment
}

####################################
## Place top-level pins
####################################
## Perform pin placement when both conditions below are met:
## 1) Pin placement is enabled for this task 
## 2) User wants to run even though pin placement was detected in input DEF/TCL
if {!([get_attribute [current_block] top_pin_placement] == "1") || $PLACE_PINS_SELF != "none"} {
  if {($PLACE_PINS_SELF == "place_pins")} {
    place_pins -self
  } elseif {($PLACE_PINS_SELF == "both")} {
    if {[get_attribute [current_block] top_pin_placement_export] != ""} {
      rm_source -file [get_attribute [current_block] top_pin_placement_export]
      place_pins -self -legalize
    } else {
      puts "RM-warning : Running full top-level pin placement as no pin export file found."
      place_pins -self
    }
  }
  ## Optionally fix place ports to prevent movement by downstream commands (i.e. compile_fusion).
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
}

####################################
## Place block pins
####################################
# Note1: 
# If you need to re-run place_pins, it is recommended that you first remove previously created 
# feedthroughs (i.e. run remove_feedthroughs before re-running place_pins).
# If you do not want to disrupt your current pin placement, you can either set the physical status 
# of your block pins to fixed using the set_attribute command like so:
#    icc2_shell> set_attribute [get_terminals -of_objects [get_pins block/A]] physical_status fixed)
# Or you can assign pins for selected nets using place_pins -nets ...; 
# When the "-nets ..." option is used, the place_pins command will place pins only for the specified nets. 
# See the remove_feedthroughs and place_pins man pages for details.

# Note2: Congestion aware block pin assignment
# Optional pin assigment sequence when there is serious congestion around block boundary.
# route_global -floorplan true -virtual_flat top_and_interface_routing_only ;
# place_pin -use_existing_routing ;

## Block pin assignment.
place_pins

## Optionally fix place block pins to prevent movement by downstream commands (i.e. compile_fusion).
## - Also check and report unplaced block pins.
if {$FIX_PORT_PLACEMENT} {
  foreach inst ${DP_BLOCK_INSTS} {
    set_working_design -push $inst    
    set_app_options -name compile.auto_floorplan.enable -value false
    set port_list [get_ports -quiet -filter "port_type!=power && port_type!=ground && physical_status==placed"]
    if {[sizeof_collection $port_list] > 0} {
      set_attribute $port_list physical_status "fixed"
    }
    ## Check for unplaced block pins.
    set unplaced_ports [get_ports -quiet -filter "port_type!=power && port_type!=ground && physical_status==unplaced"]
    foreach_in_collection port $unplaced_ports {
      set port_name [get_object_name $port]
      puts "RM-warning: Port \"$port_name\" is unplaced."
    }
    set_working_design -pop -level 0
  }
}

################################################################################
# Dump pin constraints for re-use later in an incremental build
################################################################################
write_pin_constraints \
   -file_name $OUTPUTS_DIR/preferred_pin_locations.tcl \
   -physical_pin_constraint {side | offset | layer} \
   -from_existing_pins

################################################################################
## Verfiy Pin assignment results
## If errors are found they will be stored in an .err file and can be browsed
## with the integrated error browser.
################################################################################
switch $FLOORPLAN_STYLE {
   channel {redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_pin_placement.rpt {check_pin_placement -alignment true -pre_route true \
            -sides true -stacking true -pin_spacing true -layers true}}
   abutted {redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_pin_placement.rpt {check_pin_placement -pre_route true -sides true \
            -stacking true -pin_spacing true -layers true -single_pin all -synthesized_pins true}}
}

################################################################################
## Generate a pin placement report to assess pin placement
################################################################################
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_feedthrough.rpt {report_feedthroughs -reporting_style net_based }
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_pin_placement.rpt {report_pin_placement}

## check_mv_design -erc_mode and -power_connectivity
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_mv_design.erc_mode {check_mv_design -erc_mode}
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_mv_design.power_connectivity {check_mv_design -power_connectivity}

if {($PLACE_PINS_SELF == "place_pins" || $PLACE_PINS_SELF == "both") && (!([get_attribute [current_block] top_pin_placement] == "1") || $PLACE_PINS_SELF != "none")} {
   # Write top-level port constraint file based on actual port locations.
   write_pin_constraints -self \
      -file_name $OUTPUTS_DIR/preferred_port_locations.tcl \
      -physical_pin_constraint {side | offset | layer} \
      -from_existing_pins

   # Verify Top-level Port Placement Results
   redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_pin_placement {check_pin_placement -self -pre_route true -pin_spacing true -sides true -layers true -stacking true}

   # Generate Top-level Port Placement Report
   redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_pin_placement {report_pin_placement -self}
}
  
## Post pin placement node specific file.
## - Typical uses are periphery routing blockages, port diode insertion, etc.
rm_source -file $SIDEFILE_PLACE_PINS -optional -print "SIDEFILE_PLACE_PINS"

####################################
## Post-place_pins customizations
####################################
rm_source -file $TCL_USER_PLACE_PINS_POST_SCRIPT -optional -print "TCL_USER_PLACE_PINS_POST_SCRIPT"

save_lib -all

redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/run_end.rpt {run_end}

write_qor_data -report_list "performance host_machine report_app_options" -label $REPORT_PREFIX -output $WRITE_QOR_DATA_DIR

report_msg -summary
print_message_info -ids * -summary
echo [date] > place_pins

exit 

