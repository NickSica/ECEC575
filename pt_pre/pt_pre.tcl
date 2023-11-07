###### Pre-Layout PrimeTime Script #######

source -echo ../set_env.tcl
set output_dir  output/$top
set reports_dir reports/$top
set const_dir   const/$top
lappend search_path ../dc_synth/$output_dir

file mkdir $output_dir
file mkdir $reports_dir
file mkdir $const_dir

## read the verilog files
read_verilog $top.v

## Set top module name
link_design $top

## Read in SDC from the synthesis
read_sdc ../dc_synth/$const_dir/$top.sdc

## Analysis reports
report_qor > $reports_dir/pt_qor.rpt

report_timing > $reports_dir/timing_overview.rpt
report_timing -from [all_inputs] -max_paths 20 -to [all_registers -data_pins] > $reports_dir/timing.rpt
report_timing -from [all_register -clock_pins] -max_paths 20 -to [all_registers -data_pins]  >> $reports_dir/timing.rpt
report_timing -from [all_registers -clock_pins] -max_paths 20 -to [all_outputs] >> $reports_dir/timing.rpt
report_timing -from [all_inputs] -to [all_outputs] -max_paths 20 >> $reports_dir/timing.rpt
report_timing -from [all_registers -clock_pins] -to [all_registers -data_pins] -delay_type max  >> $reports_dir/timing.rpt
report_timing -from [all_registers -clock_pins] -to [all_registers -data_pins] -delay_type min  >> $reports_dir/timing.rpt

report_timing -transition_time -capacitance -nets -input_pins -from [all_registers -clock_pins] -to [all_registers -data_pins]  > $reports_dir/timing.tran.cap.rpt

## Save outputs
save_session $output_dir/fifo.session

exit

