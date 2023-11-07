##########################################################################################
# Script: write_data.tcl
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################

source ./rm_utilities/procs_global.tcl 
source ./rm_utilities/procs_icc2.tcl 
rm_source -file ./rm_setup/design_setup.tcl
rm_source -file ./rm_setup/icc2_pnr_setup.tcl
rm_source -file ./rm_setup/header_icc2_pnr.tcl

open_lib $DESIGN_LIBRARY
copy_block -from ${DESIGN_NAME}/${WRITE_DATA_FROM_BLOCK_NAME} -to ${DESIGN_NAME}/${WRITE_DATA_BLOCK_NAME}
current_block ${DESIGN_NAME}/${WRITE_DATA_BLOCK_NAME}
link_block

########################################################################
## change_names
########################################################################
## Purpose : change the names of ports, cells, and nets in a design, in order to make the output netlist, 
#  DEF, SPEF, ... etc conform to specified name rules
#  Note : 
#  - If the current block is a sub cell of another block, make sure no port names are changed during change_names;
#    if there is, you either modify your naming rule to avoid the name change, re-setup the connection between
#    the renamed port and the net at the parent level, or if the blocks are from commit_block then you can run 
#    the same change_names command before commit_block at the parent level.
#  - To preview whether there is any potential port name changes, check the report_names log first
redirect -tee -file ${REPORTS_DIR}/${WRITE_DATA_BLOCK_NAME}.report_names.log {report_names -rules verilog}

change_names -rules verilog -hierarchy

save_block

####################################################################################################
## For current block, write out ASCII Data (verilog, UPF, DEF, scripts/SDC, parasitics, and GDS)  
####################################################################################################
## write_verilog (no pg, and no physical only cells)
set write_verilog_logic_only_cmd "write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations pg_objects end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells} -hierarchy all -switch_view_list design ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}.full_chip.v"
puts "RM-info: running $write_verilog_logic_only_cmd"

## Write out UPF
if {$UPF_SUPPLEMENTAL_FILE != ""} {

	## For golden UPF flow
	## write supplemental UPF with supply exceptions
	save_upf -full_chip ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}.supplemental.pg.full_chip.upf
	## write supplemental UPF without supply exceptions
	set_app_options -name mv.upf.save_upf_include_supply_exceptions -value false
	save_upf -full_chip ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}.supplemental.full_chip.upf

} else {

	## For UPF prime flow
	save_upf -full_chip ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}.full_chip.upf

}

## write_parasitics
change_abstract -view design -references $USE_ABSTRACTS_FOR_BLOCKS
update_timing
write_parasitics -hierarchical -compress -output ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}.full_chip

## write_def : Enable the following for LEF/DEF based flow to StarRC if LEF is written from the tool,
#  since write_lef in the tool doesn't currently support WRONGDIRECTION syntax.
#  This is not needed if you are using LEF files which contain the WRONGDIRECTION syntax already.
#	set_app_options -name file.def.wrong_way_wiring_to_special_net -value true
set write_def_cmd "write_def -compress gzip -version 5.8 -include_tech_via_definitions -traverse_physical_hierarchy ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}.full_chip.def"
puts "RM-info: running $write_def_cmd"

## If there's any design mismatches found, write_gds will not write out GDS, since GDS will be used for tape-out.
#  If you still want to write out GDS despite of mismatches, append the -allow_design_mismatch option to the 
#  write_gds command.
set write_gds_cmd "write_gds -compress -hierarchy all -long_names -keep_data_type -switch_view_list design ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}.full_chip.gds"
if {[file exists $WRITE_GDS_LAYER_MAP_FILE]} {lappend write_gds_cmd -layer_map $WRITE_GDS_LAYER_MAP_FILE}
puts "RM-info: running $write_gds_cmd"

## If there's any design mismatches found, write_oasis will not write out OASIS, since OASIS will be used for tape-out.
#  If you still want to write out OASIS despite of mismatches, append the -allow_design_mismatch option to the 
#  write_oasis command.
set write_oasis_cmd "write_oasis -compress 6 -hierarchy all -keep_data_type -switch_view_list design ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}.full_chip.oasis"
if {[file exists $WRITE_OASIS_LAYER_MAP_FILE]} {lappend write_oasis_cmd -layer_map $WRITE_OASIS_LAYER_MAP_FILE}
puts "RM-info: running $write_oasis_cmd"

## Node specific file
rm_source -file $SIDEFILE_WRITE_FULL_CHIP_DATA_1 -optional -print "SIDEFILE_WRITE_FULL_CHIP_DATA_1"

parallel_execute -commands_only {
	{eval $write_verilog_logic_only_cmd}
	{eval $write_def_cmd}
	{eval $write_gds_cmd}
	{eval $write_oasis_cmd}
}

echo [date] > write_data

exit

