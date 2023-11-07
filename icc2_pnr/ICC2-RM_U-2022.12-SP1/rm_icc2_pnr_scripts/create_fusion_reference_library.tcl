##########################################################################################
# Script: create_fusion_reference_library.tcl
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################


source ./rm_utilities/procs_global.tcl 
source ./rm_utilities/procs_icc2.tcl 
rm_source -file ./rm_setup/design_setup.tcl
rm_source -file ./rm_setup/icc2_pnr_setup.tcl
rm_source -file ./rm_setup/header_icc2_pnr.tcl
rm_source -file sidefile_setup.tcl -after_file technology_override.tcl

## Create fusion library
## FUSION_REFERENCE_LIBRARY_FRAM_LIST, FUSION_REFERENCE_LIBRARY_LOG_DIR require user inputs
if {$FUSION_REFERENCE_LIBRARY_FRAM_LIST != "" && $FUSION_REFERENCE_LIBRARY_DB_LIST != ""} {

	if {[file exists $FUSION_REFERENCE_LIBRARY_DIR]} {
		puts "RM-info: FUSION_REFERENCE_LIBRARY_DIR ($FUSION_REFERENCE_LIBRARY_DIR) is specified and exists. The directory will be overwritten." 
	}

	lc_sh {\
		source ./rm_setup/design_setup.tcl; \
		source ./rm_setup/header_icc2_pnr.tcl; \
		compile_fusion_lib -frame $FUSION_REFERENCE_LIBRARY_FRAM_LIST \
		-dbs $FUSION_REFERENCE_LIBRARY_DB_LIST \
		-log_file_dir $FUSION_REFERENCE_LIBRARY_LOG_DIR \
		-output_directory $FUSION_REFERENCE_LIBRARY_DIR \
		-force
	}
} else {
	puts "RM-error: either FUSION_REFERENCE_LIBRARY_FRAM_LIST or FUSION_REFERENCE_LIBRARY_DB_LIST is not specified. Fusion library creation is skipped!"	
}

echo [date] > create_fusion_reference_library
exit
