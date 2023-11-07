###########################################################################
### Clock Tree Synthesis
###########################################################################

##In the Layout window, click on "Clock ", you will see various options, you can set any of the options to run CTS. If you click on Clock ' Core CTS and Optimization
clock_opt

##Save the Cell and report timing

save_block -as ${lib_name}_cts
#report_placement_utilization > reports/${lib_name}_cts_util.rpt NOT A COMMAND
#report_qor_snapshot > reports/${lib_name}_cts_qor_snapshot.rpt DOESNT WORK
report_qor > $reports_dir/${lib_name}_cts_qor.rpt
report_timing -max_paths 20 -delay max > $reports_dir/${lib_name}_cts.setup.rpt
report_timing -max_paths 20 -delay min > $reports_dir/${lib_name}_cts.hold.rpt

