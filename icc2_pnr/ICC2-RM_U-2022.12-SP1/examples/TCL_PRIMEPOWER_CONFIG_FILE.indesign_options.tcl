##########################################################################################
# Script: TCL_PRIMEPOWER_CONFIG_FILE.indesign_options.tcl (example)
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################

#Usage: set_indesign_primepower_options    # Sets the PrimePower analysis options for the Indesign PrimePower flow
#        -fsdbs list of {fsdb_file_name -weight -scaling_ratio -strip_path -path -time -format -analyze_scenarios -back_annotate_scenarios}
#                               (FSDB file(s) to analyze)
#        [-output_dir output_dir]
#                               (Output directory)
#        -pwr_shell pwr_shell_path
#                               (PrimePower executable)
#        [-db_libraries list of db_libs]
#                               (Additional libraries to be included)
#        [-num_processes num_processes]
#                               (Number of processes that should be launched: 
#                                Value >= 1)
#        [-max_cores max_cores] (Upper bound on number of cores to use per host instance: 
#                                Range: 1 to 260)
#        [-submit_command submit_cmd]
#                               (Command to submit processes for parallel execution)
#        [-host_names list of host_names]
#                               (Specify list of hosts on which to run processes)
#        [-advanced_fsdb_reader]
#                               (Enable advanced fsdb reader)
#        [-write_fsdb]          (Write the time based activity)
#        [-delay_shifted_event_analysis]
#                               (Enable delay shifted event analysis)
#        [-concurrent_event_analysis_max_process concurrent_analysis]
#                               (Specify parameter for concurrent analysis: 
#                                Value >= 1)

set_indesign_primpower_options -fsdbs { \
{ \
fsdb_file_name1 \
[-strip_path strip_path] \
[-path path] \
[-time time_window] \
[-scaling_ratio scaling_ratio] \
[-format format_type] \
[-analyze_scenarios scenarios_list] \
[-annotate_scenarios scenarios_list] \
[-weight <value>] \
} \
{ \
fsdb_file_name2 \
[-strip_path strip_path] \
[-path path] \
[-time time_window] \
[-scaling_ratio scaling_ratio] \
[-format format_type] \
[-analyze_scenarios scenarios_list] \
[-annotate_scenarios scenarios_list] \
[-weight <value>] \
} \
} \
-pwr_shell path_to_pwr_shell \
-max_cores max_cores 

