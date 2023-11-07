##########################################################################################
# Tool: IC Compiler II 
# Script: placement.tcl
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################

source ./rm_utilities/procs_global.tcl 
source ./rm_utilities/procs_icc2.tcl 
rm_source -file ./rm_setup/design_setup.tcl
rm_source -file ./rm_setup/icc2_dp_setup.tcl
rm_source -file ./rm_setup/header_icc2_dp.tcl
rm_source -file sidefile_setup.tcl -after_file technology_override.tcl

set PREVIOUS_STEP $SHAPING_BLOCK_NAME
set CURRENT_STEP  $PLACEMENT_BLOCK_NAME

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
## Open design
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
## Pre-placement customizations
####################################
rm_source -file $TCL_USER_PLACEMENT_PRE_SCRIPT -optional -print "TCL_USER_PLACEMENT_PRE_SCRIPT"

####################################
# Push rows and tracks into blocks if no site_arrays exist
####################################
if {[llength [get_site_arrays -quiet]] == 0} {
   puts "RM-info : pushing down site_rows into all blocks"
   push_down_objects [get_site_rows]
}

rm_source -file $TCL_AUTO_PLACEMENT_CONSTRAINTS_FILE -optional -print "TCL_AUTO_PLACEMENT_CONSTRAINTS_FILE"

####################################
## Set placement constraints
####################################
if {[sizeof_collection [get_cells -hierarchical -filter "is_hard_macro==true" -quiet]]} {
   redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_macro_constraints.rpt \
    {report_macro_constraints -allowed_orientations -preferred_location -alignment_grid -align_pins_to_tracks}
}

# If pin-constraint aware placement is used then sourcing all pin constraint files before placement
if {$PLACEMENT_PIN_CONSTRAINT_AWARE == "true"} {
   puts "RM-info : pin aware pin placement enabled (PLACEMENT_PIN_CONSTRAINT_AWARE == $PLACEMENT_PIN_CONSTRAINT_AWARE)"
   rm_source -file $TCL_PIN_CONSTRAINT_FILE -optional -print "TCL_PIN_CONSTRAINT_FILE"
   if {[file exists [which $CUSTOM_PIN_CONSTRAINT_FILE]]} {
      puts "RM-info : sourcing CUSTOM_PIN_CONSTRAINT_FILE $CUSTOM_PIN_CONSTRAINT_FILE"
      read_pin_constraints -file_name $CUSTOM_PIN_CONSTRAINT_FILE
   }
}

# To support incremental macro placement constraints, enable it and write out the preferred locations file
if {$USE_INCREMENTAL_DATA} {
   rm_source -file $OUTPUTS_DIR/preferred_macro_locations.tcl
}

####################################
# Check Design: Pre-Placement
####################################
if {$CHECK_DESIGN} { 
   redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_design.pre_macro_placement \
    {check_design -ems_database check_design.pre_macro_placement.ems -checks dp_pre_macro_placement}
}

####################################
# Place macro and stdcell with floorplan mode.
####################################

set CMD_OPTIONS "-floorplan $HOST_OPTIONS"

if {[info exist CONGESTION_DRIVEN_PLACEMENT] && $CONGESTION_DRIVEN_PLACEMENT != ""} {
   set_app_option -name plan.place.congestion_driven_mode -value $CONGESTION_DRIVEN_PLACEMENT
   set CMD_OPTIONS "$CMD_OPTIONS -congestion"
}

if {[info exist TIMING_DRIVEN_PLACEMENT] && $TIMING_DRIVEN_PLACEMENT != ""} {
   if {$DP_BLOCK_REFS != ""} {
      ## SDC loading is delayed until a timing driven operation when running high-capacity mode.  The UPF was previously loaded.
      if {$DP_HIGH_CAPACITY_MODE == "true"} {
         puts "RM-info : Running load_block_constraints -type SDC -blocks \"$all_blocks\" $HOST_OPTIONS"
         eval load_block_constraints -type SDC -blocks [get_blocks ${all_blocks}] ${HOST_OPTIONS}
      }
   }
   set_app_options -name plan.place.timing_driven_mode -value $TIMING_DRIVEN_PLACEMENT
   set CMD_OPTIONS "$CMD_OPTIONS -timing_driven"
   puts "RM-info : Running timing driven placement for $TIMING_DRIVEN_PLACEMENT."
}

if {$PLACEMENT_STYLE=="on_edge"} {
  ##### On-Edge Macro Placement
  set CMD_OPTIONS "-floorplan $HOST_OPTIONS"
  puts "RM-info: Running create_placement $CMD_OPTIONS"
  eval create_placement $CMD_OPTIONS

} elseif {$PLACEMENT_STYLE=="freeform" || $PLACEMENT_STYLE=="hybrid"} {
  ##### Freeform/Hybrid Macro Placement
  set fp_status [rm_detect_fp_valid_operations -operations {block_pin_placement}] ; 
  
  if {$FLOORPLAN_STYLE != "abutted"} {
    puts "RM-info: Running preliminary top level placement." ;
    set_editability -value false -blocks [get_blocks $child_blocks] ;
    eval create_placement -floorplan ;
    set_editability -value true -blocks [get_blocks $child_blocks]
  }
  if {!$PLACEMENT_PIN_CONSTRAINT_AWARE} {
    rm_source -optional -file $TCL_PIN_CONSTRAINT_FILE -print TCL_PIN_CONSTRAINT_FILE ;
    if {[file exists [which $CUSTOM_PIN_CONSTRAINT_FILE]]} {
      read_pin_constraints -file_name $CUSTOM_PIN_CONSTRAINT_FILE ;
    }
  }
  puts "RM-info: Running preliminary block pin assignment." ;
  eval place_pins ;

  save_lib -all ;

  puts "RM-info: Running block level $PLACEMENT_STYLE  macro placement." ;
  set place_block_script "./rm_icc2_dp_hier_scripts/place_block.tcl" 
  eval run_block_script -script ${place_block_script} \
                        -blocks [list "${DP_BLOCK_REFS}"] \
                        -work_dir ./work_dir/place_block ${HOST_OPTIONS}
  if {$FLOORPLAN_STYLE != "abutted"} {
    set_app_options -name {plan.macro.style} -value $PLACEMENT_STYLE
    set_macro_constraints -style $MACRO_CONSTRAINT_STYLE [get_cells -hierarchical -filter "is_hard_macro==true"]
    set_editability -value false -blocks [get_blocks $child_blocks] ;

    puts "RM-info: Running top level freeform macro placement." ;
    eval create_placement -floorplan ;

    set_editability -value true -blocks [get_blocks $child_blocks] ;
  }

  if { $fp_status == "block_pin_placement" } {
    puts "RM-info: Removing preliminary assigned block pins" ;
    set terms_removing [get_terminals -of_objects [get_cells $DP_BLOCK_INSTS] -filter "physical_status==unrestricted"]
    remove_terminals $terms_removing
  }
} else {
  puts "RM-error: The value of PLACEMENT_STYLE = $PLACEMENT_STYLE is unsupported."
}

###############################################
## Floorplan checking and fixing
## - Floorplan rules must be pre-defined in the library. 
## - This can be done via TCL_FLOORPLAN_RULE_SCRIPT, sidefiles, etc.
###############################################
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
## Generate reports
####################################
set all_macros [get_cells -hierarchical -filter "is_hard_macro==true" -quiet]

redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_placement.rpt \
   {report_placement -physical_hierarchy_violations all -wirelength all -hard_macro_overlap -verbose high}

## Write out macro preferred locations based on latest placement
## If this file exists on subsequent runs it will be used to drive the macro placement
if {[sizeof_collection $all_macros]} {
   file delete -force $OUTPUTS_DIR/preferred_macro_locations.tcl
   derive_preferred_macro_locations $all_macros -file $OUTPUTS_DIR/preferred_macro_locations.tcl
}

####################################
## Fix all shaped blocks and macros
####################################
set_attribute -quiet $all_macros physical_status fixed
set_attribute -quiet [get_cells $DP_BLOCK_INSTS] physical_status fixed

####################################
## Post-placement customizations
####################################
rm_source -file $TCL_USER_PLACEMENT_POST_SCRIPT -optional -print "TCL_USER_PLACEMENT_POST_SCRIPT"

save_lib -all

redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/run_end.rpt {run_end}

write_qor_data -report_list "performance host_machine report_app_options" -label $REPORT_PREFIX -output $WRITE_QOR_DATA_DIR

report_msg -summary
print_message_info -ids * -summary
echo [date] > placement

exit 
