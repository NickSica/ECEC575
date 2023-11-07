###########################################################################
### Routing
###########################################################################

##In the layout window, click on Route -> Core Routing and Optimization
route_opt -initial_route_only 
create_qor_snapshot -name initial_route > $reports_dir/pre_route_qor.rpt
route_opt -skip_initial_route

##Save the cel and report timing

save_mw_cel -as route
report_placement_utilization > $reports_dir/route_util.rpt
report_qor_snapshot > $reports_dir/route_qor_snapshot.rpt
report_qor > $reports_dir/route_qor.rpt
report_power > $reports_dir/route_power.rpt
report_timing -max_paths 50 -delay max > $reports_dir/route.setup.rpt
report_timing -max_paths 50 -delay min > $reports_dir/route.hold.rpt

##POST ROUTE OPTIMIZATION STEPS

##Goto Layout Window, Route -> Verify Route
verify_zrt_route

