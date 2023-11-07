##########################################################################################
# Script: icc2_dp_setup.tcl 
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################

##########################################################################################
# Flow setup applicable to both flat and hierarchical DP flows
##########################################################################################

set DP_FLOW         "flat"    ;# hier or flat
set CHECK_DESIGN    "true"    ;# run atomic check_design pre checks prior to DP commands

## Floorplan initialization variables.  See floorplanning sidefile for details.
set INITIALIZE_FLOORPLAN_UTIL        "0.5" ;# (default) configure initialize_floorplan with -core_utilization
set INITIALIZE_FLOORPLAN_WIDTH       ""    ;# configure initialize_floorplan with -side_length; the value specified will be used as width
set INITIALIZE_FLOORPLAN_HEIGHT      ""    ;# configure initialize_floorplan with -side_length; the value specified will be used as height
set INITIALIZE_FLOORPLAN_BOUNDARY    ""    ;# configure initialize_floorplan with -boundary; the value specified will be used as bbox; example : "{x y} {x y} {x y} {x y} ... "
set INITIALIZE_FLOORPLAN_AREA        ""    ;# configure initialize_floorplan with -core_utilization which is derived from the specified area
set INITIALIZE_FLOORPLAN_CORE_OFFSET "1 1" ;# configure initialize_floorplan with -core_offset; the value specified will be used as X/Y offsets
set INITIALIZE_FLOORPLAN_CUSTOM_OPTIONS "" ;# Custom command line options for the initialize_floorplan command.  Use this lieu of the options above for more custom needs.

set TCL_FLOORPLAN_FILE_DP  "" ;# Optional; Input TCL based floorplan file
		              ;# See the examples/mpc.tcl file for a template script.  This provides a basic Minimum Physical Constraint (MPC) file
			      ;# to provide some physical guidance for compile in design planning.
set DEF_FLOORPLAN_FILES_DP "" ;# Optional; Input DEF based floorplan files

set FIX_FLOORPLAN_RULES    "false" ;# Default is "false".  Set to "true" to run fix_floorplan_rules.
				   ;# Rules (i.e. set_floorplan_*_rules) are applied via TCL_FLOORPLAN_RULE_SCRIPT, sidefiles, etc.

set TCL_FIX_FLOORPLAN_RULES_CUSTOM_SCRIPT "" ;# Optional; Specifies a custom floorplan rule fixing script.
                                             ;# By default, the fix_floorplan_rule command in the flow scripts is run when fixing is enabled.

set FIX_PORT_PLACEMENT "true"		     ;# Sets physical_status of placed ports to "fixed" when true (default).
					     ;# Set to false to keep ports with physical_status of "placed".

##########################################################################################
# Flat Design Planning Setup
##########################################################################################

## Variables used during init_design_dp
set TCL_USER_INIT_DESIGN_DP_PRE_SCRIPT ""  ;# An optional Tcl file to be sourced at the very beginning of the task                                         
set TCL_USER_INIT_DESIGN_DP_POST_SCRIPT "" ;# An optional Tcl file to be sourced at the very end of the task                                         

## Variables used during compile_dp
set EARLY_COMPILE_STAGE "initial_map"  ;# Define the compile stage to run through.  The valid options are "initial_map" (default) and "logic_opto".                                         
set COMPILE_DP_ACTIVE_SCENARIO_LIST "" ;# A subset of scenarios to be made active during DP compile step;
				       ;# once set, the list of active scenarios is saved and carried over to subsequent steps;
				       ;# include CTS scenarios if you are enabling CTS related features during compile.
set TCL_USER_COMPILE_DP_PRE_SCRIPT  "" ;# An optional Tcl file to be sourced at the very beginning of the task                                         
set TCL_USER_COMPILE_DP_POST_SCRIPT "" ;# An optional Tcl file to be sourced at the very end of the task                                         

## Variables used during create_floorplan
set CREATE_FLOORPLAN_OPERATIONS                "INITIALIZE_FLOORPLAN PLACE_PINS MACRO_PLACEMENT BOUNDARY_CELL TAP_CELL NODE_SUPPLEMENT" ;# List of operations to run during create_floorplan task.
                                                                                                                         ;# See rm_icc2_dp_flat_scripts/create_floorplan.tcl for all valid options.
set TCL_USER_CREATE_FLOORPLAN_FLAT_PRE_SCRIPT  "" ;# An optional Tcl file to be sourced at the very beginning of the task                                         
set TCL_USER_CREATE_FLOORPLAN_FLAT_POST_SCRIPT "" ;# An optional Tcl file to be sourced at the very end of the task                                         
set TCL_USER_INITIALIZE_FLOORPLAN_PRE_SCRIPT   "" ;# An optional Tcl file to be sourced at the beginning of the operation
set TCL_USER_INITIALIZE_FLOORPLAN_POST_SCRIPT  "" ;# An optional Tcl file to be sourced at the end of the operation
set TCL_USER_PLACE_PINS_INIT_PRE_SCRIPT        "" ;# An optional Tcl file to be sourced at the beginning of the operation
set TCL_USER_PLACE_PINS_INIT_POST_SCRIPT       "" ;# An optional Tcl file to be sourced at the end of the operation
set TCL_USER_MACRO_PLACEMENT_PRE_SCRIPT        "" ;# An optional Tcl file to be sourced at the beginning of the operation
set TCL_USER_MACRO_PLACEMENT_POST_SCRIPT       "" ;# An optional Tcl file to be sourced at the end of the operation
set TCL_PHYSICAL_CONSTRAINTS_FILE              "" ;# An optional Tcl file used for custom floorplanning in the create_floorplan task
set TCL_MV_SETUP_FILE			       "" ;# Optional; a Tcl script placeholder for your MV setup commands,such as create_voltage_area, 
					          ;# placement bound, power switch creation and level shifter insertion, etc;
					          ;# refer to examples/TCL_MV_SETUP_FILE.tcl for sample commands

## Variables used during create_power
set CREATE_POWER_OPERATIONS "PNS STDCELL_PLACEMENT" ;# List of operations to run during create_power task. See rm_icc2_dp_flat_scripts/create_power.tcl for all valid options.
set TCL_USER_CREATE_POWER_FLAT_PRE_SCRIPT  "" ;# An optional Tcl file to be sourced at the very beginning of the task
set TCL_USER_CREATE_POWER_FLAT_POST_SCRIPT "" ;# An optional Tcl file to be sourced at the very end of the task
set TCL_USER_PNS_PRE_SCRIPT                "" ;# An optional Tcl file to be sourced at the beginning of the operation
set TCL_USER_PNS_POST_SCRIPT               "" ;# An optional Tcl file to be sourced at the end of the operation
set TCL_USER_STDCELL_PLACEMENT_PRE_SCRIPT  "" ;# An optional Tcl file to be sourced at the beginning of the operation
set TCL_USER_STDCELL_PLACEMENT_POST_SCRIPT "" ;# An optional Tcl file to be sourced at the end of the operation

## Variables used during place_pins
set PLACE_PINS_OPERATIONS "PLACE_PINS"        ;# List of operations to run during place_pins task. See rm_icc2_dp_flat_scripts/place_pins.tcl for all valid options.
set TCL_USER_PLACE_PINS_FLAT_PRE_SCRIPT ""    ;# An optional Tcl file to be sourced at the beginning of the operation
set TCL_USER_PLACE_PINS_FLAT_POST_SCRIPT ""   ;# An optional Tcl file to be sourced at the end of the operation


##########################################################################################
# Hierarchical Design Planning Setup
##########################################################################################
set DP_HIGH_CAPACITY_MODE "true" ;# Enables outline view for ICC2 DP flow.

set FLOORPLAN_STYLE "channel" ;# The supported design styles are channel (default) and abutted.
                              ;# Used in hier DP scripts for flow configuration.  It is also used
			      ;# in rm_set_dp_flow_strategy to configure application options and settings. 

set DP_STAGE "final" ;# The supported design planning stages are early and final (default).
                     ;# It is used in rm_set_dp_flow_strategy to configure application options and settings.

set DISTRIBUTED "true"  ;# Enables distributed processing for block jobs.  Use in conjunction with BLOCK_DIST_JOB_COMMAND and BLOCK_DIST_JOB_FILE (if needed).

set DP_MAX_CORES_BLOCKS "8" ;# Sets max cores for each distributed process.

set BLOCK_DIST_JOB_COMMAND "" ;# Sets job distribution command for blocks.
                              ;# Example parallel submit command : qsub -pe mt 4 -cwd -P normal -N block_script
                              ;# Use can use BLOCK_DIST_JOB_FILE for block specific settings if there are blocks that need different
			      ;# resources than the standard specified here.

set BLOCK_DIST_JOB_FILE    "" ;# File to set block specific resource requests for distributed jobs
# For example:
#   set_host_options -name large_block   -submit_command "bsub -q huge"
#   set_host_options -name special_block -submit_command "rsh" local_machine
#   set_app_options -block [get_block block4] -list {plan.distributed_run.block_host large_block}
#   set_app_options -block [get_block block5] -list {plan.distributed_run.block_host large_block}
#   set_app_options -block [get_block block2] -list {plan.distributed_run.block_host special_block}
#  
#   All the jobs associated with blocks that do not have the plan.distributed_run.block_host app option specified
#   will run using the block_script host option. The jobs for blocks block4 and block5 will use the large_block 
#   host option. The job form  block2  will  use  the  special_block host option.

##########################################################################################
# If the design is run with MIBs then change the block list appropriately
##########################################################################################
set DP_BLOCK_REFS                     [list] ;# design names for each physical block (including black boxes) in the design;
                                             ;# this includes bottom and mid level blocks in a Multiple Physical Hierarchy (MPH) design
set DP_INTERMEDIATE_LEVEL_BLOCK_REFS  [list] ;# design reference names for mid level blocks only
set DP_BB_BLOCK_REFS                  [list] ;# Black Box reference names 

set BOTTOM_BLOCK_VIEW             "abstract" ;# Support abstract or design view for bottom blocks
                                             ;# in the hier flow
set INTERMEDIATE_BLOCK_VIEW       "abstract" ;# Support abstract or design view for intermediate blocks

set BLOCK_ABSTRACT_LABEL_FOR_BOTTOM_UP_BLOCKS "" ;# Label name to use for blocks built bottom-up and in reference library list.
                                                 ;# This should be left empty for designs where all blocks are built top-down.

set BLOCK_ABSTRACT_TIMING_LEVEL	"compact" ;# Specify timing detail for create_abstract.  Use either compact (default) or full_interface.
                                          ;# The default of compact has a high level of compression, has significant runtime and memory benefits,
				          ;#  and is highly recommended.  The full_interface option is provided here for corner cases.

# Provide blackbox instanace: target area, BB UPF file, BB Timing file, boundary
#set DP_BB_BLOCK_REFS "leon3s_bb"
#set DP_BB_BLOCKS(leon3s_bb,area)        [list 1346051] ;
#set DP_BB_BLOCKS(leon3s_bb,upf)         [list ${des_dir}/leon3s_bb.upf] ;
#set DP_BB_BLOCKS(leon3s_bb,timing)      [list ${des_dir}/leon3s_bbt.tcl] ;
#set DP_BB_BLOCKS(leon3s_bb,boundary)    { {x1 y1} {x2 y1} {x2 y2} {x1 y2} {x1 y1} } ;
#set DP_BB_SPLIT    "true"


##########################################################################################
# 				CONSTRAINTS / UPF INTENT
##########################################################################################
set TCL_TIMING_RULER_SETUP_FILE       "" ;# file sourced to define parasitic constraints for use with timing ruler 
                                          # before full extraction environment is defined
                                          # Example setup file:
                                          #       set_parasitic_parameters \
                                          #         -early_spec para_WORST \
                                          #         -late_spec para_WORST
set CONSTRAINT_MAPPING_FILE           "" ;# Constraint Mapping File. Default is "split/mapfile"
set DP_VA_MAP_FILE                    "pd_va.map" ;# Map file for VA push-down

set TCL_SPLIT_CONSTRAINTS_SETUP_FILE  "" ;# Specify any constraints/options prior to split_constraints


##########################################################################################
# 				TOP LEVEL FLOORPLAN CREATION (die, pad, RDL) / PLACE IO
##########################################################################################
set TCL_USER_INIT_DP_PRE_SCRIPT       "" ;# An optional Tcl file to be sourced at the very beginning of the task
set TCL_USER_INIT_DP_POST_SCRIPT      "" ;# An optional Tcl file to be sourced at the very end the task

set TCL_USER_COMMIT_BLOCK_PRE_SCRIPT  "" ;# An optional Tcl file to be sourced at the very beginning of the task
set TCL_USER_COMMIT_BLOCK_POST_SCRIPT "" ;# An optional Tcl file to be sourced at the very end of the task

set TCL_USER_INIT_COMPILE_PRE_SCRIPT  "" ;# An optional Tcl file to be sourced at the very beginning of the task
set TCL_USER_INIT_COMPILE_POST_SCRIPT "" ;# An optional Tcl file to be sourced at the very end of the task
set TCL_USER_INIT_COMPILE_SCRIPT      "" ;# An optional Tcl file to use user custom init compile script

set TCL_USER_COMPILE_BLOCK_SCRIPT     "" ;# An optional Tcl file to use user custom block compile script
set DP_1ST_COMPILE_STEP     "logic_opto" ;# Specifies default compile step for init_compile
set DP_2ND_COMPILE_STEP     "logic_opto" ;# Specifies default compile step for top compile

##########################################################################################
# 				TOP LEVEL FLOORPLAN CREATION (die, pad, RDL) / PLACE IO
##########################################################################################
set TCL_USER_EXPAND_OUTLINE_PRE_SCRIPT     "" ;# An optional Tcl file to be sourced at the very beginning of the task
set TCL_USER_EXPAND_OUTLINE_POST_SCRIPT    "" ;# An optional Tcl file to be sourced at the very end of the task
set TCL_USER_PLACE_IO_PRE_SCRIPT      "" ;# An optional Tcl file to be sourced at the very beginning of the task
set TCL_USER_PLACE_IO_POST_SCRIPT     "" ;# An optional Tcl file to be sourced at the very end of the task
set TCL_PAD_CONSTRAINTS_FILE               "" ;# file sourced to create everything needed by place_io to complete IO placement
                                              ;# including flip chip bumps, and io constraints
set TCL_RDL_FILE                           "" ;# file sourced to create RDL routes
set PLACE_PINS_SELF                        "both" ;# Enables pin placement at top-level design.  This can be performed in different places in the flow.
                                                  ;# The valid options are: expand_outline, place_pins, none, or both (default).
						  ;# When both is choosen, pins are initially placed in the expand_outline task.  They are reset prior
						  ;# to power insertion in create_power.  The final placement is then performed in the place_pins task.

set TCL_PIN_CONSTRAINT_FILE_SELF           "" ;# Specify tcl pin constraint file
set CUSTOM_PIN_CONSTRAINT_FILE_SELF        "" ;# Specify custom pin constrant file


##########################################################################################
# 				SHAPING
##########################################################################################
set TCL_SHAPING_CONSTRAINTS_FILE      "" ;# Specify any constraints prior to shaping i.e. set_shaping_options
                                          # or specify some block shapes manually, for example:
                                          #    set_block_boundary -cell block1 -boundary {{2.10 2.16} {2.10 273.60} \
                                          #    {262.02 273.60} {262.02 2.16}} -orientation R0
                                          #    set_fixed_objects [get_cells block1]
                                          # Support TCL based shaping constraints
set SHAPING_CONSTRAINTS_FILE          "" ;# Will be included as the -constraint_file option for shape_blocks
set TCL_SHAPING_PNS_STRATEGY_FILE     "" ;# file sourced to create PG strategies for block grid creation
set TCL_MANUAL_SHAPING_FILE           "" ;# File sourced to re-create all block shapes.
                                          # If this file exists, automatic shaping will be by-passed.
                                          # Existing auto or manual block shapes can be written out using the following:
                                          #    write_floorplan -objects <BLOCK_INSTS>
set TCL_USER_SHAPING_PRE_SCRIPT       "" ;# An optional Tcl file to be sourced at the very beginning of the task
set TCL_USER_SHAPING_POST_SCRIPT      "" ;# An optional Tcl file to be sourced at the very end of the task


##########################################################################################
# 				PLACEMENT
##########################################################################################
set TCL_AUTO_PLACEMENT_CONSTRAINTS_FILE    "" ;# Placeholder for any auto macro or stdcell placement constraints & options.
set PLACEMENT_PIN_CONSTRAINT_AWARE    "false" ;# tells create_placement to consider pin constraints during placement
set USE_INCREMENTAL_DATA              "false" ;# Use floorplan constraints that were written out on a previous run
set CONGESTION_DRIVEN_PLACEMENT       "" ;# Set to one of the following: std_cell, macro, or both to enable congestion driven placement
set TIMING_DRIVEN_PLACEMENT           "" ;# Set to one of the following: std_cell, macro, or both to enable timing driven placement
set TCL_USER_PLACEMENT_PRE_SCRIPT     "" ;# An optional Tcl file to be sourced at the very beginning of the task
set TCL_USER_PLACEMENT_POST_SCRIPT    "" ;# An optional Tcl file to be sourced at the very end of the task
set PLACEMENT_STYLE	              "on_edge" ;# Set to one of the following: on_edge, freeform, or hybrid.
set MACRO_CONSTRAINT_STYLE            "auto" ; # Set to one of the following: auto, on_edge, or freeform. 


##########################################################################################
#				GLOBAL PLANNING
##########################################################################################
set TCL_GLOBAL_PLANNING_FILE          "" ;#Global planning for bus/critical nets


##########################################################################################
# 				PNS
##########################################################################################
set TCL_PNS_FILE                      "" ;# File sourced to define all power structures. 
                                          # This file will include the following types of PG commands:
                                          #   PG Regions
                                          #   PG Patterns
                                          #   PG Strategies
                                          # Note: The file should not contain compile_pg statements
set PNS_CHARACTERIZE_FLOW             "true"  ;# Perform PG characterization and implementation

set TCL_COMPILE_PG_FILE               "" ;# File should contain all the compile_pg_* commands to create the power networks 
                                          # specified in the strategies in the TCL_PNS_FILE. 

set TCL_PG_PUSHDOWN_FILE              "" ;# Create this file to facilitate manual pushdown and bypass auto pushdown in the flow.
set TCL_POST_PNS_FILE                 "" ;# If it exists, this file will be sourced after PG creation.
set TCL_USER_CREATE_POWER_PRE_SCRIPT  "" ;# An optional Tcl file to be sourced at the very beginning of the task
set TCL_USER_CREATE_POWER_POST_SCRIPT "" ;# An optional Tcl file to be sourced at the very end of the task


##########################################################################################
#                               CLOCK TRUNK PLANNING
##########################################################################################
set CTP_FLOW                               "THO" ;# Specify the type of the CTP flow. The value can be 
                                                 ;#   PUSHDOWN -> pushdown flow 
                                                 ;#   THO      -> THO-CTP fow
                                                 ;#   By default it runs THO-CTP flow.  
set CTP_CLOCKS                                "" ;# Specify the list of clocks for performing clokc trunk planning 
set TCL_CTS_CONSTRAINTS_MAP_FILE              "" ;# map file to specify CTS constraint file for block and top level ;
                                                 ;# An example of map file is provided below: 
                                                 ;#######   mapfile   #############
                                                 ;#   BLK1 CTS_CONSTRAINT cts_cstr.tcl 
                                                 ;#   BLK2 CTS_CONSTRAINT cts_cstr.tcl 
                                                 ;#   TOP  CTS_CONSTRAINT cts_cstr.tcl 
set CTP_TIMING_DERATE_SCRIPT                  "" ;# Specify cript to load the timing derates for  enabling CRP estimation
set TCL_USER_CLOCK_TRUNK_PLANNING_PRE_SCRIPT  "" ;# An optional Tcl file to be sourced at the very beginning of the task
set TCL_USER_CLOCK_TRUNK_PLANNING_POST_SCRIPT "" ;# An optional Tcl file to be sourced at the very end of the task

##########################################################################################
# 				PLACE PINS
##########################################################################################
##Note:Feedthroughs are disabled by default. Enable feedthroughs either through set_*_pin_constraints  Tcl commands or through Pin constraints file
set TCL_PIN_CONSTRAINT_FILE           "" ;# file sourced to apply set_*_pin_constraints to the design
set CUSTOM_PIN_CONSTRAINT_FILE        "" ;# will be loaded via read_pin_constraints -file
                                         ;# used for more complex pin constraints, 
                                         ;# or in constraint replay
set TIMING_PIN_PLACEMENT              "false" ;# Set to true for timing driven pin placement
set TCL_USER_PLACE_PINS_PRE_SCRIPT    "" ;# An optional Tcl file to be sourced at the very beginning of the task
set TCL_USER_PLACE_PINS_POST_SCRIPT   "" ;# An optional Tcl file to be sourced at the very end of the task

##########################################################################################
# 				TOP COMPILE
##########################################################################################
set TCL_USER_TOP_COMPILE_PRE_SCRIPT   "" ;# An optional Tcl file to be sourced at the very beginning of the task
set TCL_USER_TOP_COMPILE_POST_SCRIPT  "" ;# An optional Tcl file to be sourced at the very end of the task
set TCL_USER_TOP_COMPILE_SCRIPT       "" ;# An optional Tcl file to use user custom top compile script

##########################################################################################
# 				TIMING_ESTIMATION /  BUDGETING
##########################################################################################
set TCL_TIMING_ESTIMATION_SETUP_FILE       "" ;# Specify any constraints prior to timing estimation
set TCL_BUDGETING_SETUP_FILE                "" ;# Specify any constraints prior to budgeting
set TCL_BOUNDARY_BUDGETING_CONSTRAINTS_FILE "" ;# An optional user constraints file to override compute_budget_constraints
set COMPUTE_BUDGET_CONSTRAINTS_OPTIONS      "-setup_delay -boundary -latency_targets actual -balance true" ;# Command line options for "compute_budget_constraints".
set TCL_USER_BUDGETING_PRE_SCRIPT           "" ;# An optional Tcl file to be sourced at the very beginning of the task
set TCL_USER_BUDGETING_POST_SCRIPT          "" ;# An optional Tcl file to be sourced at the very end of the task

##########################################################################################
## System Variables (there's no need to change the following)
##########################################################################################
set WORK_DIR ./work ;# Specify work directory
set WORK_DIR_WRITE_DATA ./write_data_dir ;# Specify work directory for write data

set PNR_SCRIPTS_DIR "./rm_icc2_pnr_scripts"		;# Directory of PNR scripts

## Design label and reports variables for the Flat DP flow
set INIT_DESIGN_DP_BLOCK_NAME "init_design_dp"          	;# Label name to be used when saving a block in init_design_dp.tcl
set COMPILE_DP_BLOCK_NAME "compile_dp"                  	;# Label name to be used when saving a block in compile_dp.tcl
set CREATE_FLOORPLAN_FLAT_BLOCK_NAME "create_floorplan" 	;# Label name to be used when saving a block in create_floorplan.tcl
set CREATE_POWER_FLAT_BLOCK_NAME "create_power"         	;# Label name to be used when saving a block in create_power.tcl
set PLACE_PINS_FLAT_BLOCK_NAME "place_pins"             	;# Label name to be used when saving a block in place_pins.tcl

## Design label variables common to both Hierarchical DP flows
set INIT_DP_BLOCK_NAME init_dp ;# Specify init_dp block name
set COMMIT_BLOCK_BLOCK_NAME commit_blocks ;# Specify commit_block block name
set SHAPING_BLOCK_NAME shaping ;# Specify shaping block name
set PLACEMENT_BLOCK_NAME placement ;# Specify placement block name
set CREATE_POWER_BLOCK_NAME create_power ;# Specify create_power block name
set CLOCK_TRUNK_PLANNING_BLOCK_NAME clock_trunk_planning ;# Specify clock trunk planning block name
set PLACE_PINS_BLOCK_NAME place_pins ;# Specify place_pins block name
set BUDGETING_BLOCK_NAME budgeting ;# Specify budgetting block name

## Design label variables applicable to the Traditional Hierarchical DP flow
set SPLIT_CONSTRAINTS_BLOCK_NAME split_constraints ;# Specify split_constraints block name
set EXPAND_OUTLINE_BLOCK_NAME expand_outline ;# Specify expand_outline block name

## Variables applicable to the HPC DP flow
set FAST_COMPILE_HPC_BLOCK_NAME fast_compile_hpc 	;# Label name to be used when saving a block in rm_icc2_dp_hier_scripts/dp_flat_compile.tcl
set TCL_USER_FAST_COMPILE_HPC_PRE_SCRIPT "" 		;# An optional Tcl file to be sourced at the very beginning of the task
set TCL_USER_FAST_COMPILE_HPC_POST_SCRIPT ""		;# An optional Tcl file to be sourced at the very end of the task
set FAST_COMPILE_HPC_ACTIVE_SCENARIO_LIST ""		;# A subset of scenarios to be made active during HPC DP compile step;
				            		;# once set, the list of active scenarios is saved and carried over to subsequent steps;
set DESIGN_PLANNING_HPC_BLOCK_NAME design_planning_hpc 	;# Label name to be used when saving a block in rm_icc2_dp_hier_scripts/dp_create_partitions.tcl
set TCL_USER_DESIGN_PLANNING_HPC_PRE_SCRIPT "" 		;# An optional Tcl file to be sourced at the very beginning of the task
set TCL_USER_DESIGN_PLANNING_HPC_POST_SCRIPT "" 	;# An optional Tcl file to be sourced at the very end of the task

