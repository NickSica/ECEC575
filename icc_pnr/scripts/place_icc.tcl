###########################################################################
### Placement
###########################################################################

set_buffer_opt_strategy -effort low

set_tlu_plus_files -max_tluplus $tlupmax -min_tluplus $tlupmin -tech2itf_map $tech2itf

##Goto Layout Window , Placement ' Core Placement and Optimization .  A new window opens up as shown below . There are various options, you can click on what ever option you want and say ok. The tool will do the placement. Alternatively you can also run at the command at icc_shell . Below is example with congestion option.

check_physical_design > $reports_dir/pre_place_check.rpt
report_ignored_layers > $reports_dir/pre_place_ignored_layers.rpt
place_opt_feasibility > $reports_dir/pre_place_opt_feasibility.rpt
create_qor_snapshot -name pre_place > $reports_dir/pre_place_qor.rpt

place_opt -skip_initial_placement -congestion -power

save_mw_cel -as place

### Reports 

report_placement_utilization > $reports_dir/place_util.rpt
report_qor_snapshot > $reports_dir/place_qor_snapshot.rpt
report_qor > $reports_dir/place_qor.rpt

report_power > $reports_dir/place_power.rpt

### Timing Report

report_timing -delay max -max_paths 20 > $reports_dir/place.setup.rpt
report_timing -delay min -max_paths 20 > $reports_dir/place.hold.rpt


