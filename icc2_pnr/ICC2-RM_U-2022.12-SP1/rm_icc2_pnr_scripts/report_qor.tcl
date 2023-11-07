##########################################################################################
# Script: report_qor.tcl
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################


if {[info exists REPORT_STAGE]} {
    puts "RM-info: Reporting stage set to ${REPORT_STAGE}" 
} else {
    puts "RM-error: Reporting stage variable REPORT_STAGE is not defined"
} 

   if {[info exists REPORT_ACTIVE_SCENARIOS] && $REPORT_ACTIVE_SCENARIOS != ""} {
           set_scenario_status -active false [get_scenarios -filter active]
           set_scenario_status -active true $REPORT_ACTIVE_SCENARIOS
   } 

########################################################################
## non-SI reporting at route_auto stage  
########################################################################
if {$REPORT_DEBUG && [regexp ^route $REPORT_STAGE]} {
        if {[get_app_option_value -name time.si_enable_analysis]} {
                set RM_current_value_enable_si true
        }
        puts "RM-info: time.si_enable_analysis is set to false ...\n"
        set_app_options -name time.si_enable_analysis -value false

        puts "RM-info: Reporting timing and QoR in non-SI mode ...\n"
        ## QoR
        redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/no_si.report_qor {report_qor -scenarios [get_scenarios -filter active] -nosplit}
        redirect -tee -append -file ${REPORTS_DIR}/${REPORT_PREFIX}/no_si.report_qor {report_qor -summary -nosplit}

        ## Timing (-variation enabled for POCV)
        if {[get_app_option_value -name time.pocvm_enable_analysis]} {
                redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/no_si.report_timing.max {report_timing -delay max -scenarios [get_scenarios -filter active] \
                -input_pins -nets -transition_time -capacitance -attributes -physical -derate -report_by group -variation -nosplit}
                redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/no_si.report_timing.no_variation.max {report_timing -delay max -scenarios [get_scenarios -filter active] \
                -input_pins -nets -transition_time -capacitance -attributes -physical -derate -report_by group -nosplit}
        } else {
                redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/no_si.report_timing.max {report_timing -delay max -scenarios [get_scenarios -filter active] \
                -input_pins -nets -transition_time -capacitance -attributes -physical -derate -report_by group -nosplit}
        }

        ## Restore user default of time.si_enable_analysis
        if {[info exists RM_current_value_enable_si] && ${RM_current_value_enable_si}} {
                set_app_options -name time.si_enable_analysis -value true
        }
}
####################################
## Timing and QoR 
####################################
puts "RM-info: Reporting timing and QoR ...\n"

## Show special inbuilt path groups **async_default** and **clock_gating_default** in timing report 
## Note: User specified path groups has higher precedence than these. (global-scoped)
#	set_app_options -name time.use_special_default_path_groups -value true ;# tool default false

## QoR
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_qor {report_qor -scenarios [get_scenarios -filter active] -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit}
redirect -tee -append -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_qor {report_qor -summary -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit}
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/proc_qor {proc_qor -pba_mode [get_app_option_value -name time.pba_optimization_mode]}

## global timing 
redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_global_timing {report_global_timing -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit}

## Timing (-variation enabled for POCV)
if {[get_app_option_value -name time.pocvm_enable_analysis]} {
	redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_timing.no_variation.max {report_timing -delay max -scenarios [get_scenarios -filter active] \
        -input_pins -nets -transition_time -capacitance -attributes -physical -derate -crosstalk -report_by group -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit}
	redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_timing.max {report_timing -delay max -scenarios [get_scenarios -filter active] \
	-input_pins -nets -transition_time -capacitance -attributes -physical -derate -crosstalk -report_by group -pba_mode [get_app_option_value -name time.pba_optimization_mode] -variation -nosplit}

	foreach_in_collection scenario [get_scenarios -filter {active && setup}] {
		set scenario_name [get_object_name $scenario]
		redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_timing.max.end.${scenario_name} {report_timing -delay max -path end -nosplit -max_paths 5000 -scenarios ${scenario_name}}
		if {$REPORT_VERBOSE} {
			redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_timing.max.${scenario_name} {report_timing -delay max -scenarios ${scenario_name} -path_type full_clock_expanded -variation \
        		-input_pins -nets -transition_time -capacitance -attributes -physical -derate -crosstalk -report_by group -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit -max_paths 300 -slack_lesser_than 0.0}
                	redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_timing.no_variation.max.${scenario_name} {report_timing -delay max -scenarios ${scenario_name} -path_type full_clock_expanded \
                	-input_pins -nets -transition_time -capacitance -attributes -physical -derate -crosstalk -report_by group -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit -max_paths 300 -slack_lesser_than 0.0}
		}
	}	
} else {
	redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_timing.max {report_timing -delay max -scenarios [get_scenarios -filter active] \
	-input_pins -nets -transition_time -capacitance -attributes -physical -derate -crosstalk -report_by group -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit}

	foreach_in_collection scenario [get_scenarios -filter {active && setup}] {
		set scenario_name [get_object_name $scenario]
		redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_timing.max.end.${scenario_name} {report_timing -delay max -path end -nosplit -max_paths 5000 -scenarios ${scenario_name}}
		if {$REPORT_VERBOSE} {
			redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_timing.max.${scenario_name} {report_timing -delay max -scenarios ${scenario_name} -path_type full_clock_expanded \
        		-input_pins -nets -transition_time -capacitance -attributes -physical -derate -crosstalk -report_by group -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit -max_paths 300 -slack_lesser_than 0.0}
		}
	}
}

# Min timing report is generated in postcts (-variation enabled for POCV)
if {![regexp init_design|mapped|synthesis|placement $REPORT_STAGE]} {
	if {[get_app_option_value -name time.pocvm_enable_analysis]} {
                redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_timing.no_variation.min {report_timing -delay min -scenarios [get_scenarios -filter active] \
                -input_pins -nets -transition_time -capacitance -attributes -physical -derate -crosstalk -report_by group -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit}
		redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_timing.min {report_timing -delay min -scenarios [get_scenarios -filter active] \
		-input_pins -nets -transition_time -capacitance -attributes -physical -derate -crosstalk -report_by group -pba_mode [get_app_option_value -name time.pba_optimization_mode] -variation -nosplit}

		foreach_in_collection scenario [get_scenarios -filter {active && hold}] {
			set scenario_name [get_object_name $scenario]
			redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_timing.min.end.${scenario_name} {report_timing -delay min -path end -nosplit -max_paths 5000 -scenarios ${scenario_name}}
			if {$REPORT_VERBOSE} {
				redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_timing.min.${scenario_name} {report_timing -delay min -scenarios ${scenario_name} -path_type full_clock_expanded -variation \
        			-input_pins -nets -transition_time -capacitance -attributes -physical -derate -crosstalk -report_by group -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit -max_paths 300 -slack_lesser_than 0.0}
                        	redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_timing.no_variation.min.${scenario_name} {report_timing -delay min -scenarios ${scenario_name} -path_type full_clock_expanded \
                        	-input_pins -nets -transition_time -capacitance -attributes -physical -derate -crosstalk -report_by group -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit -max_paths 300 -slack_lesser_than 0.0}
			}
		}
	} else {
		redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_timing.min {report_timing -delay min -scenarios [get_scenarios -filter active] \
		-input_pins -nets -transition_time -capacitance -attributes -physical -derate -crosstalk -report_by group -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit}

		foreach_in_collection scenario [get_scenarios -filter {active && hold}] {
			set scenario_name [get_object_name $scenario]
			redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_timing.min.end.${scenario_name} {report_timing -delay min -path end -nosplit -max_paths 5000 -scenarios ${scenario_name}}
			if {$REPORT_VERBOSE} {
				redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_timing.min.${scenario_name} {report_timing -delay min -scenarios ${scenario_name} -path_type full_clock_expanded \
        			-input_pins -nets -transition_time -capacitance -attributes -physical -derate -crosstalk -report_by group -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit -max_paths 300 -slack_lesser_than 0.0}
			}
		}
	}
}

## Constraint violations
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_constraint {report_constraint -all_violators -max_transition -max_capacitance -scenarios [get_scenarios -filter active] -nosplit}

## Debugging
puts "RM-info: Analyzing design violations ...\n"
# analyze_design_violations for setup
# The command will automatically add "type" (ie, setup or hold) as part of the report name
# For example, the report name for setup type would be ${REPORTS_DIR}/${REPORT_PREFIX}/analyze_design_violations.setup
if {[regexp synthesis|placement|post_cts_opt $REPORT_STAGE]} {
	analyze_design_violations -type setup -stage preroute -output ${REPORTS_DIR}/${REPORT_PREFIX}/analyze_design_violations
} elseif {[regexp post_route $REPORT_STAGE]} {
	analyze_design_violations -type setup -stage postroute -output ${REPORTS_DIR}/${REPORT_PREFIX}/analyze_design_violations
}

# analyze_design_violations for hold
if {[regexp post_cts_opt $REPORT_STAGE]} {
	analyze_design_violations -type hold -stage preroute -output ${REPORTS_DIR}/${REPORT_PREFIX}/analyze_design_violations
} elseif {[regexp post_route $REPORT_STAGE]} {
	analyze_design_violations -type hold -stage postroute -output ${REPORTS_DIR}/${REPORT_PREFIX}/analyze_design_violations
}

if {[regexp synthesis|mapped $REPORT_STAGE]} {
        redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_transformed_registers {report_transformed_registers -nosplit}
        redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_clock_gating {report_clock_gating -nosplit}
        redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_resources {report_resources -nosplit}
        redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_logic_levels {report_logic_levels -nosplit}
        redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_dft {report_dft -nosplit}
	redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_activity.rtl {report_activity -rtl}
	redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_activity.driver.end {report_activity -driver}
}
if {![regexp init_design|synthesis|mapped $REPORT_STAGE]} {
	redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_activity {report_activity -verbose}
}
####################################
## Clock tree QoR
####################################
if {![regexp init_design|mapped|synthesis|placement $REPORT_STAGE]} {
	puts "RM-info: Reporting clock tree information and QoR ...\n"
	redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_clock_qor.summary {report_clock_qor -nosplit}
	parallel_execute {
		{report_clock_qor -type latency -show_paths -nosplit} ${REPORTS_DIR}/${REPORT_PREFIX}/report_clock_qor.latency
		{report_clock_qor -type area -nosplit} ${REPORTS_DIR}/${REPORT_PREFIX}/report_clock_qor.cell_area
		{report_clock_qor -type structure -nosplit} ${REPORTS_DIR}/${REPORT_PREFIX}/report_clock_qor.structure
		{report_clock_qor -type drc_violators -all -nosplit} ${REPORTS_DIR}/${REPORT_PREFIX}/report_clock_qor.drc_violators
		{report_clock_timing -type summary -clock_synthesis_view -scenarios [get_scenarios -filter active] -nosplit} ${REPORTS_DIR}/${REPORT_PREFIX}/report_clock_timing.summary
		{report_clock_timing -type skew -clock_synthesis_view -scenarios [get_scenarios -filter active] -nosplit} ${REPORTS_DIR}/${REPORT_PREFIX}/report_clock_timing.skew
		{report_clock_timing -type latency -clock_synthesis_view -scenarios [get_scenarios -filter active] -nosplit} ${REPORTS_DIR}/${REPORT_PREFIX}/report_clock_timing.latency 
	}
	if {[get_app_option_value -name cts.compile.enable_local_skew] || [get_app_option_value -name cts.optimize.enable_local_skew] || [get_app_option_value -name clock_opt.flow.enable_ccd]} {\
		redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_clock_qor.local_skew {report_clock_qor -type local_skew -nosplit}
	}
}
if {$REPORT_CLOCK_POWER && [regexp cts|post_route $REPORT_STAGE]} { 
	if {[sizeof_collection [get_scenarios -filter "active && (dynamic_power || leakage_power)"]] > 0} {
		puts "RM-info: Running report_clock_qor -type power ...\n"
		redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_clock_qor.power {report_clock_qor -type power -nosplit}
	}
}
####################################
## Power 
####################################
if {![regexp init_design $REPORT_STAGE]} {
	redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_threshold_voltage_group {report_threshold_voltage_group -nosplit}
}

if {$REPORT_QOR_REPORT_POWER} { 
	puts "RM-info: Running report_power ...\n"
	## For hierarchical designs, use report_power -blocks to get the power consumption for the top and sub-blocks separately
	if {$USE_ABSTRACTS_FOR_BLOCKS != "" && $USE_ABSTRACTS_FOR_POWER_ANALYSIS == "true"} {
		redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_power {report_power -blocks -verbose -scenarios [get_scenarios -filter active] -nosplit}
	} else {
		redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_power {report_power -verbose -scenarios [get_scenarios -filter active] -nosplit}
	}

	
	set power_scenarios [get_scenarios -filter "leakage_power==true||dynamic_power==true"]
	if { [sizeof_collection $power_scenarios] > 0 } {
	  puts "RM-info: Running report_power ...\n"

	  ## Activate inactive power scenarios
	  if { [sizeof_collection [filter $power_scenarios "active==false"]] > 0 } {
	    set inactive_power_scenarios [filter $power_scenarios "active==false"]
	    set_scenario_status $inactive_power_scenarios -active true
	  } else {
	    set inactive_power_scenarios {}
	  }

	  ## Retrieve all power scenarios
	  set power_scenarios [get_scenarios -filter "leakage_power==true||dynamic_power==true"]

	  ## With REPORT_POWER_SAIF_FILE
	  if {$REPORT_POWER_SAIF_FILE != ""} {
	    if { [file exists [which ${REPORT_POWER_SAIF_FILE}]] } {
	      ## Source saif_map if it exists
	      if { [file exists [which $REPORT_POWER_SAIF_MAP]] } {
	        saif_map -read $REPORT_POWER_SAIF_MAP
	      }

	      ## read_saif
	      reset_switching_activity -scenarios $power_scenarios
	      set scaling_factor  [lindex [sh zgrep TIMESCALE $REPORT_POWER_SAIF_FILE ] 1]
	      puts "RM-info: Running read_saif ${REPORT_POWER_SAIF_FILE} -scaling_ratio $scaling_factor -strip_path $SAIF_FILE_SOURCE_INSTANCE -scenarios [get_object_name $power_scenarios]"
	      read_saif {{$REPORT_POWER_SAIF_FILE -scaling_ratio $scaling_factor}} -strip_path $SAIF_FILE_SOURCE_INSTANCE -scenarios $power_scenarios
	
	      ## report the amount of annotation that was propagated
	      redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_power {report_activity -driver -show_zeros -verbose -scenarios $power_scenarios }
	
	      ## set app options to align with PT
	      set_app_option -name power.default_toggle_rate -value 0.0
	      set_app_option -name power.default_static_probability -value 0.0
	      set_app_option -name power.propagation_effort -value high
	      set_app_option -name power.use_ccs_rcv_cap -value true
	      set_app_option -name power.use_enhanced_multidriven_net_driver_type -value true
	      set_app_option -name power.include_primary_input_swcap -value true

	      ## report_power	    
	      puts "RM-info: Running report_power with REPORT_POWER_SAIF_FILE ($REPORT_POWER_SAIF_FILE) ...\n"
	      redirect -tee -append -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_power {report_power -verbose -scenarios $power_scenarios -nosplit}
	    } else {
	      puts "RM-error: REPORT_POWER_SAIF_FILE ($REPORT_POWER_SAIF_FILE) is invalid. Please correct it. report_power is skipped"
	    }

	  ## Without REPORT_POWER_SAIF_FILE
	  } else {
	    redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_power {report_power -verbose -scenarios $power_scenarios -nosplit}
	  }

	  ## Restore active status
	  if { [sizeof_collection $inactive_power_scenarios] > 0 } {
	    set_scenario_status $inactive_power_scenarios -active false
	  }

	} else {
          puts "RM-info: No power scenarios found. Skipping report_power."
	}
}
####################################
## Timing Constraints 
####################################
puts "RM-info: Reporting timing constraints ...\n"
parallel_execute {
	{report_modes -nosplit} ${REPORTS_DIR}/${REPORT_PREFIX}/report_modes
	{report_pvt -nosplit} ${REPORTS_DIR}/${REPORT_PREFIX}/report_pvt
	{report_corners [all_corners]} ${REPORTS_DIR}/${REPORT_PREFIX}/report_corners
}
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_scenarios {report_scenarios -nosplit}
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_clocks {report_clocks -mode [all_modes] -nosplit}


####################################
## MV
####################################
# check_mv_design -erc_mode and -power_connectivity
	redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_mv_design.erc_mode {check_mv_design -erc_mode}
	redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_mv_design {check_mv_design} ;# check_mv_design is also covered by check_design
        redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_pg_connectivity {check_pg_connectivity}

if {[regexp init_design $REPORT_STAGE]} {
        redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_power_domains {report_power_domains -nosplit}
        redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_voltage_areas {report_voltage_areas -nosplit}
        redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_power_scopes {report_power_scopes -nosplit}
        redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_pst {report_pst -nosplit}
        redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_supply_set {report_supply_set -nosplit}
}

# check_mv_design -erc_mode and -power_connectivity 
#	redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_mv_design.power_connectivity {check_mv_design -power_connectivity}

redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_mv_path {report_mv_path -all_not_associated}

####################################
## report_design  
####################################
puts "RM-info: Reporting design information ...\n"
if {[regexp cts|post_cts_opt|route|post_route $REPORT_STAGE]} {
	redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_design {report_design -library -netlist -floorplan -routing -nosplit}
} else {
	redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_design {report_design -library -netlist -floorplan -nosplit}
	redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_tracks {report_tracks -nosplit}
}

set rm_lib_type [get_attribute -quiet [current_design] rm_lib_type]
if {$rm_lib_type != ""} {puts "RM-info: rm_lib_type = $rm_lib_type"}
if { [regexp {h$} $rm_lib_type] } { 
        create_utilization_configuration no_physical -capacity site_row -exclude {hard_macros macro_keepouts soft_macros io_cells hard_blockages physical_only_cells}
	redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_utilization {report_utilization -hybrid -config no_physical}
} else {
	redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_utilization {report_utilization}
}

redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_reference {report_reference -hierarchical -nosplit}
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_ignored_layers {report_ignored_layers}
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_extraction_options {report_extraction_options -corners [all_corners]}
####################################
## check_design, check_netlist & check_legality 
####################################
puts "RM-info: Checking design issues ...\n"
#DJYEN CHECK IF WE NEED

## The following lines are applicable for hierarchical designs with abstracts
# The following enables checking consistency of timing constraints between top and sub-blocks
if {$USE_ABSTRACTS_FOR_BLOCKS != ""} {
   if { $CHECK_HIER_TIMING_CONSTRAINTS_CONSISTENCY == "true" } {
       set_app_options -name abstract.check_constraints_consistency -value true
   } elseif { $CHECK_HIER_TIMING_CONSTRAINTS_CONSISTENCY == "false" } {
       set_app_options -name abstract.check_constraints_consistency -value false
   }
}

## Run the pre-defined mega-check pre_placement_stage which includes
#  atomic checks such as mv_design, design_mismatch, rp_constraints, timing, and scan chain.
if {[regexp init_design $REPORT_STAGE]} {
	redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_design.pre_placement_stage {check_design -ems_database check_design.pre_placement_stage.ems -checks pre_placement_stage}
	redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_netlist {check_netlist -summary}
}

## Run the pre-defined mega-check pre_clock_tree_stage which includes
#  atomic checks such as mv_design, design_mismatch, timing, scan chain, legality, design_extraction, and clock tree.
if {[regexp synthesis|placement $REPORT_STAGE]} {
    redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_design.pre_clock_tree_stage {check_design -ems_database check_design.pre_clock_tree_stage.ems -checks pre_clock_tree_stage}
}
## Report Early Data Check Results
if {$EARLY_DATA_CHECK_POLICY != "none"} {
	redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_early_data_checks.list_of_checks {report_early_data_checks -policy}
	redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_early_data_checks.rpt {report_early_data_checks -verbose}
}

## Run check_variants
if {![regexp init_design $REPORT_STAGE]} {
        redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_variants.end {check_variants -dont_use -included_purposes}
}

## Run check_legality
if {![regexp init_design $REPORT_STAGE]} {
	redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_legality {check_legality -verbose}
}  
####################################
## MISC  
####################################
puts "RM-info: Reporting units ...\n"
if {[regexp init_design $REPORT_STAGE]} {
	redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_units {report_units -nosplit}
	redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_user_units {report_user_units -nosplit}
}

puts "RM-info: Reporting non-default app option settings ...\n"
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_app_options.end {report_app_options -non_default *}
puts "RM-info: Reporting size_only and dont_touch information ...\n"
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_size_only {report_size_only -all}
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_dont_touch {report_dont_touch -all}
puts "RM-info: Reporting ideal_network information ...\n"
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_ideal_network {report_ideal_network -scenarios [get_scenarios -filter active]}

########################################################################
## Additional Zero interconnect delay reporting at init_design stage  
########################################################################
#DJYEN Need to check if this should be default
if {$REPORT_DEBUG && [regexp init_design $REPORT_STAGE]} {
	puts "RM-info: time.delay_calculation_style is set to zero_interconnect ...\n"
	# To restore user settings later
	set RM_current_value_high_fanout_net_pin_capacitance [get_app_option_value -name time.high_fanout_net_pin_capacitance]
	set RM_current_value_high_fanout_net_threshold [get_app_option_value -name time.high_fanout_net_threshold]

	set_app_options -name time.delay_calculation_style -value zero_interconnect ;# tool default auto
	set_app_options -name time.high_fanout_net_pin_capacitance -value 0pF ;# tool default 1pF
	set_app_options -name time.high_fanout_net_threshold -value 100 ;# tool default 1000

	puts "RM-info: Reporting timing and QoR in zero_interconnect mode with zero pin cap ...\n"
	## QoR
	redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/zwlm.report_qor {report_qor -scenarios [get_scenarios -filter active] -nosplit}
	redirect -tee -append -file ${REPORTS_DIR}/${REPORT_PREFIX}/zwlm.report_qor {report_qor -summary -nosplit}
	
	## Timing (-variation enabled for POCV)
	if {[get_app_option_value -name time.pocvm_enable_analysis]} {
		redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/zwlm.report_timing.max {report_timing -delay max -scenarios [get_scenarios -filter active] \
		-input_pins -nets -transition_time -capacitance -attributes -physical -derate -report_by group -variation -nosplit}
                redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/zwlm.report_timing.no_variation.max {report_timing -delay max -scenarios [get_scenarios -filter active] \
                -input_pins -nets -transition_time -capacitance -attributes -physical -derate -report_by group -nosplit}
	} else {
		redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/zwlm.report_timing.max {report_timing -delay max -scenarios [get_scenarios -filter active] \
		-input_pins -nets -transition_time -capacitance -attributes -physical -derate -report_by group -nosplit}
	}

	puts "RM-info: time.delay_calculation_style is reset...\n"
	reset_app_options time.delay_calculation_style
	set_app_options -name time.high_fanout_net_pin_capacitance -value $RM_current_value_high_fanout_net_pin_capacitance
	set_app_options -name time.high_fanout_net_threshold -value $RM_current_value_high_fanout_net_threshold
}
########################################################################
## report_drc_error after route_auto
########################################################################
if {[regexp route|post_route $REPORT_STAGE]} {
	if {[get_drc_error_data -quiet zroute.err] == ""} {open_drc_error_data zroute.err}
	redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_drc {report_drc_error -error_data zroute.err}
	redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/rm_report_drc {rm_report_drc}
}

########################################################################
## report_congestion and global route congestion map 
########################################################################
if {$REPORT_QOR_REPORT_CONGESTION && [regexp synthesis|placement|cts|post_cts_opt $REPORT_STAGE]} {
	set_app_options -name route.global.timing_driven -value true	
	#DJYEN need to check
	if {![regexp post_cts_opt $REPORT_STAGE]} {
		redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_congestion {report_congestion -layers [get_layers -filter "layer_type==interconnect"] -rerun_global_router -nosplit}
	} else {
        	redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_congestion {report_congestion -layers [get_layers -filter "layer_type==interconnect"] -nosplit}
	}
	if {[info exists env(DISPLAY)]} {
		gui_start
		#gui_execute_menu_item -menu "View->Layout View"
		gui_execute_menu_item -menu "View->Map->Global Route Congestion"
		gui_write_window_image -format png -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_congestion.png
		gui_stop
	} else {
		puts "RM-info: env(DISPLAY) is not defined. Global route congestion map snapshot is skipped."
	}
}


####################################
## write_qor_data
####################################
if {$WRITE_QOR_DATA} {
        set QOR_DATA_LABEL $REPORT_PREFIX 
	if {[regexp init_design $REPORT_STAGE]} {
		## No op
	} elseif {[regexp synthesis|placement $REPORT_STAGE]} {
		write_qor_data -report_group placed -label $QOR_DATA_LABEL -output $WRITE_QOR_DATA_DIR -exclude_list "performance host_machine report_app_options" 
	} elseif {[regexp init_design|mapped $REPORT_STAGE]} {
		write_qor_data -report_group mapped -label $QOR_DATA_LABEL -output $WRITE_QOR_DATA_DIR -exclude_list "performance host_machine report_app_options" 
	} elseif {[regexp cts|post_cts_opt $REPORT_STAGE]} {
		write_qor_data -report_group cts -label $QOR_DATA_LABEL -output $WRITE_QOR_DATA_DIR -exclude_list "performance host_machine report_app_options" 
	} else {
		write_qor_data -report_group routed -label $QOR_DATA_LABEL -output $WRITE_QOR_DATA_DIR -exclude_list "performance host_machine report_app_options" 
	}
	
	## write_qor_data lite for sequential reporting
	#	write_qor_data -report_list "host_machine report_app_options report_utilization report_design wirelength" -label $QOR_DATA_LABEL -output $WRITE_QOR_DATA_DIR

	if {![regexp init_design $REPORT_STAGE]} {
		compare_qor_data -run_locations $WRITE_QOR_DATA_DIR -force -output $COMPARE_QOR_DATA_DIR
        }

## Run the pre-defined mega-check pre_route_stage which includes
#  atomic checks such as mv_design, design_mismatch, timing, scan chain, design_extraction, and routeability. 
if {[regexp post_cts_opt $REPORT_STAGE]} {
	redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_design.pre_route_stage {check_design -ems_database check_design.pre_route_stage.ems -checks pre_route_stage}
   }

}

########################################################################
## Other reporting commands 
########################################################################
## report_ccd_timing : Reports CCD timing information of a design
## - To Print D slacks and Q slacks of the top 5 critical endpoints
##   (D slack : worst slack of the paths captured by a flop)
##   (Q slack : worst slack of the paths lauched by a flop)
##	report_ccd_timing 
## - To report slacks of timing paths that precede or succeed a critical end point with a specified stage number up/down the chain
##	report_ccd_timing -type stage -pin <pin> -max_stages <integer>
## - To report top 5 timing paths in the fanin(fanout) cone of a critical end point
##	report_ccd_timing -type fanin -pin <pin>

rm_source -file $TCL_USER_SUPPLEMENTAL_REPORTS_SCRIPT -optional -print TCL_USER_SUPPLEMENTAL_REPORTS_SCRIPT

if {$REPORT_PARALLEL_SUBMIT_COMMAND != ""} {
        echo [date] > report_done
}


