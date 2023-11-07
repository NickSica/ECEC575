###########################################################################
### Placement
###########################################################################

source -echo [file join $root_dir icc2_pnr/scripts/mcmm_setup.tcl]

#set_app_options -name place.coarse.continue_on_missing_scandef -value true

##Goto Layout Window , Placement ' Core Placement and Optimization .  A new window opens up as shown below . There are various options, you can click on what ever option you want and say ok. The tool will do the placement. Alternatively you can also run at the command at icc_shell . Below is example with congestion option.
if { $pdk == "saed32nm" } {
	set CTS_LIB_CELL_PATTERN_LIST "*/NBUF* */AOBUF* */AOINV* */SDFF*"
} elseif { $pdk == "saed14nm" } {
	set CTS_LIB_CELL_PATTERN_LIST "*/*_AOBUF* */*_AOI*"
} elseif { $pdk == "tsmc65nm" } {
	set CTS_LIB_CELL_PATTERN_LIST "*/BUFF* */AOI*"
} elseif { $pdk == "tsmc28nm" } {
	set CTS_LIB_CELL_PATTERN_LIST "*/BUFF* */AOI*"
}

set_dont_touch [get_lib_cells $CTS_LIB_CELL_PATTERN_LIST] false
set_lib_cell_purpose -include {optimization cts} [get_lib_cells $CTS_LIB_CELL_PATTERN_LIST]

create_placement -floorplan

place_opt 

save_block -as ${lib_name}_place

### Reports 

#report_placement_utilization > output/${lib_name}_place_util.rpt
report_utilization > output/${lib_name}_place_util.rpt
report_qor > output/${lib_name}_place_qor.rpt

### Timing Report

report_timing -delay max -max_paths 20 > output/${lib_name}_place.setup.rpt
report_timing -delay min -max_paths 20 > output/${lib_name}_place.hold.rpt
