##########################################################################################
# Script: write_data_for_etm.tcl
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################

source ./rm_utilities/procs_global.tcl 
source ./rm_utilities/procs_icc2.tcl 
rm_source -file ./rm_setup/design_setup.tcl
rm_source -file ./rm_setup/icc2_pnr_setup.tcl
rm_source -file ./rm_setup/header_icc2_pnr.tcl

######################################################################
## Write out ASCII Data needed to Generate ETM in PT and Create Frame
######################################################################
if {$WRITE_DATA_FOR_ETM_GENERATION } {

        if {[file exists ./${DESIGN_LIBRARY}]} {
             	open_lib ${DESIGN_LIBRARY}
     
             	## Following set of lines open the block saved after icv_in_design step and dump out design data needed to generate ETM
             	## Modify WRITE_DATA_FOR_ETM_BLOCK_NAME in design_setup.tcl if you want to create ETM for some other stage of the block
             	open_block ${DESIGN_NAME}/$WRITE_DATA_FOR_ETM_BLOCK_NAME
     
     	     	## write_verilog for PT (without physical only cells and with diodes and DCAP for leakage power analysis)
     	     	## To enable write_verilog to write out UPF compatible for other Synopsys tools as well as verilog
             	set write_verilog_pt_cmd "write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations pg_objects end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells flip_chip_pad_cells} -hierarchy all ${OUTPUTS_DIR}/${DESIGN_NAME}.pt.v"
             	if {$CHIP_FINISH_METAL_FILLER_LIB_CELL_LIST != ""} {lappend write_verilog_pt_cmd -force_reference $CHIP_FINISH_METAL_FILLER_LIB_CELL_LIST}
                puts "RM-info: $write_verilog_pt_cmd"
             	eval $write_verilog_pt_cmd
     
     	     	## write_parasitics
            	if {$DESIGN_STYLE == "hier"} {
                  if { $PHYSICAL_HIERARCHY_LEVEL != "bottom" && $USE_ABSTRACTS_FOR_BLOCKS != ""} {
                      change_abstract -view design -references $USE_ABSTRACTS_FOR_BLOCKS
                      update_timing
                      write_parasitics -hierarchical -output ${OUTPUTS_DIR}/${DESIGN_NAME}
                  } else {
                      update_timing
                      write_parasitics -hierarchical -output ${OUTPUTS_DIR}/${DESIGN_NAME}
                  }
                }

     
             	## write out scenario creation script
                write_script -format pt -output ${OUTPUTS_DIR}/pt_write_script

             	save_lib
     	     	close_lib
        } else {
		puts "RM-error: ${DESIGN_LIBRARY} does not exist. Please correct it. Exiting"
		exit 
        }
}

print_message_info -ids * -summary
echo [date] > write_data_for_etm

exit 
