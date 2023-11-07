#set designs {s1238 s15850 s35932 s386 s9234}
if { [info exists ::env(TOP)] } {
	set top $::env(TOP) 
} else {
	set top s1238
}

if { [info exists ::env(SRC_DIRS)] } {
    set src_dirs $::env(SRC_DIRS)
} else {
	set src_dirs ""
}

if { [info exists ::env(SVLOG_FILES)] } {
    set svlog_files $::env(SVLOG_FILES)
} else {
	set svlog_files ""
}

if { [info exists ::env(PKG_FILES)] } {
    set pkg_files $::env(PKG_FILES)
} else {
	set pkg_files ""
}

if { [info exists ::env(INCL_DIRS)] } {
    set incl_dirs $::env(INCL_DIRS)
} else {
    set incl_dirs ""
}

set pdk tsmc65nm

## Define the library location
if { $pdk == "saed14nm" } {
	set pdk_dir /home/tech/SAED14nm
	set link_library [ list * \
		$pdk_dir/stdcell_rvt/db_ccs/saed14rvt_ss0p72v125c.db \
		$pdk_dir/stdcell_rvt/db_ccs/saed14rvt_ss0p72v25c.db \
		$pdk_dir/stdcell_rvt/db_ccs/saed14rvt_ss0p72vm40c.db \
	]
	
	set target_library [ list \
		$pdk_dir/stdcell_rvt/db_ccs/saed14rvt_ss0p72v25c.db \
	]
} elseif { $pdk == "saed32nm" } {
	set pdk_dir /home/tech/SAED32nm
	set link_library [ list * \
		$pdk_dir/lib/stdcell_rvt/db_ccs/saed32rvt_ss0p95v125c.db \
		$pdk_dir/lib/stdcell_rvt/db_ccs/saed32rvt_ss0p95v25c.db \
		$pdk_dir/lib/stdcell_rvt/db_ccs/saed32rvt_ss0p95vn40c.db \
	]
	
	set target_library [ list \
		$pdk_dir/lib/stdcell_rvt/db_ccs/saed32rvt_ss0p95v25c.db \
	]
} elseif { $pdk == "saed90nm" } {
	set pdk_dir /home/tech/SAED90nm_lib/SAED_EDK90nm
	set link_library [ list * \
		$pdk_dir/Digital_Standard_cell_Library/synopsys/models/saed90nm_max.db \
		$pdk_dir/Digital_Standard_cell_Library/synopsys/models/saed90nm_typ.db \
		$pdk_dir/Digital_Standard_cell_Library/synopsys/models/saed90nm_min.db \
	]
	
	set target_library [ list \
		$pdk_dir/Digital_Standard_cell_Library/synopsys/models/saed90nm_typ.db \
	]
} elseif { $pdk == "tsmc65nm" } {
	set pdk_dir /home/tech/TSMC65
	set db_dir $pdk_dir/TSMCHOME/digital/Front_End/timing_power_noise/CCS/tcbn65gplus_200a
	set link_library [ list * \
		$db_dir/tcbn65gplustc_ccs.db \
		$db_dir/tcbn65gpluswc_ccs.db \
		$db_dir/tcbn65gplusbc_ccs.db \
	]

	set target_library [ list \
		$db_dir/tcbn65gplustc_ccs.db \
	]
} elseif { $pdk == "tsmc28nm" } {
	set pdk_dir /home/tech/TSMC28
	set db_dir $pdk_dir/TSMCHOME/digital/Front_End/timing_power_noise/CCS/tcbn28hpcplusbwp30p140_180a
    set mem_dir $pdk_dir/TSMCHOME/sram/Compiler/tsn28hpcpd127spsram_20120200_180a/tsn28hpcpd127spsram_20120200_180a
	set link_library [ list \
		$db_dir/tcbn28hpcplusbwp30p140tt0p9v25c_ccs.db \
		$db_dir/tcbn28hpcplusbwp30p140ssg0p9v0c_ccs.db \
		$db_dir/tcbn28hpcplusbwp30p140ffg0p99v0c_ccs.db \
	]
        #$mem_dir/ts1n28hpcphvtb256x78m4s_tt0p9v25c.db \
    

	set target_library [ list \
		$db_dir/tcbn28hpcplusbwp30p140tt0p9v25c_ccs.db \
	]
}
set power_net VDD
set ground_net GND

#set_app_var command_log_file ./logs/command.log
#set_app_var view_command_log_file ./logs/view_command.log
#set_app_var sh_command_log_file ./logs/command.log
#set_app_var sh_output_log_file ./logs/output.log
