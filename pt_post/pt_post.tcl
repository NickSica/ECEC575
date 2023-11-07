###### Pre-Layout PrimeTime Script #######
source -echo ../set_env.tcl
set const_dir const/$top 

set icc_output ../icc_pnr/output/$top
set output_dir output/$top
set reports_dir reports/$top
set snapshot_dir snapshot/$top
set lib_dir lib
lappend search_path ../dc_synth/$output_dir

file mkdir $output_dir
file mkdir $reports_dir
file mkdir $snapshot_dir
file mkdir $lib_dir


## read the verilog files
read_verilog $icc_output/${top}_extracted.v

## Set top module name
link_design $top

## Read in the extracted parasitics
## Read in SDC from the synthesis 
## read in spef.max for setup time
## read in spef.min for hold time
read_parasitics -format SPEF "$icc_output/${top}_extracted.spef"


## Read in SDC from the extracted view
read_sdc ../dc_synth/const/$top/$top.sdc

## Analysis reports
report_timing > $reports_dir/timing_overview.rpt
report_qor > $reports_dir/qor.rpt
report_timing -from [all_inputs] -max_paths 20 -to [all_registers -data_pins] > $reports_dir/timing.rpt
report_timing -from [all_register -clock_pins] -max_paths 20 -to [all_registers -data_pins]  >> $reports_dir/timing.rpt
report_timing -from [all_registers -clock_pins] -max_paths 20 -to [all_outputs] >> $reports_dir/timing.rpt
report_timing -from [all_inputs] -to [all_outputs] -max_paths 20 >> $reports_dir/timing.rpt
report_timing -from [all_registers -clock_pins] -to [all_registers -data_pins] -delay_type max  >> $reports_dir/timing.rpt
##report_timing -from [all_registers -clock_pins] -to [all_registers -data_pins] -delay_type min  >> $reports_dir/timing.rpt

report_timing -transition_time -capacitance -nets -input_pins -from [all_registers -clock_pins] -to [all_registers -data_pins]  > $reports_dir/timing.tran.cap.rpt

## Save outputs
save_session $output_dir/$top.session
#exit
