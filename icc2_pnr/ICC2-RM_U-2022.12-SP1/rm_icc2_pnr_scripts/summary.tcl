##########################################################################################
# Script: summary.tcl
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################

source ./rm_utilities/procs_global.tcl 
source ./rm_utilities/procs_icc2.tcl 
rm_source -file ./rm_setup/design_setup.tcl
rm_source -file ./rm_setup/icc2_pnr_setup.tcl
rm_source -file ./rm_setup/header_icc2_pnr.tcl
rm_source -file sidefile_setup.tcl -after_file technology_override.tcl

####################################
## Summary Report
####################################			 
if {$REPORT_QOR} {
	set REPORT_PREFIX summary
	rm_source -file print_results.tcl
        print_results -tns_sig_digits 2 -outfile ${REPORTS_DIR}/${REPORT_PREFIX}.rpt
	## Specify -tns_sig_digits N to display N digits for the TNS results in the report. Default is 0
}

print_message_info -ids * -summary
exit 
