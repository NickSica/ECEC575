
##########################################################################################
# Script: TCL_POCV_SETUP_FILE.tcl (example)
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################

set POCV_CORNER_FILE_MAPPING_LIST 	"" ;# a list of corner and its associated POCV file in pairs, as POCV is corner dependant;
					;# same corner can have multiple corresponding files;
					;# example: set POCV_CORNER_FILE_MAPPING_LIST "{corner1 file1a} {corner1 file1b} {corner2 file2}";
					;# in the example, file1a and file1b will be loaded for corner1, file2 will be loaded for corner2.

## Read POCV coefficient data and distance-based derate tables to reduce pessimism and improve accuracy of the results.
#  Specify a list of corner and its associated POCV file in pairs, as POCV is corner dependant.
foreach pair $POCV_CORNER_FILE_MAPPING_LIST {
	set corner [lindex $pair 0]	
	set file [lindex $pair 1]	
	if {[file exists [which $file]]} {
		puts "RM-info: Corner $corner: reading POCV file $file"
        	read_ocvm -corners $corner $file
	} else {
        	puts "RM-error: Corner $corner: POCV file $file is not found"
      	}
}

## Enable POCV analysis
set_app_options -name time.pocvm_enable_analysis -value true ;# tool default false; enables POCV
reset_app_options time.aocvm_enable_analysis ;# reset it to prevent POCV being overriden by AOCV

########################################################################
## Additional timer related setups : POCV	
########################################################################
## Enable distance analysis
#	set_app_options -name time.ocvm_enable_distance_analysis -value true

## Enable constraint and slew variation if there're pre-existing library LVF constraints
#	set_app_options -name time.enable_constraint_variation -value true ;# tool default false
#	set_app_options -name time.enable_slew_variation -value true ;# tool default false

## Specify the number of standard deviations used in POCV analysis
#  The larger the value, the more violations there will be 
#	set_app_options -name time.pocvm_corner_sigma -value 2 -block [current_block] ;# default 3

## Use OCV derates to fill gaps in POCV data
#  To completely ignore OCV derate settings:  
#	set_app_options -name time.ocvm_precedence_compatibility -value true
#  To consider both OCV and POCV derate settings:
#	set_app_options -name time.ocvm_precedence_compatibility -value false

## Set and report POCV guard band (per corner)
#  Use the set_timing_derate command to specify POCV guard band, which affects the mean and sensit
#  values in the timing report. For ex, if value is the same across corners:
#	set_timing_derate -cell_delay -pocvm_guardband -early 0.97 -corner [all_corners]
#  Or if value is different per corner:
#	set_timing_derate -cell_delay -pocvm_guardband -early 0.97 -corner corner1
#	set_timing_derate -cell_delay -pocvm_guardband -early 0.98 -corner corner2, ... etc
#  To report guard band:
#	report_timing_derate -pocvm_guardband -corner [all_corners]

## Set and report scaling factor (per corner)
#  It affects sensit which equals to sensit * scaling factor. For ex, if value is the same across corners:
#	set_timing_derate -cell_delay -pocvm_coefficient_scale_factor -early 0.95 -corner [all_corners]
#  Or if value is different per corner:
#	set_timing_derate -cell_delay -pocvm_coefficient_scale_factor -early 0.95 -corner corner1
#	set_timing_derate -cell_delay -pocvm_coefficient_scale_factor -early 0.96 -corner corner2, ... etc
#  To report scale factor:
#	report_timing_derate -pocvm_coefficient_scale_factor -corner [all_corners]

