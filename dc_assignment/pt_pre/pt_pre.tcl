###### Pre-Layout PrimeTime Script #######

source ../set_env.tcl
set output_dir designs/$top
lappend search_path ../dc_synth/$output_dir/output

file mkdir $output_dir/reports
file mkdir $output_dir/const
file mkdir $output_dir/output

## read the verilog files
read_verilog $top.v

## Set top module name
link_design $top

## Read in SDC from the synthesis
read_sdc ../dc_synth/$output_dir/const/$top.sdc

## Analysis reports
report_qor > $output_dir/reports/pt_qor.rpt

report_timing > $output_dir/reports/timing_overview.rpt
report_timing -from [all_inputs] -max_paths 20 -to [all_registers -data_pins] > $output_dir/reports/timing.rpt
report_timing -from [all_register -clock_pins] -max_paths 20 -to [all_registers -data_pins]  >> $output_dir/reports/timing.rpt
report_timing -from [all_registers -clock_pins] -max_paths 20 -to [all_outputs] >> $output_dir/reports/timing.rpt
report_timing -from [all_inputs] -to [all_outputs] -max_paths 20 >> $output_dir/reports/timing.rpt
report_timing -from [all_registers -clock_pins] -to [all_registers -data_pins] -delay_type max  >> $output_dir/reports/timing.rpt
report_timing -from [all_registers -clock_pins] -to [all_registers -data_pins] -delay_type min  >> $output_dir/reports/timing.rpt

report_timing -transition_time -capacitance -nets -input_pins -from [all_registers -clock_pins] -to [all_registers -data_pins]  > $output_dir/reports/timing.tran.cap.rpt

## Save outputs
save_session $output_dir/output/fifo.session

exit

