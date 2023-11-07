set_parasitic_parameters -early_spec tlup_min -late_spec tlup_min -corners { ss_m40c }

set_temperature 25
set_process_number 0.99
set_process_label ss0p95v25c
set_voltage 0.95 -object_list VDD
#set_voltage 0.95 -object_list VDDG
set_voltage 0.00 -object_list VSS

