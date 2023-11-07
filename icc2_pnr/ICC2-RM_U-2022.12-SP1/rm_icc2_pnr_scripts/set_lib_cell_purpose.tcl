##########################################################################################
# Script: set_lib_cell_purpose.tcl
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################

########################################################################
## Sample commands for general restrictions
########################################################################
suppress_message ATTR-11 ;# suppress the information about that design specific attribute values override over library values

## Excluded cells
#  Specify a file with your excluded lib cell constraints with "set_lib_cell_purpose -exclude <purpose>" commands
rm_source -file $TCL_LIB_CELL_DONT_USE_FILE -optional -print "TCL_LIB_CELL_DONT_USE_FILE"

## Tie cells 
if {$TIE_LIB_CELL_PATTERN_LIST != ""} {
	set_dont_touch [get_lib_cells $TIE_LIB_CELL_PATTERN_LIST] false
	set_lib_cell_purpose -include optimization [get_lib_cells $TIE_LIB_CELL_PATTERN_LIST]
}

## Hold time fixing cells 
if {$HOLD_FIX_LIB_CELL_PATTERN_LIST != ""} {
	set_dont_touch [get_lib_cells $HOLD_FIX_LIB_CELL_PATTERN_LIST] false
	set_lib_cell_purpose -exclude hold [get_lib_cells */*]
	set_lib_cell_purpose -include hold [get_lib_cells $HOLD_FIX_LIB_CELL_PATTERN_LIST]
}

##########################################################################################
## Sample commands for CTS restrictions
##########################################################################################
## CTS cells (non-exclusive) 
## Please make sure to include always-on cells (for MV-CTS), clock gate cells (for sizing),
## and equivalent gates for other types of pre-existing clock cells such as muxes (for sizing).
## You should also include flops (CCD can size them for timing improvement) in the list.
## Here's an example if you want to include flops that are already available to optimization :
#	set_lib_cell_purpose -include cts [get_lib_cells */SDFF* -filter "valid_purposes=~*optimization*"]		 
if {$CTS_LIB_CELL_PATTERN_LIST != "" || $CTS_ONLY_LIB_CELL_PATTERN_LIST != ""} {
	set_lib_cell_purpose -exclude cts [get_lib_cells */*]
}

if {$CTS_LIB_CELL_PATTERN_LIST != ""} {
	set_dont_touch [get_lib_cells $CTS_LIB_CELL_PATTERN_LIST] false ;# CTS respects dont_touch
	set_lib_cell_purpose -include cts [get_lib_cells $CTS_LIB_CELL_PATTERN_LIST]
} 

## CTS cells (exclusive)
## These are the lib cells to be used by CTS exclusively, such as CTS specific buffers and inverters.
## Please be aware that these cells will be applied with only cts purpose and nothing else.
## If you want to use these lib cells for other purposes, such as optimization and hold,
## specify them in CTS_LIB_CELL_PATTERN_LIST instead.
if {$CTS_ONLY_LIB_CELL_PATTERN_LIST != ""} {
	set_dont_touch [get_lib_cells $CTS_ONLY_LIB_CELL_PATTERN_LIST] false ;# CTS respects dont_touch
	set_lib_cell_purpose -include none [get_lib_cells $CTS_ONLY_LIB_CELL_PATTERN_LIST]
	set_lib_cell_purpose -include cts [get_lib_cells $CTS_ONLY_LIB_CELL_PATTERN_LIST]
}

