###### DC Synth Script #######
#
source -echo ../set_env.tcl
lappend search_path ${incl_dirs}
set const_dir     const/${top}
set reports_dir reports/${top}
set output_dir   output/${top}
set const_dir     const/${top}
set work_dir       work/${top}

define_design_lib WORK -path $work_dir

## read the verilog files
#analyze -format verilog $top.v
#analyze -library WORK -format verilog $mem_dir/ts1n28hpcphvtb256x78m4s_180a_tt0p9v25c.v
analyze -library WORK -format sverilog ${pkg_files}
read_file -library WORK -autoread -recursive -top ibex_top ../src/ \
          -param RV32M=>"RV32MSingleCycle",RV32B=>"RV32BFull",RegFile=>"RegFileFF",BranchTargetALU=>1'b1,WritebackStage=>1'b1,ICache=>1'b1,ICacheECC=>1'b1,ICacheScramble=>1'b0,BranchPredictor=>1'b0,DbgTriggerEn=>1'b0,SecureIbex=>1'b0,PMPEnable=>1'b1,PMPGranularity=>0,PMPNumRegions=>16,MHPMCounterNum=>0,MHPMCounterWidth=>40

rename_design [current_design] $top
current_design $top

link

check_design

file mkdir $reports_dir
file mkdir $output_dir
file mkdir $const_dir

set clk clk_i

create_clock $clk -name ideal_clock1 -period 4.6
set_clock_latency 0.4 $clk -clock ideal_clock1
set_clock_transition 0.1 ideal_clock1

set_input_delay 0.4 [ remove_from_collection [all_inputs] $clk ] -clock ideal_clock1 
set_output_delay 0.4 [ all_outputs ] -clock ideal_clock1
set_clock_uncertainty 0.05 ideal_clock1
set_max_area 0
set_load 0.3 [ all_outputs ]

#create_power_domain pd
#create_supply_net VDD
#connect_supply_net VDD -ports VDD
#set_voltage 1 -object_list VDD

check_design > $reports_dir/synth_check_design.rpt
check_timing > $reports_dir/synth_check_timing.rpt

uniquify > $reports_dir/synth_uniquify.rpt

compile_ultra

report_area > $reports_dir/synth_area.rpt
report_power > $reports_dir/synth_power.rpt
report_qor > $reports_dir/synth_qor.rpt
report_cell > $reports_dir/synth_cells.rpt
report_resource > $reports_dir/synth_resources.rpt
report_timing > $reports_dir/timing_overview.rpt

## Analysis reports

report_timing -from [all_inputs] -max_paths 20 -to [all_registers -data_pins] > $reports_dir/timing.rpt
report_timing -from [all_register -clock_pins] -max_paths 20 -to [all_registers -data_pins]  >> $reports_dir/timing.rpt
report_timing -from [all_registers -clock_pins] -max_paths 20 -to [all_outputs] >> $reports_dir/timing.rpt
report_timing -from [all_inputs] -to [all_outputs] -max_paths 20 >> $reports_dir/timing.rpt
report_timing -from [all_registers -clock_pins] -to [all_registers -data_pins] -delay_type max  >> $reports_dir/timing.rpt
report_timing -from [all_registers -clock_pins] -to [all_registers -data_pins] -delay_type min  >> $reports_dir/timing.rpt

report_timing -transition_time -capacitance -nets -input_pins -from [all_registers -clock_pins] -to [all_registers -data_pins]  > $reports_dir/timing.tran.cap.rpt

change_names -rules verilog

write -hier -f verilog -output $output_dir/$top.v
write -hier -f ddc -output $output_dir/$top.ddc

write_sdc $const_dir/$top.sdc

exit
