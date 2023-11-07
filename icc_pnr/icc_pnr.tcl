source -echo ../set_env.tcl

# const dir only used for dc_synth folder no need to create
set const_dir const/$top 

set output_dir output/$top
set reports_dir reports/$top
set snapshot_dir snapshot/$top
set lib_dir lib
lappend search_path ../dc_synth/$output_dir

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
	set ref_lib "$pdk_dir/stdcell_rvt/milkyway/saed14nm_rvt_1p9m"
} elseif { $pdk == "saed32nm" } {
	set libdir "$pdk_dir/tech/star_rcxt"
	set tlupmax "$libdir/saed32nm_1p9m_Cmax.tluplus"
	set tlupnom "$libdir/saed32nm_1p9m_nominal.tluplus"
	set tlupmin "$libdir/saed32nm_1p9m_Cmin.tluplus"
	set tech2itf "$libdir/saed32nm_tf_itf_tluplus.map"

	set techfile "$pdk_dir/tech/milkyway/saed32nm_1p9m_mw.tf"
	set ref_lib "$pdk_dir/lib/stdcell_rvt/milkyway/saed32nm_rvt_1p9m"
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
	set tech2itf "/home/tech/TSMC65/TSMCHOME/digital/Back_End/milkyway/tcbn65gplus_200a/techfiles/tluplus/star.map_9M"

	set techfile $pdk_dir/TSMCHOME/6x1z1u_icc_icc2_tech_files/PRTF_ICC_65nm_001_Syn_V24a/PR_tech/Synopsys/TechFile/VHV/PRTF_ICC_N65_9M_6X1Z1U_RDL.24a.tf
	set ref_lib $pdk_dir/TSMCHOME/digital/Back_End/milkyway/tcbn65gplus_200a/cell_frame/tcbn65gplus
} elseif { $pdk == "tsmc28nm" } {
	set libdir "$pdk_dir/APR_Tech/Synopsys/RC_TLUplus_crn28hpc+_1p9m_6x1z1u_ut-alrdl_9corners_1.3p1a"
	set tlupnom "$libdir/RC_TLUplus_crn28hpc+_1p09m+ut-alrdl_6x1z1u_typical/crn28hpc+_1p09m+ut-alrdl_6x1z1u_typical.tluplus"
	set tlupmin "$libdir/RC_TLUplus_crn28hpc+_1p09m+ut-alrdl_6x1z1u_rcworst/crn28hpc+_1p09m+ut-alrdl_6x1z1u_rcworst.tluplus"
	set tlupmax "$libdir/RC_TLUplus_crn28hpc+_1p09m+ut-alrdl_6x1z1u_rcbest/crn28hpc+_1p09m+ut-alrdl_6x1z1u_rcbest.tluplus"
	set tech2itf "$pdk_dir/PDK/TSMC_iPDK/CCI/CCI_decks/starrcxt_mapping"
	set techfile "$pdk_dir/APR_Tech/Synopsys/tn28clpr002s1_1_9_1a/PRTF_ICC_28nm_Syn_V19_1a/tsmcn28_9lm6X1Z1UUTRDL.tf"
	#set techfile "$pdk_dir/APR_Tech/Synopsys/tn28clpr002s1_1_9_1a/PRTF_ICC_28nm_Syn_V19_1a/PR_tech/Synopsys/TechFile/HVH/tsmcn28_9lm6X1Z1UUTRDL.tf"
	#set ndm [file join $root_dir lm_shell/tsmc28nm.ndm]
	set ndm /home/tech/TSMC28/TSMCHOME/digital/Back_End/milkyway/tcbn28hpcplusbwp30p140_110a/cell_frame_VHV_0d5_0/tcbn28hpcplusbwp30p140
	set ref_lib [list $ndm $mem_dir/ts1n28hpcphvtb256x78m4s_c.ndm]
}

set icc_snapshot_storage_location $snapshot_dir

#open_mw_lib lib/ibex_top.mw
#open_mw_cel place
source -echo scripts/init_design.tcl
source -echo scripts/floorplan_icc.tcl
source -echo scripts/place_icc.tcl
source -echo scripts/cts_icc.tcl
source -echo scripts/route_icc.tcl
source -echo scripts/extract_icc.tcl
#exit
