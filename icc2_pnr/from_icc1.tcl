source ../set_env.tcl

set lib_name $top_file
set_app_options -name lib.configuration.icc_shell_exec -value /home/tools/synopsys/icc/T-2022.03-SP4/bin/icc_shell
if { $pdk == "saed32nm" } {
	set libdir "$pdk_dir/tech/star_rcxt"
	set tlupmax "$libdir/saed32nm_1p9m_Cmax.tluplus"
	set tlupnom "$libdir/saed32nm_1p9m_nominal.tluplus"
	set tlupmin "$libdir/saed32nm_1p9m_Cmin.tluplus"
	set tech2itf "$libdir/saed32nm_tf_itf_tluplus.map"
	
	set techfile "../icc_pnr/icc2_frame/data/TF/fifo.mw.tf"
	#set techfile "$pdk_dir/tech/milkyway/saed32nm_1p9m_mw.tf"
	#set ref_lib "../lc/SAED32nm.ndm"
	#set ref_lib "../lm_shell/saed32nm/saed32rvt_ss0p95v_c.ndm"
	#set ref_lib "../lm_shell/saed32nm.ndm"
	set ref_lib [ glob "../icc_pnr/icc2_frame/ndm/*.ndm" ]
	#set ref_lib "../icc_pnr/icc2_frame/ndm/saed32rvt_ss0p95v_c.ndm"
	#set ref_lib "../lc_shell/saed32nm/saed32nm_rvt_1p9m.ndm"
	#set ref_lib "$pdk_dir/lib/stdcell_rvt/lef"
	#set ref_lib "$pdk_dir/lib/stdcell_rvt/milkyway/saed32nm_rvt_1p9m"
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
	#set techfile $pdk_dir/TSMCHOME/6x1z1u_icc_icc2_tech_files/PRTF_ICC_65nm_001_Syn_V24a/PR_tech/Synopsys/TechFile/VHV/PRTF_ICC_N65_9M_6X1Z1U_RDL.24a.tf
	set techfile $pdk_dir/TSMCHOME/6x1z1u_icc_icc2_tech_files/PRTF_ICC_65nm_001_Syn_V24a/PR_tech/Synopsys/TechFile/VHV/PRTF_ICC_N65_9M_6X1Z1U_RDL.24a.tf
	#set ref_lib $pdk_dir/TSMCHOME/digital/Back_End/milkyway/tcbn65gplus_200a/cell_frame/tcbn65gplus
	#set ref_lib "../icc_pnr/icc2_frame/ndm/saed32rvt_ss0p95v_c.ndm"
	set ref_lib [ glob "../icc_pnr/icc2_frame/ndm/*.ndm" ]
}

if { ![file exists $lib_name.dlib] } {
	create_lib $lib_name.dlib \
		-technology $techfile
	set_ref_libs -ref_libs $ref_lib
}
open_lib $lib_name.dlib

#set design_data ../dc_synth/output/fifo.ddc
set cell_name "FIFO"
#import_designs $design_data -format ddc -top $cell_name

set logic0_net VSS
set logic1_net VDD

read_verilog -top FIFO ../icc_pnr/icc1_to_icc2/from_icc1.v

link_block

read_sdc ../dc_synth/const/fifo.sdc

save_block -as ${lib_name}_initial
source -echo ../icc_pnr/icc1_to_icc2/from_icc1_fp.tcl
source -echo ../icc_pnr/icc1_to_icc2/from_icc1_cstr.tcl
source -echo ../icc_pnr/icc1_to_icc2/from_icc1_cstr_cts_setup.tcl
source -echo ../icc_pnr/icc1_to_icc2/from_icc1_tim_context/top.tcl

