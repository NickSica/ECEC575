###### DC Synth Script #######
#
lappend search_path ../src
source -echo ../set_env.tcl
set output_dir designs/$top

define_design_lib WORK -path $output_dir/work

## read the verilog files
analyze -format verilog dff.v
analyze -format verilog $top.v
elaborate -architecture verilog $top

link

check_design

file mkdir $output_dir/reports
file mkdir $output_dir/output
file mkdir $output_dir/const

# 100MHz
create_clock CK -name ideal_clock1 -period 10
# 500MHz
#create_clock CK -name ideal_clock1 -period 2
set_clock_latency 0.4 CK -clock ideal_clock1
set_clock_transition 0.1 ideal_clock1

set_input_delay 2 [ remove_from_collection [all_inputs] CK ] -clock ideal_clock1 
set_output_delay 2 [ all_outputs ] -clock ideal_clock1
set_clock_uncertainty 0.05 ideal_clock1
set_max_area 0
set_load 0.3 [ all_outputs ]

#create_power_domain pd
#create_supply_net VDD
#connect_supply_net VDD -ports VDD
#set_voltage 1 -object_list VDD

check_design > $output_dir/reports/synth_check_design.rpt
check_timing > $output_dir/reports/synth_check_timing.rpt

uniquify > $output_dir/reports/synth_uniquify.rpt

compile_ultra

report_area > $output_dir/reports/synth_area.rpt
report_power > $output_dir/reports/synth_power.rpt
report_qor > $output_dir/reports/synth_qor.rpt
report_cell > $output_dir/reports/synth_cells.rpt
report_resource > $output_dir/reports/synth_resources.rpt
report_timing > $output_dir/reports/timing_overview.rpt

## Analysis reports

report_timing -from [all_inputs] -max_paths 20 -to [all_registers -data_pins] > $output_dir/reports/timing.rpt
report_timing -from [all_register -clock_pins] -max_paths 20 -to [all_registers -data_pins]  >> $output_dir/reports/timing.rpt
report_timing -from [all_registers -clock_pins] -max_paths 20 -to [all_outputs] >> $output_dir/reports/timing.rpt
report_timing -from [all_inputs] -to [all_outputs] -max_paths 20 >> $output_dir/reports/timing.rpt
report_timing -from [all_registers -clock_pins] -to [all_registers -data_pins] -delay_type max  >> $output_dir/reports/timing.rpt
report_timing -from [all_registers -clock_pins] -to [all_registers -data_pins] -delay_type min  >> $output_dir/reports/timing.rpt

report_timing -transition_time -capacitance -nets -input_pins -from [all_registers -clock_pins] -to [all_registers -data_pins]  > $output_dir/reports/timing.tran.cap.rpt

write_sdc $output_dir/const/$top.sdc

write -hier -f verilog -output $output_dir/output/$top.v
write -hier -f ddc -output $output_dir/output/$top.ddc

exit
