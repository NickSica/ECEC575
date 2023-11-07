#################################################################################
# Tool: Verification Compiler Low Power Static Signoff Script 
# Script: vclp.tcl
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
#################################################################################

## Enable the default behavior of sh_continue_on_error to be same as DC
set_app_var sh_continue_on_error true
set_app_var handle_hanging_crossover true
set_app_var enable_local_policy_match true
set_app_var upf_iso_filter_elements_with_applies_to ENABLE
set_app_var enable_multi_driver_analysis true
set_app_var implicit_scmr_pins true
set_app_var enable_verdi_debug true

source ./rm_utilities/procs_global.tcl 
source ./rm_utilities/procs_icc2.tcl 
rm_source -file ./rm_setup/design_setup.tcl
rm_source -file ./rm_setup/icc2_pnr_setup.tcl
rm_source -file ./rm_setup/header_icc2_pnr.tcl

rm_source -file $TCL_USER_LIBRARY_SETUP_SCRIPT -optional -print "TCL_USER_LIBRARY_SETUP_SCRIPT"

set_app_var link_library $LINK_LIBRARY

read_file -netlist -top $DESIGN_NAME ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}.vc_lp.v.gz

## Read UPF
if {$UPF_SUPPLEMENTAL_FILE != ""} {
	## For golden UPF flow
	read_upf $UPF_FILE -supplemental $OUTPUTS_DIR/${WRITE_DATA_BLOCK_NAME}.supplement.upf -strict_check false
} else {
	## For UPF prime flow
	read_upf $OUTPUTS_DIR/${WRITE_DATA_BLOCK_NAME}.upf
}

check_lp -stage upf
check_lp -stage design
check_lp -stage pg

report_lp -file ${REPORTS_DIR}/${DESIGN_NAME}.vc_lp_report_violations.PGNETLIST.rpt
report_lp -verbose -file ${REPORTS_DIR}/${DESIGN_NAME}.vc_lp_report_violations.PGNETLIST.verbose.rpt

puts "RM-info: End script [info script]\n"
exit
