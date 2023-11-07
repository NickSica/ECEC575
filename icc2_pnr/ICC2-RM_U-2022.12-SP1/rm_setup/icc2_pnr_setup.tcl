##########################################################################################
# Script: icc2_pnr_setup.tcl 
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################

##########################################################################################
###+ADVANCED FLOW CUSTOMIZATION
##########################################################################################

########################################################################################## 
### CONGESTION & OPTIMIZATION
## Special features
##########################################################################################
## For controlling the set_qor_strategy command options
set SET_QOR_STRATEGY_METRIC		"timing" ;# timing|leakage_power|total_power; default is timing;
					;# Specify one metric for the set_qor_strategy -metric option and the settings will be configured to optimize the specified target metric.
set SET_QOR_STRATEGY_MODE		"balanced" ;# balanced|extreme_power|early_design; default is balanced;
					;# Specify one mode for set_qor_strategy -mode option and the settings will be configured for the target mode
set ENABLE_REDUCED_EFFORT		false ;# false|true; RM default false; set it to true to enable the -reduced_effort option for the set_qor_strategy command;
					;# reduces efforts used by the set_qor_strategy command
set RESET_CHECK_STAGE_SETTINGS		false ;# false|true|all; RM default false; set it to true to enable the -reset_app_options option for the check_stage_settings command;
					;# compares current app option settings against set_technology, set_qor_strategy, set_stage, and select tool default settings which can impact runtime or ppa
					;# when set to all, the reset_app_options command will be applied to the incoming design database in the init_design.tcl script 
set NON_DEFAULT_CHECK_STAGE_SETTINGS    false ;# false|true; RM default false; set it to true to enable the -all_non_default option for the check_stage_settings command;
                                        ;# reports all non-default app options other than megaswitch settings


## For SPG flow
set ENABLE_SPG 				false ;# false|true; RM default false; set it to true to enable SPG input handling flow in place_opt.tcl;
					;# which skips the first pass of the two-pass placement;
					;# recommended to go with DC-ASCII inputs (set INIT_DESIGN_INPUT DC_ASCII)


## For high utilization designs
set ENABLE_HIGH_UTILIZATION_FLOW	false ;# false|true; RM default false; set it to true to enable extra commands to address high utilization, such as:
					;# remove_buffer_trees -all, create_placement -buffering_aware_timing_driven, and place_opt initial_drc in place_opt.tcl;
					;# these extra commands are enabled only if ENABLE_SPG is set to false

 
## For High effort congestion
set ENABLE_HIGH_EFFORT_CONGESTION 	false ;# false|true; RM default false; set it to true to enable high effort congestion flow.  
					;# When true, the -high_effort_congestion switch will be enabled with set_stage -step {synthesis|compile_Place|placement}  

## For Multibit Banking
set ENABLE_MULTIBIT                     false ;# false | true; RM default false but will be set to true if SET_QOR_STRATEGY_METRIC is set to total_power. 
                                        ;# In SET_QOR_STRATEGY_METRIC timing or leakage_power, multibit banking is not automatically used. Set  
                                        ;# ENABLE_MULTIBIT to true to enable multibit banking and debanking regardless of the SET_QOR_STRATEGY_METRIC. 

########################################################################################## 
### POWER & IR FEATURES 
##########################################################################################

## For DPS
set ENABLE_DPS				false ;# false|true; RM default false; set it to true for set_stage command to enable dynamic power shaping (DPS)
					;# Optimizes peak current and bulk dynamic voltage drop (DVD) by clock scheduling. Reduces DVD across the design. Takes effect during final_opto phase.
					;# Affects timing network latencies to make pre-CTS steps see the impact, and clock balance points to direct tool to implement the offsets in CTS. 
					;# Pls run redhawk fusion after clock_opt/route_opt stage to verify dynamic voltage drop improvements
## For IRDP
set ENABLE_IRDP				false ;# false|true; RM default false; set it to true to enable IR-aware placement (IRDP) in clock_opt_opto.tcl
set TCL_IRDP_CONFIG_FILE		"" ;# (Required for ENABLE_IRDP) Specify a Tcl script for IRDP configuration
					;# Example for IRDP with streamline RedHawk config :	examples/TCL_IRDP_CONFIG_FILE.rh.tcl  
					;# Example for IRDP with streamline RHSC config :	examples/TCL_IRDP_CONFIG_FILE.rhsc.tcl
## For IRD-CCD
set ENABLE_IRDCCD			false ;# false|true; RM default false; set it to true to enable IR-aware CCD (IRD-CCD) in route_opt.tcl
set TCL_IRDCCD_CONFIG_FILE		"" ;# (Required for ENABLE_IRDCCD) Specify a Tcl script for IRD-CCD configuration
					;# Example for IRD-CCD with RH config: 			examples/TCL_IRDCCD_CONFIG_FILE.rh.tcl
					;# Example for IRD-CCD with RHSC config : 		examples/TCL_IRDCCD_CONFIG_FILE.rhsc.tcl

## For Indesign PrimePower
set INDESIGN_PRIMEPOWER_STAGES	 	"AFTER_CLOCK_OPT_OPTO AFTER_ROUTE_OPT" ;# list of stage names where Indesign PrimePower flow should be run; 
                                        ;# valid list values: AFTER_PLACE_OPT AFTER_CLOCK_OPT_OPTO AFTER_ROUTE_OPT
set TCL_PRIMEPOWER_CONFIG_FILE		"" ;# (Required to enable InDesign PrimePower flow) Specify a Tcl script for Indesign PrimePower configuration
					;# Example for Indesign PrimePower config :		examples/TCL_PRIMEPOWER_CONFIG_FILE.indesign_options.tcl 
                                        ;# The config file will be used to run Indesign PrimePower after compile/place_opt/clock_opt_opto
					;# Using the FSDB, PrimePower will create an updated gate level SAIF that will be annotated back into the design after compile/place_opt/clock_opt_opto
set KEEP_INDESIGN_SAIF_FILE		"false" ;# false|true; RM default false; set it to true to keep the saif file generated during  Indesign PrimePower flow. By default saif file will be overwritten 

########################################################################################## 
### CTS & MSCTS 
###########################################################################################
## For CTS & MSCTS
set CTS_STYLE                           "standard" ;# standard|MSCTS; RM default standard; specify MSCTS to enable regular multisource clock tree synthesis flow; 
set TCL_REGULAR_MSCTS_FILE		"./examples/mscts.regular.tcl" ;# Specify a Tcl script for regular multisource clock tree synthesis setup and creation,
					;# which will be sourced after initial placement if CTS_STYLE is set to MSCTS in place_opt.tcl
					;# (Required if CTS_STYLE is MSCTS); RM provided script: examples/mscts.regular.tcl 
set TCL_USER_MSCTS_MESH_ROUTING_SCRIPT  "" ;# An optional Tcl file that can be provided for clock mesh net routing

########################################################################################## 
### ROUTE & POSTROUTE 
###########################################################################################
## Variables for incremental route_detail for fixing routing DRCs (Used by route_opt.tcl and endpoint_opt.tcl)
set INCR_ROUTE_DETAIL_MODE              "auto" ;# auto|false|true; triggers "route_detail -incremental true -initial_drc_from_input true" after the core command (hyper_route_opt in route_opt.tcl and 
                                        ;# endpoint in endpoint_opt.tcl)
                                        ;# true : always on  
                                        ;# false : always off; 
                                        ;# auto (the default): script automatically triggers the command if the following 4 conditions are met : 
                                        ;# (1) DRC increases after the core command (2) DRC increase percentage is larger than INCR_ROUTE_DETAIL_PERCENTAGE_THRESHOLD_MIN 
                                        ;# (3) DRC before core command is less than INCR_ROUTE_DETAIL_DRC_THRESHOLD_MAX (4) DRC after core command is larger than INCR_ROUTE_DETAIL_DRC_THRESHOLD_MIN
set INCR_ROUTE_DETAIL_DRC_INCREASE_THRESHOLD_MIN "0.1" ;# a float between 0 and 1; default is 0.1; this variable only takes effect if INCR_ROUTE_DETAIL_MODE = auto;
                                        ;# if DRC increases (i.e. DRC after core command - DRC before core command) divided by DRC before core command is smaller than this value, route_detail is skipped;
                                        ;# for ex, if value is 0.2, then (DRC increase)/(DRC before core command) needs to be larger than 0.2 in order for route_detail to kick in;
                                        ;# a larger value requires the DRC increase to be much larger in order to trigger route_detail, and thus reducing chances it triggers.   
set INCR_ROUTE_DETAIL_DRC_THRESHOLD_MAX "10000" ;# a positive integer as the DRC maximum threshold; default 10000; if routing DRC before the core command (hyper_route_opt or endpoint) is larger than 
                                        ;# this value, incremental route_detail is skipped; only takes effect if INCR_ROUTE_DETAIL_MODE = auto; 
set INCR_ROUTE_DETAIL_DRC_THRESHOLD_MIN "50" ;# a positive integer as the DRC minimum threshold; default 50; if routing DRC after the core command (hyper_route_opt or endpoint) is smaller than this value,
                                        ;# incremental route_detail is skipped; only takes effect if INCR_ROUTE_DETAIL_MODE = auto; 
set INCR_ROUTE_DETAIL_MAX_ITERATIONS    "" ;# (optional) a positive integer; if specified, add "-max_number_iterations $INCR_ROUTE_DETAIL_MAX_ITERATIONS" to the route_detail command;
                                        ;# default is null which means -max_number_iterations is not used and route_detail runs with its own default max iterations

## For hyper_route_opt
set ENABLE_ROUTE_OPT_PBA		true ;# true|false; RM default true; set it to false to use GBA instead of PBA during hyppr_route_opt

## For shielding
set ENABLE_CREATE_SHIELDS		false ;# false|true; RM default false; enable shielding (create_shields) in the flow;
					;# it is done at the beginning of clock_opt_opto, end of route_auto, end of route_opt, and end of endpoint_opt steps;
					;# For route_auto, route_opt, and endpoint_opt steps, create_shields command runs with -shielding_mode reshield  
set CREATE_SHIELDS_GROUND_NET		"" ;# specify a net name for -with_ground; by default shielding wires are tied to the ground net. If design has multiple ground nets, use this option to specify the desired net
set CREATE_SHIELDS_OPTIONS 		"" ;# specify additional user specified options for create_shields command, such as "-preferred_direction_only true -align_to_shape_end true";
					;# please do not specify duplicate "-with_ground" or "-shielding_mode reshield" as they are RM defaults and will be applied when applicable in the flow.

set ROUTE_OPT_STARRC_CONFIG_FILE 	"" ;# Specify the configuration file for StarRC in-design extraction for route_auto.tcl and route_opt.tcl;
					;# (Required for enabling StarRC in-design extraction); refer to examples/ROUTE_OPT_STARRC_CONFIG_FILE.example.txt for sample content and syntax
set SET_STARRC_IN_DESIGN_OPTIONS	"" ;# specify additional user specified options for set_starrc_in_design command, such as "-mode ... -reduction ...";
					;# please do not specify duplicate "-config" option as it is RM default when ROUTE_OPT_STARRC_CONFIG_FILE is specified.
## For virtual metal fill
set VMF_PARAMETER_FILE			"" ;# Parameter File required for virtual metal fill to be modeled during route_opt
set SET_VMF_EXTRACTION_OPTIONS		"-real_metalfill_extraction none -virtual_metalfill_extraction floating"  ;# Define options to be used with set_extraction_options command
set ENABLE_ADVANCED_VMF			false ;# true|false; RM desault false; Set it to true if VMF parameter file does not use the basic VMF format 

