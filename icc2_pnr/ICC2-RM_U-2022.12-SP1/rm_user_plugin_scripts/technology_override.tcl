##########################################################################################
# Script: technology_override.tcl
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################

## NOTE:
## This technology_override.tcl is intended to allow users to locally override node specific variables desfined in sidefile_setup.tcl  
## This file will be sourced after the sidefile_setup.tcl and precedence will be given to these variable definitions. 
## User can define any node specific variables in the section below to override the value defined in sidefile_setup.tcl  

########################################################################################## 
## Node specific variables 
##########################################################################################
#set MIN_ROUTING_LAYER                                   "" ;# Optional; Min routing layer name; normally should be specified; otherwise tool can use all metal layers
#set MAX_ROUTING_LAYER                                   "" ;# Optional; Max routing layer name; normally should be specified; otherwise tool can use all metal layers
#set TCL_LIB_CELL_DONT_USE_FILE                          "" ;# Optional; A Tcl file for customized don't use ("set_lib_cell_purpose -exclude <purpose>" commands)
#                                                           ;# sourced by set_lib_cell_purpose.tcl; only applicable if TCL_LIB_CELL_PURPOSE_FILE is set to set_lib_cell_purpose.tcl
#set TCL_CTS_NDR_RULE_FILE                               "" ;# Specify a script for clock NDR creation and association, to be sourced at place_opt
#                                                        ;# By default the variable is set to ./examples/cts_ndr.tcl, which is an RM provided example.
#                                                        ;# All the variables for customizing the clock NDR are defined within the example script.
