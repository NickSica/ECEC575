remove_corners -all
#read_parasitic_tech -tlup "$tlupmax $tlupmin" -layermap $tech2itf -name early_spec
read_parasitic_tech -tlup $tlupmax -layermap $tech2itf -name tlup_max
read_parasitic_tech -tlup $tlupmin -layermap $tech2itf -name tlup_min
#read_parasitic_tech -tlup $tlupnom -layermap $tech2itf -name tlup_nom

#set_parasitic_parameters -early_spec tlup_min -late_spec tlup_min -corners { fast }
#set_parasitic_parameters -early_spec tlup_max -late_spec tlup_max -corners { slow }

#create_mode test
#create_corner ss_25c
#create_scenario -name default.ss_m40c -mode default -corner ss_25c
#set_parasitic_parameters -early_spec tlup_min -late_spec tlup_min -corners { ss_25c }
set_parasitic_parameters -early_spec tlup_min -late_spec tlup_min
#set_operating_conditions -max_library saed32rvt_frame_timing_ccs -max ss0p95v25c -min_library saed32rvt_frame_timing_ccs -min ff0p95v25c
#set_operating_conditions -max_library saed32rvt_frame_timing_ccs -max ss0p95v25c -min_library saed32rvt_frame_timing_ccs -min ff0p95v25c

if { $pdk == "saed32nm" } {
    set_temperature 25
    set_process_number 0.99
    #set_process_label ss0p95v25c
    set_voltage 0.95 -object_list VDD
    ##set_voltage 0.95 -object_list VDDG
    set_voltage 0.00 -object_list VSS
} elseif { $pdk == "tsmc65nm" } {
    set_temperature 25
    set_process_number 0.99
    #set_process_label ss0p95v25c
    set_voltage 1 -object_list VDD
    ##set_voltage 0.95 -object_list VDDG
    set_voltage 0.00 -object_list VSS
} elseif { $pdk == "tsmc28nm" } {
    #set_temperature 25.00
    #set_process_number 1.00
    ##set_process_label ss0p95v25c
    set_voltage 0.90 -object_list VDD
    ###set_voltage 0.95 -object_list VDDG
    set_voltage 0.00 -object_list VSS
}

#source -echo [file join $root_dir icc2_pnr/constraints/ss_m40c.tcl]
read_sdc [file join $root_dir dc_synth/const/$top/$top.sdc]
update_timing



#set_extraction_options -late_ccap_threshold 0.0005 -early_ccap_threshold 0.0005 \
#	-honor_mask_constraints true \
#	-real_metalfill_extraction floating \
#	-virtual_shield_extraction false \
#	-corners { fast slow }
