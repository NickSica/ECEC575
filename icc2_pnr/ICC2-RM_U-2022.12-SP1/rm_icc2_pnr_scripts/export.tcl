##########################################################################################
# Script: export.tcl
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################

source ./rm_utilities/procs_global.tcl 
source ./rm_utilities/procs_icc2.tcl 
rm_source -file ./rm_setup/design_setup.tcl
rm_source -file ./rm_setup/icc2_pnr_setup.tcl
rm_source -file ./rm_setup/header_icc2_pnr.tcl

if {![file exists ${RELEASE_DIR_PNR}]} {
	## Check if target release directory exists. Create one if it doesn't exist.
	file mkdir ${RELEASE_DIR_PNR}
} elseif {$RELEASE_DIR_PNR == $RELEASE_DIR_DP} {
	## If already exists, make sure target release directory for PNR is not set to the same value as DP.
	puts "RM-error: RELEASE_DIR_PNR is set to same value as RELEASE_DIR_DP. Please change it to avoid data overwrite" 
	puts "RM-info: Exiting" 
	exit 
}

if {[file exists ${RELEASE_DIR_PNR}/${DESIGN_LIBRARY}]} {
	## Check if the library to be copied already exists in the release directory. 
	puts "RM-error: DEISGN_LIBRARY ${DESIGN_LIBRARY} already exists in the target release area ${RELEASE_DIR_PNR}" 
	puts "RM-info: Please back up existing ${DESIGN_LIBRARY} to a new location to avoid ovewrite." 
	puts "RM-info: Exiting"
	exit 
} else {
	file copy ./$DESIGN_LIBRARY ${RELEASE_DIR_PNR}/
}

exit 
