##########################################################################################
# Tool: IC Compiler II 
# Script: clock_trunk_planning.tcl
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
set CURRENT_STEP  $CLOCK_TRUNK_PLANNING_BLOCK_NAME

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
rm_open_design -from_lib   ${WORK_DIR}/${DESIGN_LIBRARY} \
               -block_name $DESIGN_NAME \
               -from_label $PREVIOUS_STEP \
               -to_label   $CURRENT_STEP \
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

################################################################################
## Pre-clock trunk planning customizations
################################################################################
rm_source -file $TCL_USER_CLOCK_TRUNK_PLANNING_PRE_SCRIPT -optional -print "TCL_USER_CLOCK_TRUNK_PLANNING_PRE_SCRIPT"

####################################
## Check Design: Pre-Clock Trunk Planning
####################################
if {$CHECK_DESIGN} { 
   redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_design.pre_clock_trunk_planning \
    {check_design -ems_database check_design.pre_clock_trunk_planning.ems -checks dp_pre_clock_trunk_planning}
}


################################################################################
## Run BLOCK Level CTP 
################################################################################
set CTP_BLOCKS [get_blocks -hierarchical $DP_BLOCK_REFS] ;
set_editability -blocks $CTP_BLOCKS -value true ;

if {$CTP_CLOCKS == ""} {
  set clocks_plan [get_attribute [get_clocks] name] ;
} else {
  set clocks_plan $CTP_CLOCKS
}

if {$DP_BLOCK_REFS != ""} {
   #############################################################################
   # Specify TCL_CTS_CONSTRAINTS_MAP_FILE 
   #############################################################################
   if {[file exists $TCL_CTS_CONSTRAINTS_MAP_FILE]} {
     set_constraint_mapping_file $TCL_CTS_CONSTRAINTS_MAP_FILE
   }

   ## Following app options are used to prevent pre-routes check during running block level CTP scripts. 
   ## This will create Error due to some cells not having legal location due to pnet check.
   set_app_options -name place.legalize.enable_prerouted_net_check -value false -as_user_default
   set_app_options -name opt.common.do_physical_checks             -value never -as_user_default

   set_block_to_top_map -auto_clock all

   eval synthesize_clock_trunk_endpoints $HOST_OPTIONS -blocks $CTP_BLOCKS -clocks [list $clocks_plan] ;

}
if {$DP_BB_BLOCK_REFS != ""} {
   #############################################################################
   # Manually set clock trunk endpoints for Black Boxes
   #############################################################################
   # set_clock_trunk_endpoints [options]
}

redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_clock_trunk_endpoints {report_clock_trunk_endpoints} ;


################################################################################
# Run TOP Level CTP 
################################################################################

##################################################
# Setting the type of the top level CTP flow
#   Specify the type of CTP flow using CTP_FLOW in icc2_dp_setup.tcl 
#   pushdown or THO_CTP 
##################################################
if {$CTP_FLOW eq "PUSHDOWN"} {
  set_app_options -name plan.clock_trunk.flow_control -value push_down
} elseif {$CTP_FLOW eq "THO"} {
  set_app_options -name plan.clock_trunk.flow_control -value optimize_subblocks
  set_app_options -name plan.clock_trunk.enable_new_flow -value true
  set_app_options -name top_level.optimize_subblocks -value all
  set_app_options -name cts.common.enable_subblock_optimization -value true
}

##################################################
#Specify the prefix for top level CTP added buffers/inverters 
##################################################
set_app_options -name cts.common.user_instance_name_prefix -value ICC2_TOP_CTP_

set_block_to_top_map -auto_clock all
###################################################
# Run top level sanity checker 
###################################################
check_design_for_clock_trunk_planning -clock [get_clocks $clocks_plan]


##################################################
#  Pushdown flow 
##################################################
if {$CTP_FLOW eq "PUSHDOWN" } {

  ########################################################################
  ## TIO-CTP-flow
  ## create frame view for all blocks
  ## Please make the necessary edits in block_create_frame.tcl
  ## By default all layers below $MIN_ROUTING_LAYER are blocked
  ########################################################################
  save_lib -all
  set create_frame_script "./rm_icc2_dp_hier_scripts/block_create_frame.tcl" 
  run_block_script -script $create_frame_script \
                   -blocks [list [concat $DP_BLOCK_REFS $DP_BB_BLOCK_REFS]] \
                   -work_dir ./work_dir/CTP $HOST_OPTIONS ;

  synthesize_clock_trunks -clock [list $clocks_plan] ;
  ##########################################################################
  ## Place clock pins with trunk physical guidance 
  ###########################################################################
  push_down_clock_trunks -clock [list $clocks_plan] ;

} elseif {$CTP_FLOW eq "THO" } {
  ##################################################
  ## THO-CTP flow 
  ##################################################
  synthesize_clock_trunk_setup_hier_context -init -host_option $HOST_OPTIONS
  synthesize_clock_trunks -clock [get_clocks $clocks_plan] -from pin_constr_generation -to read_pin_constr_and_place_pins
  synthesize_clock_trunk_setup_hier_context -commit -host_option $HOST_OPTIONS
}


# Freeze clock pin placement if required
# set_locked_objects [get_clock_tree_pins -scan_all_hierarchical_pins -filter is_on_physical_boundary]

###############################################################################
## Clock trunk QoR report 
## Load timing derates for all the corners before running this command
## This will report the CRP and OCV value estimated by CTP. 
## Timing numbers reported here is not valid because the signal pins are not placed and estimate_timing is not run.
## To check the timing numbers along with CTP estimated OCV and CRP numbers, run report_clock_trunk_qor after timing_estimation step. 
###############################################################################
rm_source -optional -file $CTP_TIMING_DERATE_SCRIPT -print CTP_TIMING_DERATE_SCRIPT ;

redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_clock_trunk_qor {report_clock_trunk_qor -clock $clocks_plan} ;

################################################################################
## Post-clock trunk planning User Customizations
################################################################################
rm_source -file $TCL_USER_CLOCK_TRUNK_PLANNING_POST_SCRIPT -optional -print "TCL_USER_CLOCK_TRUNK_PLANNING_POST_SCRIPT"

save_lib -all

redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/run_end.rpt {run_end}

write_qor_data -report_list "performance host_machine report_app_options" -label $REPORT_PREFIX -output $WRITE_QOR_DATA_DIR

report_msg -summary
print_message_info -ids * -summary
echo [date] > clock_trunk_planning

exit 
