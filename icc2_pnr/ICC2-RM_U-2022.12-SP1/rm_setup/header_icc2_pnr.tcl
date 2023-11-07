##########################################################################################
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################


set search_path [list ./rm_user_plugin_scripts ./rm_tech_scripts ./rm_icc2_pnr_scripts ./rm_setup ./examples]
if {$SUPPLEMENTAL_SEARCH_PATH != ""} {
   set search_path "$search_path $SUPPLEMENTAL_SEARCH_PATH"
}
lappend search_path .

if {$synopsys_program_name == "icc2_shell" || $synopsys_program_name == "fc_shell"} {
   set_host_options -max_cores $SET_HOST_OPTIONS_MAX_CORES

   ## The default number of significant digits used to display values in reports
   set_app_options -name shell.common.report_default_significant_digits -value 3 ;# tool default is 2

   ## Enable on-disk operation for copy_block to save block to disk right away
   #  set_app_options -name design.on_disk_operation -value true ;# default false and global-scoped
}

set sh_continue_on_error true

if {![file exists $OUTPUTS_DIR]} {file mkdir $OUTPUTS_DIR} ;# do not change this line or directory may not be created properly
if {![file exists $REPORTS_DIR]} {file mkdir $REPORTS_DIR} ;# do not change this line or directory may not be created properly
if {$WRITE_QOR_DATA && ![file exists $WRITE_QOR_DATA_DIR]} {file mkdir $WRITE_QOR_DATA_DIR} ;# do not change this line or directory may not be created properly
if {$WRITE_QOR_DATA && ![file exists $COMPARE_QOR_DATA_DIR]} {file mkdir $COMPARE_QOR_DATA_DIR} ;# do not change this line or directory may not be created properly

########################################################################################## 
## Message handling
##########################################################################################
if {[get_app_var synopsys_program_name] == "fc_shell" || [get_app_var synopsys_program_name] == "icc2_shell"} {
	suppress_message ATTR-11 ;# suppress the information about that design specific attribute values override over library values
	set_message_info -id PVT-012 -limit 1
	set_message_info -id PVT-013 -limit 1
}
puts "RM-info: Hostname: [sh hostname]"; puts "RM-info: Date: [date]"; puts "RM-info: PID: [pid]"; puts "RM-info: PWD: [pwd]"
