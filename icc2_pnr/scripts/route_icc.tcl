###########################################################################
### Routing
###########################################################################

##In the layout window, click on Route -> Core Routing and Optimization

route_opt 

##Save the cel and report timing

save_block -as ${lib_name}_route
#report_placement_utilization > reports/${lib_name}_route_util.rpt NOT A COMMAND
#report_qor_snapshot > reports/${lib_name}/${lib_name}_route_qor_snapshot.rpt
report_qor > $reports_dir/${lib_name}_route_qor.rpt
report_timing -max_paths 50 -delay max > $reports_dir/${lib_name}_route.setup.rpt
report_timing -max_paths 50 -delay min > $reports_dir/${lib_name}_route.hold.rpt

##POST ROUTE OPTIMIZATION STEPS

##Goto Layout Window, Route -> Verify Route
check_routes > $reports_dir/route_verify.rpt
