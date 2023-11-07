
##########################################################################################
# Script: TCL_USER_SPARE_CELL_PRE_SCRIPT.tcl (example)
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################

## Below are to be inserted before the place_opt commands

set SPARE_CELL_PREFIX		"" ;# A string to specify the prefix for the spare cells used by add_spare_cells -cell_name option; 
set SPARE_CELL_REF_NUM_LIST 	"" ;# Specify a list that consists of pairs of space cell library cell name and number of instances,
				   ;# which is used by "add_spare_cells -num_cells" and "place_eco_cells -cells";
				   ;# the valid format is "ref1 num1 ref2 num2 ..."; for example, "andx1 10 norx1 5"

if {$SPARE_CELL_PREFIX != "" && $SPARE_CELL_REF_NUM_LIST != ""} {
	add_spare_cells -cell_name $SPARE_CELL_PREFIX -num_cells $SPARE_CELL_REF_NUM_LIST
	place_eco_cells -legalize_only -cells [get_cells -physical_context *${SPARE_CELL_PREFIX}*]
} else {
	puts "RM-warning: Either SPARE_CELL_PREFIX or SPARE_CELL_REF_NUM_LIST is not spcified."
	puts "RM-warning: Skipping add_spare_cells and place_eco_cells."
}

