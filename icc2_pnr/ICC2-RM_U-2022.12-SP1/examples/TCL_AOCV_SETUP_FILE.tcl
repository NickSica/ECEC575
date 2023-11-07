
##########################################################################################
# Script: TCL_AOCV_SETUP_FILE.tcl (example)
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################

set AOCV_CORNER_TABLE_MAPPING_LIST 	"" ;# Optional; a list of corner and its associated AOCV table in pairs, as AOCV is corner dependant;
					;# same corner can have multiple corresponding tables;
					;# example: set AOCV_CORNER_TABLE_MAPPING_LIST "{corner1 table1a} {corner1 table1b} {corner2 table2}";
					;# in the example, table1a and table1b will be loaded for corner1, table2 will be loaded for corner2.

## Read AOCV derate factor table to reduce pessimism and improve accuracy of the results.
#  Specify a list of corner and its associated AOCV table in pairs, as AOCV is corner dependant.
if {![get_app_option_value -name time.pocvm_enable_analysis] && $AOCV_CORNER_TABLE_MAPPING_LIST != ""} {
	foreach pair $AOCV_CORNER_TABLE_MAPPING_LIST {
		set corner [lindex $pair 0]	
		set table [lindex $pair 1]	
		if {[file exists [which $table]]} {
			puts "RM-info: Corner $corner: reading AOCV table file $table"
	        	read_ocvm -corners $corner $table
		} else {
	        	puts "RM-error: Corner $corner: AOCV table file $table is not found"
	      	}
	}
	
	## Set user-specified instance based random coefficient for the AOCV analysis 
	#  Example : set_aocvm_coefficient <value> [get_lib_cells <lib_cell>]

	## AOCV is enabled in clock_opt_cts.tcl after CTS is done
}
