set SNPS_ROUTE_AS_CHILD_START_TIME [clock seconds]
set phys_hier_attr_mode DC_ATTR
suppress_message {OBS-004 PWR-18 }
set_message_info -id CMD-013 -limit 0
set_message_info -id UCN-32 -limit 0
set_message_info -id TIM-112 -limit 0
set_message_info -id RCEX-202 -limit 0
set_message_info -id RCEX-013 -limit 0
set_message_info -id PSYN-850 -limit 0
set_message_info -id DPI-025 -limit 0
set_message_info -id RCEX-011 -limit 0
set_message_info -id PSYN-523 -limit 0
set_message_info -id PSYN-1042 -limit 0
set_message_info -id PSYN-605 -limit 0
set_message_info -id UPF-213 -limit 10
set_message_info -id RCEX-015 -limit 0
set_message_info -id RCEX-018 -limit 0
set_message_info -id CMD-025 -limit 0
set_message_info -id DPI-029 -limit 0
set_message_info -id PSYN-1111 -limit 0
set_message_info -id PSYN-1099 -limit 0
set_message_info -id PSYN-308 -limit 0
set_message_info -id LINT-52 -limit 0
set_message_info -id PSYN-864 -limit 0
set_message_info -id PNR-159 -limit 0
set_message_info -id IFS-007 -limit 0
set_message_info -id MWUI-004 -limit 0
set_message_info -id CTS-375 -limit 0
set_message_info -id RCEX-023 -limit 0
set_message_info -id UID-85 -limit 0
set_message_info -id SEL-002 -limit 0
set_message_info -id UID-83 -limit 0
set_message_info -id UPF-213d -limit 10
set_message_info -id SEL-004 -limit 0
set_message_info -id UPF-213e -limit 10
set_message_info -id MWDC-217 -limit 0
set_message_info -id UPF-213f -limit 10
set_message_info -id HFS-802 -limit 0
set_message_info -id MWDC-119 -limit 0
set_message_info -id UPF-213a -limit 10
set_message_info -id PSYN-878 -limit 0
set_message_info -id MWDC-118 -limit 0
set_message_info -id UPF-213b -limit 10
set_message_info -id TIM-134 -limit 0
set_message_info -id TIM-176 -limit 0
set_message_info -id PNR-165 -limit 0
set_message_info -id VFP-425 -limit 0
set_message_info -id UPF-213c -limit 10
set_message_info -id PSYN-508 -limit 0
set_message_info -id ROPT-028 -limit 0
set_message_info -id PNR-164 -limit 0
set_message_info -id MWLIBP-300 -limit 0
set_message_info -id PWR-536 -limit 0
set_message_info -id RCEX-141 -limit 0
set_message_info -id CTS-152 -limit 0
set_message_info -id UPF-710 -limit 1
set_message_info -id ROPT-020 -limit 0
set_message_info -id UIG-5 -limit 0
set_message_info -id MW-336 -limit 0
set_message_info -id PSYN-476 -limit 0
set_message_info -id PNR-133 -limit 0
set_message_info -id LINT-5 -limit 0
set_message_info -id PNR-131 -limit 0
set_message_info -id CTS-1121 -limit 0
set_message_info -id LINT-31 -limit 0
set_message_info -id LINT-33 -limit 0
set_message_info -id LINT-32 -limit 0
set_message_info -id LINT-2 -limit 0
set_message_info -id LINT-3 -limit 0
set_message_info -id RCEX-043 -limit 0
set_message_info -id RCEX-081 -limit 0
set_message_info -id MW-339 -limit 0
set_message_info -id RCEX-042 -limit 0
set_message_info -id RCEX-041 -limit 0
set_message_info -id OPT-1505 -limit 0
set_message_info -id CTS-103 -limit 0
set_message_info -id RCEX-040 -limit 0
set_message_info -id LINT-8 -limit 0
set_message_info -id RCEX-047 -limit 0
set_message_info -id RCEX-007 -limit 0
set_message_info -id UID-349 -limit 0
set_message_info -id TIM-270 -limit 0
set_message_info -id PSYN-054 -limit 0
set_message_info -id DPI-030 -limit 0
set_message_info -id CTS-1115 -limit 0
set_message_info -id PWR-414 -limit 0
set_message_info -id PWR-415 -limit 0
set_message_info -id RCEX-008 -limit 0
set_message_info -id MWLIBP-324 -limit 0
set_message_info -id TIM-024 -limit 0
set_message_info -id TIM-025 -limit 0
set_message_info -id PWR-6 -limit 0
set_message_info -id MWNL-111 -limit 0
set_message_info -id PWR-24 -limit 0
set_message_info -id UIED-114 -limit 0
set search_path ". /home/tools/synopsys/icc/T-2022.03-SP4/libraries/syn /home/tools/synopsys/icc/T-2022.03-SP4/dw/syn_ver /home/tools/synopsys/icc/T-2022.03-SP4/dw/sim_ver ../dc_synth/output/ibex_top"
set physical_library ""
set target_library "/home/tech/TSMC65/TSMCHOME/digital/Front_End/timing_power_noise/CCS/tcbn65gplus_200a//tcbn65gplustc_ccs.db"
set link_library "* /home/tech/TSMC65/TSMCHOME/digital/Front_End/timing_power_noise/CCS/tcbn65gplus_200a//tcbn65gplustc_ccs.db /home/tech/TSMC65/TSMCHOME/digital/Front_End/timing_power_noise/CCS/tcbn65gplus_200a//tcbn65gpluswc_ccs.db /home/tech/TSMC65/TSMCHOME/digital/Front_End/timing_power_noise/CCS/tcbn65gplus_200a//tcbn65gplusbc_ccs.db"
set mw_reference_library ""
set enable_set_units FALSE 
open_mw_lib /home/sica/ECEC575/icc_pnr/lib/ibex_top.mw
open_working_copy_mw_cel ibex_top -version 3
set_separate_process_options -routing false
set_route_zrt_common_options -timing_file /home/sica/ECEC575/icc_pnr/lib/ibex_top.mw/ROUTE/ibex_top.1040319.tim
set routeopt_xtalk_reduction_tns true
set ropt_habefast 3
set_route_zrt_global_options -timing_driven true
set_route_zrt_track_options -timing_driven true
set_route_zrt_detail_options -timing_driven true
set neco_file_name /tmp/neco_POUbYG
set_host_options  -max_cores 16
route_zrt_auto  -max_detail_route_iterations 10
pass_working_copy_mw_cel_back
set SNPS_ROUTE_AS_CHILD_END_TIME [clock seconds]
set SNPS_CPUTIME [cputime -self -child]
set SNPS_ELAPSED_TIME [expr $SNPS_ROUTE_AS_CHILD_END_TIME - $SNPS_ROUTE_AS_CHILD_START_TIME]
set SNPS_CPUTIME_hr [expr $SNPS_CPUTIME/3600.0]
set SNPS_ELAPSED_TIME_hr [expr $SNPS_ELAPSED_TIME/3600.0]
set SNPS_MEMORY_Mb [expr [mem]/1024]
set SNPS_CPU_MEM_LOG_FORMAT "%-30s CPU: %6d s (%5.2f hr) ELAPSE: %6d s (%5.2f hr) MEM-PEAK: %5lu Mb "
set SNPS_CPU_MEM_LOG_OUT [format $SNPS_CPU_MEM_LOG_FORMAT "CHILD_PROC: Router" $SNPS_CPUTIME $SNPS_CPUTIME_hr $SNPS_ELAPSED_TIME $SNPS_ELAPSED_TIME_hr $SNPS_MEMORY_Mb ]
 set fileId [open proc_end_1040319 w 0600]
puts $fileId "/home/sica/ECEC575/icc_pnr/route_route_zrt_auto_1040319.tcl $SNPS_CPU_MEM_LOG_OUT"
close $fileId
quit
