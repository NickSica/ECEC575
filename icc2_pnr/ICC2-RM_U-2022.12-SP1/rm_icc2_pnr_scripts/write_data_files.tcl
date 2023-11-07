##########################################################################################
# Script: write_data_files.tcl
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################
if { [ info exists block_libfilename ] } { 
   source ./rm_utilities/procs_global.tcl 
   source ./rm_utilities/procs_icc2.tcl 
   rm_source -file ./rm_setup/design_setup.tcl
   rm_source -file ./rm_setup/icc2_pnr_setup.tcl
   rm_source -file ./rm_setup/icc2_dp_setup.tcl
   rm_source -file sidefile_setup.tcl -after_file technology_override.tcl
   set full_lib_name $block_libfilename
   set block_name $block_refname_no_label
   set full_block_name "${block_libfilename}:${block_refname}.design"
} else {
   set lib_name [get_attribute $block lib_name]
   set full_lib_name [get_attribute [get_lib $lib_name] extended_name]
   set label_name [get_attribute $block label_name]
   set block_name [get_attribute $block block_name]
   set full_block_name "${lib_name}:${block_name}/${label_name}.design"
}

rm_source -file $TCL_USER_LIBRARY_SETUP_SCRIPT -optional -print "TCL_USER_LIBRARY_SETUP_SCRIPT"

## open the design view and initialize setup
open_block -read $full_block_name
set BLOCK_OUTPUT_DIR "${OUTPUTS_DIR}/$block_name"
file delete -force ${BLOCK_OUTPUT_DIR}
file mkdir ${BLOCK_OUTPUT_DIR}

## Copy block library to outputs.
#if { [ info exists block_libfilename ] } {
#  set lib_name [get_attribute [current_lib] name]
#}
#puts "lib_name == $lib_name"
#copy_lib -from $full_lib_name -to ${BLOCK_OUTPUT_DIR}/${lib_name}${LIBRARY_SUFFIX}

########################################################################
## write_verilog for logic only, DC, PT, FM, and VC LP
########################################################################
## write_verilog (no pg, and no physical only cells)
set write_verilog_logic_only_cmd "write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations pg_objects end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells} -hierarchy all ${BLOCK_OUTPUT_DIR}/${block_name}.v"

## write_verilog for comparison with a DC netlist (no pg, no physical only cells, and no diodes)
set write_verilog_dc_cmd "write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations pg_objects end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells diode_cells} -hierarchy all ${BLOCK_OUTPUT_DIR}/${block_name}.dc.v"

## write_verilog for PrimeTime (no pg, no physical only cells but with diodes and DCAP for leakage power analysis)
set write_verilog_pt_cmd "write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations pg_objects end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells flip_chip_pad_cells} -hierarchy all ${BLOCK_OUTPUT_DIR}/${block_name}.pt.v"
if {$CHIP_FINISH_METAL_FILLER_LIB_CELL_LIST != ""} {
	lappend write_verilog_pt_cmd -force_reference $CHIP_FINISH_METAL_FILLER_LIB_CELL_LIST
}

## write_verilog for Formality (with pg, no physical only cells, and no supply statements)
set write_verilog_fm_cmd "write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells supply_statements} -hierarchy all ${BLOCK_OUTPUT_DIR}/${block_name}.fm.v"

## write_verilog for VC LP (with pg, no physical_only cells, no diodes, and no supply statements)
set write_verilog_vclp_cmd "write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells diode_cells supply_statements} -hierarchy all ${BLOCK_OUTPUT_DIR}/${block_name}.vc_lp.v"

puts "RM-info: running $write_verilog_logic_only_cmd"
puts "RM-info: running $write_verilog_dc_cmd"
puts "RM-info: running $write_verilog_pt_cmd"
puts "RM-info: running $write_verilog_fm_cmd"
puts "RM-info: running $write_verilog_vclp_cmd"
parallel_execute -commands_only [list
eval ${write_verilog_logic_only_cmd}
eval ${write_verilog_dc_cmd}
eval ${write_verilog_pt_cmd}
eval ${write_verilog_fm_cmd}
eval ${write_verilog_vclp_cmd}
]

########################################################################
## write_verilog for LVS, write_gds & write_oasis
########################################################################
## write_verilog for LVS (with pg, and with physical only cells)
set write_verilog_lvs_cmd "write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations empty_modules} -hierarchy all ${BLOCK_OUTPUT_DIR}/${block_name}.lvs.v"

## write_gds
set write_gds_cmd "write_gds -compress -hierarchy all -long_names -keep_data_type ${BLOCK_OUTPUT_DIR}/${block_name}.gds"
if {[file exists $WRITE_GDS_LAYER_MAP_FILE]} {lappend write_gds_cmd -layer_map $WRITE_GDS_LAYER_MAP_FILE}
if {$STREAM_FILES_FOR_MERGE != ""} {
	lappend write_gds_cmd -merge_gds_top_cell ${block_name}
	lappend write_gds_cmd -merge_files $STREAM_FILES_FOR_MERGE
}

## write_oasis
set write_oasis_cmd "write_oasis -compress 6 -hierarchy all -keep_data_type ${BLOCK_OUTPUT_DIR}/${block_name}.oasis"
if {[file exists $WRITE_OASIS_LAYER_MAP_FILE]} {lappend write_oasis_cmd -layer_map $WRITE_OASIS_LAYER_MAP_FILE}
if {$STREAM_FILES_FOR_MERGE != ""} {
	lappend write_oasis_cmd -merge_oasis_top_cell ${block_name}
	lappend write_oasis_cmd -merge_files $STREAM_FILES_FOR_MERGE
}

rm_source -file $SIDEFILE_WRITE_DATA -optional -print "SIDEFILE_WRITE_DATA"

puts "RM-info: running $write_verilog_lvs_cmd"
puts "RM-info: running $write_gds_cmd"
puts "RM-info: running $write_oasis_cmd"
parallel_execute -commands_only [list
eval ${write_verilog_lvs_cmd}
eval ${write_gds_cmd}
eval ${write_oasis_cmd}
]

########################################################################
## save_upf
########################################################################
## Write out UPF
if {$UPF_SUPPLEMENTAL_FILE != ""} {

	## For golden UPF flow
	## write supplemental UPF with supply exceptions
	save_upf ${BLOCK_OUTPUT_DIR}/${block_name}.supplemental.pg.upf
	## write supplemental UPF without supply exceptions
	set_app_options -name mv.upf.save_upf_include_supply_exceptions -value false
	save_upf ${BLOCK_OUTPUT_DIR}/${block_name}.supplemental.upf

} else {

	## For UPF prime flow
	save_upf ${BLOCK_OUTPUT_DIR}/${block_name}.upf

}

########################################################################
## write_script, write_routing_constraints, and write_parasitics
########################################################################
## write_script
#  writes multiple files to the specified directory. 
#  It writes mode_{mode_name}.tcl for mode specific info, corner_{corner_name}.tcl for corner specific info, 
#  design.tcl for non-mode or corner specific info, cts.tcl for cts options and top.tcl that sources all scripts. 
write_script -force -compress gzip -output ${BLOCK_OUTPUT_DIR}/${block_name}_wscript
#  -format pt generates PT compatible outputs 
write_script -force -compress gzip -format pt -output ${BLOCK_OUTPUT_DIR}/${block_name}_wscript_for_pt

## Writes routing constraints of the design in a Tcl script, such as :
## create_routing_rule, set_routing_rule, create_wire_matching, create_length_limit, create_differential_group, 
## create_net_shielding, create_net_priority, create_bus_routing_style and set_ignored_layers.
write_routing_constraints ${BLOCK_OUTPUT_DIR}/${block_name}_write_routing_constraints

## write_parasitics
update_timing
write_parasitics -compress -output ${BLOCK_OUTPUT_DIR}/${block_name}

########################################################################
## write_floorplan and write_def
########################################################################
write_floorplan \
  -format icc2 \
  -def_version 5.8 \
  -force \
  -output ${BLOCK_OUTPUT_DIR}/${block_name}_write_floorplan \
  -read_def_options {-add_def_only_objects {all} -skip_pg_net_connections} \
  -exclude {scan_chains fills pg_metal_fills routing_rules} \
  -net_types {power ground} \
  -include_physical_status {fixed locked}

## write_def : Enable the following for LEF/DEF based flow to StarRC if LEF is written out from the tool,
#  since write_lef in the tool doesn't currently support WRONGDIRECTION syntax.
#  This is not needed if you are using LEF files which contain the WRONGDIRECTION syntax already.
#	set_app_options -name file.def.wrong_way_wiring_to_special_net -value true
set write_def_cmd "write_def -compress gzip -version 5.8 -include_tech_via_definitions ${BLOCK_OUTPUT_DIR}/${block_name}.def"
puts "RM-info: running $write_def_cmd"
eval ${write_def_cmd}

close_blocks -force
