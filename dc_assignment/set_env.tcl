#set designs {s1238 s15850 s35932 s386 s9234}
if { [info exists ::env(TOP)] } {
	set top $::env(TOP) 
} else {
	set top s9234
}

## Define the library location
set link_library [ list * \
	/mnt/class_data/ecec574-w2019/PDKs/SAED32nm/lib/stdcell_rvt/db_ccs/saed32rvt_ss0p95v125c.db \
	/mnt/class_data/ecec574-w2019/PDKs/SAED32nm/lib/stdcell_rvt/db_ccs/saed32rvt_ss0p95v25c.db \
	/mnt/class_data/ecec574-w2019/PDKs/SAED32nm/lib/stdcell_rvt/db_ccs/saed32rvt_ss0p95vn40c.db \
]

set target_library [ list /mnt/class_data/ecec574-w2019/PDKs/SAED32nm/lib/stdcell_rvt/db_ccs/saed32rvt_ss0p95v25c.db ]

set mv_power_net VDD
set mw_ground_net GND
set mw_logic1_net VDD
set mw_logic0_net GND
set mw_power_port VDD
set mw_ground_port GND

#set_app_var command_log_file ./logs/command.log
#set_app_var view_command_log_file ./logs/view_command.log
#set_app_var sh_command_log_file ./logs/command.log
#set_app_var sh_output_log_file ./logs/output.log
