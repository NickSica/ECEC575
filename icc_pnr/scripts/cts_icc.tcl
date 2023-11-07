###########################################################################
### Clock Tree Synthesis
############################################################################

report_clock_tree > $reports_dir/pre_cts_tree.rpt


##In the Layout window, click on "Clock ", you will see various options, you can set any of the options to run CTS. If you click on Clock ' Core CTS and Optimization
clock_opt -only_cts
#set_fix_hold ideal_clock1
report_clock_tree > $reports_dir/pre_clock_route_tree.rpt

#clock_opt -only_psyn -area_recovery -no_clock_route
#route_zrt_group -all_clock_nets -reuse_existing_global_route true

report_constraints > $reports_dir/cts_constraints.rpt
all_ideal_nets > $reports_dir/cts_ideal_nets.rpt
all_high_fanout -nets -threshold 500 > $reports_dir/cts_high_fanout.rpt
check_legality > $reports_dir/cts_check_legality.rpt
verify_pg_nets > $reports_dir/cts_verify_pg_nets.rpt

##Save the Cell and report timing

save_mw_cel -as cts
report_placement_utilization > $reports_dir/cts_util.rpt
report_qor_snapshot > $reports_dir/cts_qor_snapshot.rpt
report_qor > $reports_dir/cts_qor.rpt
report_timing -max_paths 20 -delay max > $reports_dir/cts.setup.rpt
report_timing -max_paths 20 -delay min > $reports_dir/cts.hold.rpt

