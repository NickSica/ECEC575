##########################################################################################
# Tool: IC Compiler II 
# Script: timing_budget.tcl
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################

source ./rm_utilities/procs_global.tcl 
source ./rm_utilities/procs_icc2.tcl 
rm_source -file ./rm_setup/design_setup.tcl
rm_source -file ./rm_setup/icc2_dp_setup.tcl
rm_source -file ./rm_setup/header_icc2_dp.tcl
rm_source -file sidefile_setup.tcl -after_file technology_override.tcl
set PREVIOUS_STEP $PLACE_PINS_BLOCK_NAME 
set CURRENT_STEP  $BUDGETING_BLOCK_NAME

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

## Get block names for references defined by DP_BLOCK_REFS.  This list is used in some hier DP commands.
set child_blocks [ list ]
foreach block $DP_BLOCK_REFS {lappend child_blocks [get_object_name [get_blocks -hier -filter block_name==$block]]}
set all_blocks "$child_blocks [get_object_name [current_block]]"

## Non-persistent settings to be applied in each step (optional)
rm_source -file $TCL_USER_NON_PERSISTENT_SCRIPT -optional -print "TCL_USER_NON_PERSISTENT_SCRIPT"

####################################
## Pre-budgeting customizations
####################################
rm_source -file $TCL_USER_BUDGETING_PRE_SCRIPT -optional -print "TCL_USER_BUDGETING_PRE_SCRIPT"

rm_source -file $TCL_TIMING_ESTIMATION_SETUP_FILE -optional -print "TCL_TIMING_ESTIMATION_SETUP_FILE"

################################################################################
## Create estimate_timing abstracts for blocks and run timing estimation.
################################################################################
if {$DP_BLOCK_REFS != ""} {
   ## SDC loading is delayed until a timing driven operation when running high-capacity mode.  The UPF was previously loaded.
   if {$DP_HIGH_CAPACITY_MODE == "true"} {
      puts "RM-info : Running load_block_constraints -type SDC -blocks \"$all_blocks\" $HOST_OPTIONS "
      eval load_block_constraints -type SDC -blocks [get_blocks ${all_blocks}] ${HOST_OPTIONS}
   }
   if {$BOTTOM_BLOCK_VIEW == "abstract"} {
      ####################################
      ## Check Design: Pre-Pre Timing
      ####################################
      if {$CHECK_DESIGN} { 
         redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_design.pre_create_timing_abstract \
          {check_design -ems_database check_design.pre_create_timing_abstract.ems -checks dp_pre_create_timing_abstract}
      }
      ## Create abstracts to support estimate_timing.  
      puts "RM-info : Running create_abstract -estimate_timing -timing_level $BLOCK_ABSTRACT_TIMING_LEVEL -blocks \"$child_blocks\" $HOST_OPTIONS"
      eval create_abstract -estimate_timing -timing_level $BLOCK_ABSTRACT_TIMING_LEVEL -blocks [get_blocks $child_blocks] $HOST_OPTIONS


   }
}

####################################
# Check Design: Pre-Timing Estimation
####################################
if {$CHECK_DESIGN} { 
   redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_design.pre_timing_estimation \
    {check_design -ems_database check_design.pre_timing_estimation.ems -checks dp_pre_timing_estimation}
}
      
## Run timing estimation on the entire top design to ensure quality 
eval estimate_timing $HOST_OPTIONS

###############################################################################
# Generate Post Timing Estimation Reports 
###############################################################################
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/${DESIGN_NAME}.post_estimated_timing.rpt     {report_timing -corner estimated_corner -mode [all_modes]}
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/${DESIGN_NAME}.post_estimated_timing.qor     {report_qor    -corner estimated_corner}
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/${DESIGN_NAME}.post_estimated_timing.qor.sum {report_qor    -summary}

## Ensure that timing derates were loaded during CTP for valid report.
if {[file exists [which $CTP_TIMING_DERATE_SCRIPT]]} {
  redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/${DESIGN_NAME}.post_estimated_timing_clock_trunk.qor {report_clock_trunk_qor -clock $CTP_CLOCKS}
}

################################################################################
# Load budgeting user setup file if defined
################################################################################
rm_source -file $TCL_BUDGETING_SETUP_FILE -optional -print "TCL_BUDGETING_SETUP_FILE"

####################################
# Check Design: Pre-Budgets
####################################
if {$CHECK_DESIGN} { 
   redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_design.pre_budgeting \
    {check_design -ems_database check_design.pre_budgeting.ems -checks dp_pre_budgeting}
}

################################################################################
# Budgeting
################################################################################
# Derive block instances from block references if not already defined.
set DP_BLOCK_INSTS ""
foreach ref "$DP_BLOCK_REFS" {
   set DP_BLOCK_INSTS "$DP_BLOCK_INSTS [get_object_name [get_cells -hier -filter ref_name==$ref]]"
}

## Setup blocks to be budgeted.
set_budget_options -add_blocks $DP_BLOCK_INSTS

## Compute the budgets.
## - Note that the default COMPUTE_BUDGET_CONSTRAINTS_OPTIONS setting defines "-latency_target actual".  
##   If clock_trunk_planning was run you will need to edit to "estimated".
set compute_budget_constraints_cmd "compute_budget_constraints $COMPUTE_BUDGET_CONSTRAINTS_OPTIONS"
puts "RM-info : Running: $compute_budget_constraints_cmd"
eval $compute_budget_constraints_cmd

################################################################################
# Load boundary budgeting constraint file if defined
# - Manual fine tuning of budgets.
################################################################################
rm_source -file $TCL_BOUNDARY_BUDGETING_CONSTRAINTS_FILE -optional -print "TCL_BOUNDARY_BUDGETING_CONSTRAINTS_FILE"

###############################################################################
# Write Out Budgets
################################################################################
if {[file exists ./block_budgets]} {
  file rename ./block_budgets ./block_budgets_bak_[exec date +%y%m%d_%H%M%S] ;
}

write_budgets -output block_budgets -force -nosplit

redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_budget.latency {report_budget -latency} ;
report_budget -html_dir ${REPORTS_DIR}/${REPORT_PREFIX}/${DESIGN_NAME}.budget.html ;

################################################################################
# Write Out Budget Constraints
################################################################################
write_script -include budget -force -output ${REPORTS_DIR}/${REPORT_PREFIX}/${DESIGN_NAME}.budget_constraints

################################################################################
# Load Block Budget Constraints
################################################################################

## Save required prior to run_block_script.
save_lib -all

set load_block_budgets_script "./rm_icc2_dp_hier_scripts/load_block_budgets.tcl" 
## Added the -force due to unsaved bottom-up library edits.  Fix to Jira 33522588 should address.
eval run_block_script -script $load_block_budgets_script \
     -blocks [list "${DP_BLOCK_REFS}"] \
     -work_dir ./work_dir/load_block_budgets ${HOST_OPTIONS} \
     -force

## Re-create abstracts as they become out of sync after budget loading.
## - Abstracts can be used to support analysis at the end of DP.
if {$BOTTOM_BLOCK_VIEW == "abstract"} {
   puts "RM-info : Running create_abstract -timing_level $BLOCK_ABSTRACT_TIMING_LEVEL -blocks \"$child_blocks\" $HOST_OPTIONS"
   eval create_abstract -timing_level $BLOCK_ABSTRACT_TIMING_LEVEL -blocks [get_blocks $child_blocks] $HOST_OPTIONS
}

####################################
## Post-timing_budgeting User Customizations
####################################
rm_source -file $TCL_USER_BUDGETING_POST_SCRIPT -optional -print "TCL_USER_BUDGETING_POST_SCRIPT"

save_lib -all

redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/run_end.rpt {run_end}

write_qor_data -report_list "performance host_machine report_app_options" -label $REPORT_PREFIX -output $WRITE_QOR_DATA_DIR

report_msg -summary
print_message_info -ids * -summary
echo [date] > timing_budget

exit 

