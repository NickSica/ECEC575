source -echo ../set_env.tcl

# const dir only used for dc_synth folder no need to create
set const_dir const/$top 

set output_dir output/$top
set reports_dir reports/$top
set snapshot_dir snapshot/$top
set lib_dir lib
lappend search_path ../dc_synth/$output_dir

file mkdir $output_dir
file mkdir $reports_dir
file mkdir $snapshot_dir
file mkdir $lib_dir

set icc_snapshot_storage_location $snapshot_dir

set libdir "/mnt/class_data/ecec574-w2019/PDKs/SAED32nm/tech/star_rcxt"
set tlupmax "$libdir/saed32nm_1p9m_Cmax.tluplus"
set tlunom "$libdir/saed32nm_1p9m_nominal.tluplus"
set tlupmin "$libdir/saed32nm_1p9m_Cmin.tluplus"
set tech2itf "$libdir/saed32nm_tf_itf_tluplus.map"
set_tlu_plus_files -max_tluplus $tlunom -tech2itf_map $tech2itf

set techfile "/mnt/class_data/ecec574-w2019/PDKs/SAED32nm/tech/milkyway/saed32nm_1p9m_mw.tf"
set ref_lib "/mnt/class_data/ecec574-w2019/PDKs/SAED32nm/lib/stdcell_rvt/milkyway/saed32nm_rvt_1p9m"
set lib_name $top.mw

open_mw_lib $lib_dir/$lib_name

open_mw_cel fifo_route

source -echo scripts/extract_icc.tcl
