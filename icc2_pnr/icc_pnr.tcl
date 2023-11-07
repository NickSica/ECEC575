set root_dir [file dirname [file dirname [info script]]]
source -echo [file join $root_dir set_env.tcl]

# const dir only used for dc_synth folder no need to create
#set const_dir       const/${top}_no_sram
#set output_dir     output/${top}_no_sram
#set reports_dir   reports/${top}_no_sram
#set snapshot_dir snapshot/${top}_no_sram
#set lib_name              ${top}_no_sram

set const_dir       const/${top}_old
set output_dir     output/${top}_old
set reports_dir   reports/${top}_old
set snapshot_dir snapshot/${top}_old
set lib_name              ${top}_old

set lib_dir lib

lappend search_path ../dc_synth/$output_dir
set_app_options -name lib.configuration.icc_shell_exec -value "/home/tools/synopsys/icc/Q-2019.12-SP1/bin/icc_shell"

set_host_options -max_cores 32

file mkdir $output_dir
file mkdir $reports_dir
file mkdir $snapshot_dir
file mkdir $lib_dir

if { $pdk == "saed14nm" } {
	set libdir "$pdk_dir/tech/star_rc"
	set tlupmax "$libdir/max/saed14nm_1p9m_Cmax.tluplus"
	set tlupnom "$libdir/nominal/saed14nm_1p9m_nominal.tluplus"
	set tlupmin "$libdir/min/saed14nm_1p9m_Cmin.tluplus"
	set tech2itf "$libdir/saed14nm_tf_itf_tluplus.map"
	
	set techfile "$pdk_dir/tech/milkyway/saed14nm_1p9m_mw.tf"
	set ref_lib "$pdk_dir/stdcell_rvt/ndm/saed14rvt_frame_timing_ccs.ndm"
} elseif { $pdk == "saed32nm" } {
	set libdir "$pdk_dir/tech/star_rcxt"
	set tlupmax "$libdir/saed32nm_1p9m_Cmax.tluplus"
	set tlupnom "$libdir/saed32nm_1p9m_nominal.tluplus"
	set tlupmin "$libdir/saed32nm_1p9m_Cmin.tluplus"
	set tech2itf "$libdir/saed32nm_tf_itf_tluplus.map"
	
	#set techfile "$pdk_dir/tech/milkyway/saed32nm_1p9m_mw.tf"
	set techfile "$pdk_dir/lib/stdcell_rvt/ndm/tf/saed32nm_1p9m_mw.tf"
	#set ref_lib "$pdk_dir/lib/stdcell_rvt/ndm/saed32rvt_frame_only.ndm"
	set ref_lib "$pdk_dir/lib/stdcell_rvt/ndm/saed32rvt_frame_timing_ccs.ndm"
} elseif { $pdk == "saed90nm" } {
	set libdir "$pdk_dir/Technology_Kit/process/star_rcxt"
	set tlupmax "$libdir/tluplus/saed90nm_1p9m_1t_Cmax.tluplus"
	set tlupnom "$libdir/tluplus/saed90nm_1p9m_1t_nominal.tluplus"
	set tlupmin "$libdir/tluplus/saed90nm_1p9m_1t_Cmin.tluplus"
	set tech2itf "$libdir/saed90nm.map"

	set techfile $pdk_dir/Technology_Kit/techfile/saed90nm_1p9m.tf
	set ref_lib $pdk_dir/Digital_Standard_Cell_Library/synopsys/plib/
} elseif { $pdk == "tsmc65nm" } {
	set libdir "$pdk_dir/TSMCHOME/6x1z1u_icc_files/RC_TLUplus_crn65lp_1p9m_6x1z1u_alrdl_5corners_1.0a"
	set tlupnom "$libdir/RC_TLUplus_crn65lp_1p09m+alrdl_6x1z1u_typical/crn65lp_1p09m+alrdl_6x1z1u_typical.tluplus"
	set tlupmin "$libdir/RC_TLUplus_crn65lp_1p09m+alrdl_6x1z1u_cworst/crn65lp_1p09m+alrdl_6x1z1u_cworst.tluplus"
	set tlupmax "$libdir/RC_TLUplus_crn65lp_1p09m+alrdl_6x1z1u_cbest/crn65lp_1p09m+alrdl_6x1z1u_cbest.tluplus"
	set tech2itf "$pdk_dir/TSMCHOME/digital/Back_End/milkyway/tcbn65gplus_200a/techfiles/tluplus/star.map_9M"

	set techfile $pdk_dir/TSMCHOME/6x1z1u_icc_icc2_tech_files/PRTF_ICC_65nm_001_Syn_V24a/PR_tech/Synopsys/TechFile/VHV/PRTF_ICC_N65_9M_6X1Z1U_RDL.24a.tf
	#set ref_lib ../lc_shell/tsmc65nm.ndm
	set ref_lib [file join $root_dir lm_shell/tsmc65nm.ndm]
} elseif { $pdk == "tsmc28nm" } {
	set libdir "$pdk_dir/APR_Tech/Synopsys/RC_TLUplus_crn28hpc+_1p9m_6x1z1u_ut-alrdl_9corners_1.3p1a"
	set tlupnom "$libdir/RC_TLUplus_crn28hpc+_1p09m+ut-alrdl_6x1z1u_typical/crn28hpc+_1p09m+ut-alrdl_6x1z1u_typical.tluplus"
	set tlupmin "$libdir/RC_TLUplus_crn28hpc+_1p09m+ut-alrdl_6x1z1u_rcworst/crn28hpc+_1p09m+ut-alrdl_6x1z1u_rcworst.tluplus"
	set tlupmax "$libdir/RC_TLUplus_crn28hpc+_1p09m+ut-alrdl_6x1z1u_rcbest/crn28hpc+_1p09m+ut-alrdl_6x1z1u_rcbest.tluplus"
	set tech2itf "$pdk_dir/PDK/TSMC_iPDK/CCI/CCI_decks/starrcxt_mapping"
	set techfile "$pdk_dir/APR_Tech/Synopsys/tn28clpr002s1_1_9_1a/PRTF_ICC_28nm_Syn_V19_1a/tsmcn28_9lm6X1Z1UUTRDL.tf"
	#set ndm [file join $root_dir lm_shell/tsmc28nm.ndm]
	#set ndm /home/tech/TSMC28/TSMCHOME/digital/Back_End/milkyway/tcbn28hpcplusbwp30p140_110a/cell_frame_VHV_0d5_0/tcbn28hpcplusbwp30p140
    #set ndm ../icc_pnr/icc2_frame/ndm/ibex_top.mw_merge_db_physical_only.ndm
    set ndm ../icc_pnr/icc2_frame/ndm/ibex_top.mw_frame_only.ndm
	#set ref_lib [list $ndm $mem_dir/ts1n28hpcphvtb256x78m4s_c.ndm]
	set ref_lib $ndm 
}


set_svf -off
open_lib $lib_name.dlib
open_block ${lib_name}_extracted
#if { ![info exists top_script] } {
	#source -echo scripts/init_design.tcl
	#source -echo scripts/floorplan_icc.tcl
	#source -echo scripts/place_icc.tcl
	#source -echo scripts/cts_icc.tcl
	#source -echo scripts/route_icc.tcl
	#source -echo scripts/extract_icc.tcl
#}
start_gui
