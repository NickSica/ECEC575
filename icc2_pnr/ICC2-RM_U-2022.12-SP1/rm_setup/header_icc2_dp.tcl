##########################################################################################
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################


set search_path [list ./rm_user_plugin_scripts ./rm_tech_scripts ./rm_icc2_dp_flat_scripts ./rm_icc2_dp_hier_scripts ./rm_icc2_pnr_scripts ./rm_setup ./examples $WORK_DIR]
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

if { [info exists INTERMEDIATE_BLOCK_VIEW] && $INTERMEDIATE_BLOCK_VIEW == "abstract" } {
   set_app_options -name abstract.allow_all_level_abstract -value true  ;# Dafult value is false
}

if !{[file exists $WORK_DIR]} {file mkdir $WORK_DIR}
if !{[file exists ./work_dir]} {file mkdir ./work_dir}

if !{[file exists $REPORTS_DIR]} {file mkdir $REPORTS_DIR}
if !{[file exists $OUTPUTS_DIR]} {file mkdir $OUTPUTS_DIR}

if {[info exists env(LOGS_DIR)]} {
   set log_dir $env(LOGS_DIR)
} else {
   set log_dir ../logs_icc2 
}

########################################################################################## 
## Message handling
##########################################################################################
suppress_message ATTR-11 ;# suppress the information about that design specific attribute values override over library values
## set_message_info -id ATTR-11 -limit 1 ;# limit the message normally printed during report_lib_cells to just 1 occurence
set_message_info -id PVT-012 -limit 1
set_message_info -id PVT-013 -limit 1
puts "RM-info: Hostname: [sh hostname]"; puts "RM-info: Date: [date]"; puts "RM-info: PID: [pid]"; puts "RM-info: PWD: [pwd]"

