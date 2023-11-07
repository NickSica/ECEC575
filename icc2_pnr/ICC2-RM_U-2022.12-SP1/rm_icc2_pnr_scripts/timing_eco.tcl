##########################################################################################
# Script: eco_opt.tcl
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################

source ./rm_utilities/procs_global.tcl 
source ./rm_utilities/procs_icc2.tcl 
rm_source -file ./rm_setup/design_setup.tcl
rm_source -file ./rm_setup/icc2_pnr_setup.tcl
rm_source -file ./rm_setup/header_icc2_pnr.tcl
rm_source -file sidefile_setup.tcl -after_file technology_override.tcl
set PREVIOUS_STEP $TIMING_ECO_FROM_BLOCK_NAME
set CURRENT_STEP  $TIMING_ECO_BLOCK_NAME
if { [info exists env(RM_VARFILE)] } {
	if { [file exists $env(RM_VARFILE)] } {
		rm_source -file $env(RM_VARFILE)
	} else {
		puts "RM-error: env(RM_VARFILE) specified but not found"
	}
}

set REPORT_PREFIX $CURRENT_STEP
file mkdir ${REPORTS_DIR}/${REPORT_PREFIX}
puts "RM-info: PREVIOUS_STEP = $PREVIOUS_STEP"
puts "RM-info: CURRENT_STEP  = $CURRENT_STEP"
puts "RM-info: REPORT_PREFIX = $REPORT_PREFIX"
redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/run_start.rpt {run_start}   

rm_source -file $TCL_PVT_CONFIGURATION_FILE -optional -print "TCL_PVT_CONFIGURATION_FILE"

open_lib $DESIGN_LIBRARY
copy_block -from ${DESIGN_NAME}/${PREVIOUS_STEP} -to ${DESIGN_NAME}/${CURRENT_STEP}
current_block ${DESIGN_NAME}/${CURRENT_STEP}
link_block

if {$TIMING_ECO_ACTIVE_SCENARIO_LIST != ""} {
	set_scenario_status -active false [get_scenarios -filter active]
	set_scenario_status -active true $TIMING_ECO_ACTIVE_SCENARIO_LIST
}

## Adjustment file for modes/corners/scenarios/models to applied to each step (optional)
rm_source -file $TCL_MODE_CORNER_SCENARIO_MODEL_ADJUSTMENT_FILE -optional -print "TCL_MODE_CORNER_SCENARIO_MODEL_ADJUSTMENT_FILE"

rm_source -file $SIDEFILE_TIMING_ECO_1 -optional -print "SIDEFILE_TIMING_ECO_1" ;# node/foundry specific

## Non-persistent settings to be applied in each step (optional)
rm_source -file $TCL_USER_NON_PERSISTENT_SCRIPT -optional -print "TCL_USER_NON_PERSISTENT_SCRIPT"

####################################
## Pre-PT ECO customizations
####################################
rm_source -file $TCL_USER_TIMING_ECO_PRE_SCRIPT -optional -print "TCL_USER_TIMING_ECO_PRE_SCRIPT"

redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_app_options.start {report_app_options -non_default *}
redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_lib_cell_purpose {report_lib_cell -objects [get_lib_cells] -column {full_name:20 valid_purposes}}

if {$ENABLE_INLINE_REPORT_QOR} {
   redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_qor.start {report_qor -scenarios [all_scenarios] -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit}
   redirect -append -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_qor.start {report_qor -summary -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit}
   redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_global_timing.start {report_global_timing -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit}
}

#########################################
## Check for necessary ECO fusion license
#########################################
## This check is for ICCII as Fusion Compiler license includes the fusion features.
if {(![check_license -quiet "Digital-AF"])} {
	puts "RM-error: Required license "Digital-AF" was not detected.  Exiting..."
	
	exit
	
}
## Verify that PT/Tweaker binary is setup.
if {$ECO_OPT_ENGINE == "tweaker"} {
  if {$ECO_OPT_EXEC_PATH != ""} {
    set eco_exec_image $ECO_OPT_EXEC_PATH
  } else {
    set eco_exec_image [ exec which tweaker ]
  }
  set pt_image [ exec which pt_shell ]
} else {
  if {$ECO_OPT_EXEC_PATH != ""} {
    set eco_exec_image $ECO_OPT_EXEC_PATH
  } else {
    set eco_exec_image [ exec which pt_shell ]
  }
  set pt_image $eco_exec_image
}

if { ($ECO_OPT_ENGINE == "pt" || $ECO_OPT_ENGINE == "primeeco") && ([ file tail $eco_exec_image ] != "pt_shell") } {
	puts "RM-error: Unable to find \"[ file tail $eco_exec_image ]\".  Exiting."
	
	exit
	
} elseif {($ECO_OPT_ENGINE == "tweaker" ) && ([ file tail $eco_exec_image ] != "tweaker") && ([ file tail $pt_image ] != "pt_shell")} {
	puts "RM-error: Unable to find the binary. Please check the twekaer or PT exec path. Exiting."
	
	exit
	
}

################################################
## Set PT options
################################################
# ECO fusion ease of use 
# You can reuse existing standalone PT signoff scripts in ECO fusion with required modifications,
# including preparing your scenario setup scripts, making edits in the scripts for ECO fusion compatability, etc.
# The rest of the steps are the same as below.  
# For details, refer to FC training materials on the ECO fusion Ease of Use feature.

## PT requires the usage of timing DB's.  Need to include directory in the search path.
if {$ECO_OPT_DB_PATH != ""} {lappend search_path $ECO_OPT_DB_PATH}

## Path to PT executable.
set set_pt_options_cmd "set_pt_options -pt_exec $pt_image"

## Optionally define the number of cores per scenario for PT DMSA.
if {$ECO_OPT_PT_CORES_PER_SCENARIO !=""} {
  set_host_options -name eco_opt_host_option -max_cores $ECO_OPT_PT_CORES_PER_SCENARIO localhost
  lappend set_pt_options_cmd -host_option eco_opt_host_option
}

## Optionally specify a PT pre link script.
if {[file exists [which $ECO_OPT_PRE_LINK_SCRIPT]]} {
	lappend set_pt_options_cmd -pre_link_script $ECO_OPT_PRE_LINK_SCRIPT
} elseif {$ECO_OPT_PRE_LINK_SCRIPT != ""} {
	puts "RM-error: ECO_OPT_PRE_LINK_SCRIPT($ECO_OPT_PRE_LINK_SCRIPT) is invalid. Please correct it."
}

## Optionally specify a PT post link script.
if {[file exists [which $ECO_OPT_POST_LINK_SCRIPT]]} {
	lappend set_pt_options_cmd -post_link_script $ECO_OPT_POST_LINK_SCRIPT
} elseif {$ECO_OPT_POST_LINK_SCRIPT != ""} {
	puts "RM-error: ECO_OPT_POST_LINK_SCRIPT($ECO_OPT_POST_LINK_SCRIPT) is invalid. Please correct it."
}

## Optionally provide scenario constraints for PT.
if {$ECO_OPT_SIGNOFF_SCENARIO_PAIR != ""} {
	lappend set_pt_options_cmd -scenario_constraint $ECO_OPT_SIGNOFF_SCENARIO_PAIR
}

## Capture full string except working directory to be used in post ECO PT reporting.
set pre_eco_pt_options $set_pt_options_cmd

## Specify the eco_opt work directory.
lappend set_pt_options_cmd -work_dir eco_opt_dir_1

puts "RM-info: Running $set_pt_options_cmd"
eval $set_pt_options_cmd
redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_pt_options {report_pt_options}

################################################
## set extraction mode: StarRC in-design or native tool
################################################
## Three extraction modes, fusion_adv, in_design, or none.
## - Ensure StarRC config file is setup if using "fusion_adv" or "in_design" extraction modes.
## - This is setup via ECO_OPT_STARRC_CONFIG_FILE.

## Capture pre eco_opt extraction mode for later restoration.
set extraction_mode [get_app_option_value -name extract.starrc_mode]
set_app_options -name extract.starrc_mode -value $ECO_OPT_EXTRACTION_MODE

if {$ECO_OPT_EXTRACTION_MODE == "fusion_adv" || $ECO_OPT_EXTRACTION_MODE == "in_design"} {
	if {[file exists [which $ECO_OPT_STARRC_CONFIG_FILE]]} {
		puts "RM-info: Running with STARRC extraction"
		set_starrc_options -config $ECO_OPT_STARRC_CONFIG_FILE ;# example: route_opt.starrc_config_example.txt
		redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_starrc_options.rpt {report_starrc_options} 
	} else {
		puts "RM-error: ECO_OPT_STARRC_CONFIG_FILE is invalid. Exiting..."
	
	exit
	
	}
}

################################################
## Check if design is clean
################################################
## If design is not clean, eco_opt QoR will be impacted. Please check the reports and make sure the design is clean first.
redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/pre_check_legality.rpt {check_legality}
redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/pre_check_routes.rpt {check_routes}

################################################
## Optionally, enable PBA
################################################
if {$ECO_OPT_WITH_PBA} {
	## time.pba_optimization_mode enables path-based analysis during route_opt; tool default false;
	## you can also set it to exhaustive to apply an exhaustive path search algorithm to determine worst pba path to an endpoint;
	set_app_options -name time.pba_optimization_mode -value path 	
}

################################################
## Check and show PT QoR prior to eco_opt
################################################
## Use "check_pt_qor -help" to check all the available options of check_pt_qor
set check_pt_qor_cmd "check_pt_qor"
if {$ECO_OPT_WITH_PBA} {lappend check_pt_qor_cmd -pba_mode [get_app_option_value -name time.pba_optimization_mode]}
redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_pt_qor.pre.rpt $check_pt_qor_cmd
redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_pt_qor.pre.summary.rpt "$check_pt_qor_cmd -type summary"

################################################
## Perform ECO
################################################
## ECOs can be run either via eco_opt or a user provided PT change file.
##	Configure PT_ECO_CHANGE_FILE to NULL to run "eco_opt".
##
##	Congfiure PT_ECO_CHANGE_FILE to point to and implement a PT change file.  
##	- Note the PT_ECO_MODE variable chooses between freeze_silicon and MPI to physically implement the ECO.
##	- Note freeze silicon ECOs must be implemented via user PT ECO change file.
##

## It is recommended that a good correlation baseline be achieved between the implementation tool (i.e. FC, ICCII) 
## and PT prior to running eco_opt.  The command "analyze_timing_correlation" can be used to generate a correlation
## report.  Adjust tool settings for further alignment if needed. 

## We are disabling the following OBD option, as we are seeing negative DRC impact.
set_app_options -name route.detail.eco_route_use_soft_spacing_for_timing_optimization -value false

## Determine if the design contains filler cells.  This is used later to determine if filler insertion is rerun.
if {$ECO_OPT_FILLER_CELL_PREFIX==""} {
	puts "RM-warning: The variable ECO_OPT_FILLER_CELL_PREFIX is set NULL.  All filler cells will be removed."
}
set RM_prior_filler_cells [get_cells -hier -quiet xofiller!${ECO_OPT_FILLER_CELL_PREFIX}*]
if {[sizeof_collection $RM_prior_filler_cells] > 0} {
	set RM_enable_filler_insertion "1"
} else {
	set RM_enable_filler_insertion "0"
	puts "RM-info: No filler cells where detected in the source design."
}

if {$PT_ECO_CHANGE_FILE==""} {
	## Pre-existing filler cells are removed using the ECO_OPT_FILLER_CELL_PREFIX to identify the filler cells to remove.
	if {$RM_enable_filler_insertion} {
		remove_cells $RM_prior_filler_cells
	}

	## Note that it is recommended that routing DRC are closed prior to running eco_opt.
	
        ## Defining ECO ietration count
        set eco_count 1
	
	foreach eco_opt_type $ECO_OPT_RECIPE_INFO { 
          if {$ECO_OPT_ENGINE == "pt"} {
            
            puts "RM-info: Running eco_opt with PT"
	    ## Default types performed by eco_opt are : setup hold drc total_power buffer_removal.  See MAN page for additional details.
	    set eco_opt_cmd "eco_opt"
	    if {$ECO_OPT_PHYSICAL_MODE != ""} {lappend eco_opt_cmd -physical_mode $ECO_OPT_PHYSICAL_MODE}
	    if {$ECO_OPT_WITH_PBA} {lappend eco_opt_cmd -pba_mode [get_app_option_value -name time.pba_optimization_mode]}
	    if {$ECO_OPT_CUSTOM_OPTIONS != ""} {lappend eco_opt_cmd $ECO_OPT_CUSTOM_OPTIONS}

	    set eco_opt_args "$eco_opt_cmd -types [list $eco_opt_type]"
	    puts "RM-info: Starting run $eco_count: $eco_opt_args"
	    eval $eco_opt_args
          
          } elseif {$ECO_OPT_ENGINE == "primeeco" || $ECO_OPT_ENGINE == "tweaker"} {
            
            puts "RM-info: Fixing \"$eco_opt_type\""
           
            ## Generating Variable file to pass to the engines
            rm_generate_variables_for_eco -work_directory ${REPORTS_DIR}/${REPORT_PREFIX} -file_name eco_opt_rm_tcl_var.tcl

            set_pt_options -reset
	    
            if {$ECO_OPT_ENGINE == "primeeco"} { 
              puts "RM-info: Running eco_opt with PrimeECO"
              set_pt_options -primeeco_exec $eco_exec_image -work_dir eco_opt_dir_${eco_count}/primeeco_work
            } else {
              puts "RM-info: Running eco_opt with Tweaker"
              set_pt_options -tweaker_exec $eco_exec_image -work_dir eco_opt_dir_${eco_count}/tweaker_work
            }
            ## Performing ECO_OPT
            eco_opt -eco_script $ECO_OPT_ENGINE_SCRIPT
          
          } else {
            puts "RM-error: Invalid ECO_OPT_ENGINE.  Exiting."
			
			exit
			
          }
	  
          ################################################
          ## Check and show PT QoR
          ## - Reset work_dir for post ECO reporting for next ECO iteration.
          ## - It will otherwise overwrite the eco_opt working dir.
          ################################################

          set_pt_options -reset
          eval $pre_eco_pt_options -work_dir post_eco_pt_${eco_count}
	  redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/run_$eco_count.check_pt_qor.post.rpt $check_pt_qor_cmd
	  redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/run_$eco_count.check_pt_qor.post.summary.rpt "$check_pt_qor_cmd -type summary"
	 
          incr eco_count
	  
          set_pt_options -reset
	  eval $pre_eco_pt_options -work_dir eco_opt_dir_${eco_count}
        }

} elseif {[file exists [which $PT_ECO_CHANGE_FILE]]} {
	# Clear eco_change_status for all eco cells
	#  -quiet used in case there is no cell with defined(eco_change_status) exists
	remove_attribute [get_cell -quiet -hier -filter "defined(eco_change_status)"] eco_change_status

	## PT ECO - both Freeze Silicon and Non-Freeze Silicon ECO flows are supported 
	if {$PT_ECO_MODE == "freeze_silicon"} {
		puts "RM-info: Running freeze silicon PT-ECO flow"
	
		# The freeze silicon flow swaps ECO cells for previously inserted programmable spare cells.
		# These spare cells should have been inserted during compile or place_opt.  Refer to 
		# place_opt.spare_cell.tcl as an example script.
	
		## Enable freeze silicon ECO
		set_app_options -name design.eco_freeze_silicon_mode -value true

		## User provided PT ECO change file.
		rm_source -file $PT_ECO_CHANGE_FILE
		set_app_options -name design.eco_freeze_silicon_mode -value false
	
		## Check freeze silicon availability
		redirect -file ${REPORTS_DIR}/${PT_ECO_BLOCK_NAME}.check_freeze_silicon {check_freeze_silicon}

		## ECO placement
		place_freeze_silicon

	} else {

		puts "RM-info: Running MPI PT-ECO flow"
		rm_source -file $PT_ECO_CHANGE_FILE

		## The "report_eco_physical_changes" command reports the physical changes to the design after an ECO has been applied.
		## The actual & estimated cell displacement and net lengths can be reported.  The user can revert eco changes that have
		## large estimated cell displacement using "revert_eco_changes -cells".  This would however require an interactive approach
		## to running the ECO.  See the MAN page for additional details.
		redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_eco_physical_changes.pre_eco_place.rpt {report_eco_physical_changes -type all}
	
		## Legalize ECO cells (MPI mode)
		set place_eco_cells_cmd "place_eco_cells -eco_changed_cells -legalize_only -legalize_mode minimum_physical_impact -displacement_threshold $PT_ECO_DISPLACEMENT_THRESHOLD"
		if {$CHIP_FINISH_METAL_FILLER_LIB_CELL_LIST != "" || $CHIP_FINISH_NON_METAL_FILLER_LIB_CELL_LIST != ""} {
			lappend place_eco_cells_cmd -remove_filler_references "$CHIP_FINISH_METAL_FILLER_LIB_CELL_LIST $CHIP_FINISH_NON_METAL_FILLER_LIB_CELL_LIST"
		}
		puts "RM-info: $place_eco_cells_cmd"
		eval ${place_eco_cells_cmd}

		redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_eco_physical_changes.post_eco_place.rpt {report_eco_physical_changes -type all}


	}
	connect_pg_net

	## Route_eco will by default attempt to close DRC for the entire design.  The option "route.common.eco_route_fix_existing_drc" controls whether the
	## router works on prior DRCs (i.e. those stored in the error cell), or only new DRCs found during post-eco DRC checking.  Setting the option below
	## to false should result in quicker ECO TAT, but higher final DRCs.
	##
	## Uncomment to instruct router to only work on new DRCs.
	## set_app_options -name route.common.eco_route_fix_existing_drc -value false 

	## ECO routing
	#  Turn off timing-driven and crosstalk-driven for ECO routing 
	set RM_route_global_timing_driven [get_app_option_value -name route.global.timing_driven]
	set_app_options -name route.global.timing_driven    -value false
	set RM_route_track_timing_driven [get_app_option_value -name route.track.timing_driven]
	set_app_options -name route.track.timing_driven     -value false
	set RM_route_detail_timing_driven [get_app_option_value -name route.detail.timing_driven]
	set_app_options -name route.detail.timing_driven    -value false 
	set RM_route_global_crosstalk_driven [get_app_option_value -name route.global.crosstalk_driven]
	set_app_options -name route.global.crosstalk_driven -value false 
	set RM_route_track_crosstalk_driven [get_app_option_value -name route.track.crosstalk_driven]
	set_app_options -name route.track.crosstalk_driven  -value false 
	
	set route_eco_cmd "route_eco -utilize_dangling_wires true -reroute modified_nets_first_then_others -open_net_driven true"
	puts "RM-info: $route_eco_cmd"
	eval ${route_eco_cmd}

	set_app_options -name route.global.timing_driven -value $RM_route_global_timing_driven
	set_app_options -name route.track.timing_driven -value $RM_route_track_timing_driven
	set_app_options -name route.detail.timing_driven -value $RM_route_detail_timing_driven
	set_app_options -name route.global.crosstalk_driven -value $RM_route_global_crosstalk_driven
	set_app_options -name route.track.crosstalk_driven -value $RM_route_track_crosstalk_driven
	
	redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_eco_physical_changes.post_eco_route.rpt {report_eco_physical_changes -type all}
} else {
	puts "RM-error: PT_ECO_CHANGE_FILE($PT_ECO_CHANGE_FILE) is invalid. Please correct it."
}
## Following checks for DRCs post route_eco, and if found, runs rounds of incremetal detail route. 
if { $ENABLE_INCR_ROUTE_POST_ECO } {
  if {$PT_ECO_MODE != "freeze_silicon"} {
    check_routes > ./check_routes_report
    set fid [ open ./check_routes_report r ]
    set string_file [ read $fid ]
    close $fid
    set lines [ split $string_file \n ]
    foreach line $lines {
      if { [ regexp {^Total number of DRCs =\s([\d]+)} $line match data ] } {
        puts "RM-info: DRCs post eco_opt: $data"
        if { $data > "0" } {
          puts "RM-info: Number of DRCs reported post route_eco : $data"
          puts "RM-info: Running  a cycle of incremental detail route to resolve residual DRCs" 
          route_detail -incremental true -initial_drc_from_input true
        } else {
          puts "RM-info: DRCs are already clean. No need to run incremental detail routing."
        }
      }
    }
  }
}
########################################
## Reinsert filler cells if they previously existed in the design.  This is a complete reinsertion 
## for eco_opt, and an incremental insertion when running place_eco_cells.  Note that we skip if
## freeze_silicon was run.
########################################
if {$RM_enable_filler_insertion} {
	if {($PT_ECO_CHANGE_FILE!="") && ($PT_ECO_MODE=="freeze_silicon")} {
 		puts "RM-info: Skipping filler cell reinsertion for freeze_silicon mode."
	} else {
		puts "RM-info: Filler cells were detected in the source design.  Performing reinsertion..."
		rm_source -file $SIDEFILE_TIMING_ECO_2
	}
} else {
	puts "RM-info: Skipping filler cell reinsertion as none detected in source design."
}

########################################
## Reinsert metal fill if it pre-existed in the design.  Use ICV_IN_DESIGN_METAL_FILL_ECO_THRESHOLD to set the max
## threshold for incremental fill.
## - Note: This relies on previous full metal fill insertion using the "icv_in_design.tcl" file.  Application options 
##   get set during the icv_in_design flow target that are reused here (i.e. signoff.create_metal_fill.runset).
########################################
if {!([compare_collections [get_shapes -hier] [get_shapes -hier -include_fill]]=="0")} {
	puts "RM-info: Metal fill was detected in the source design.  Performing refill..."

	rm_source -file $SIDEFILE_TIMING_ECO_3 -optional -print "SIDEFILE_TIMING_ECO_3" ;# node/foundry specific

	save_block

	# Metal fill options set during full metal fill insertion (i.e. icv_in_design.tcl) should still be relevant. Update if needed.
	redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_app_options.signoff.create_metal_fill.rpt {report_app_options signoff.create_metal_fill*}
	
	if {$ICV_IN_DESIGN_METAL_FILL_ECO_THRESHOLD!=""} {
        	 set_app_options   -name  signoff.create_metal_fill.auto_eco_threshold_value -value $ICV_IN_DESIGN_METAL_FILL_ECO_THRESHOLD
	}

        ## Enable tool to run fullchip fill if eco change threshold is exceeded beyong specified or default value
        set_app_options -name signoff.create_metal_fill.full_run_on_large_eco -value true

	## Building a signoff_metal_fill command line that should work for most. Update if needed.
	set create_metal_fill_cmd "signoff_create_metal_fill"
	
	if {$ICV_IN_DESIGN_METAL_FILL_TRACK_BASED != "off"} {
	
		## For track-based metal fill creation, it is recommended to specify foundry node for -track_fill in order to use -fill_all_track
		if {$ICV_IN_DESIGN_METAL_FILL_TRACK_BASED != "generic"} {
			lappend create_metal_fill_cmd -track_fill $ICV_IN_DESIGN_METAL_FILL_TRACK_BASED -fill_all_tracks true
		} else {
			lappend create_metal_fill_cmd -track_fill $ICV_IN_DESIGN_METAL_FILL_TRACK_BASED
		}
	
		## Track-based metal fill creation: optionally specify a ICV_IN_DESIGN_METAL_FILL_TRACK_BASED_PARAMETER_FILE  
		if {$ICV_IN_DESIGN_METAL_FILL_TRACK_BASED_PARAMETER_FILE != "auto" && [file exists [which $ICV_IN_DESIGN_METAL_FILL_TRACK_BASED_PARAMETER_FILE]]} {
			lappend create_metal_fill_cmd -track_fill_parameter_file $ICV_IN_DESIGN_METAL_FILL_TRACK_BASED_PARAMETER_FILE
		}
	}

	if {$ICV_IN_DESIGN_METAL_FILL_SELECT_LAYERS != ""} {
		lappend create_metal_fill_cmd -select_layers $ICV_IN_DESIGN_METAL_FILL_SELECT_LAYERS
	}

	puts "RM-info: Running $create_metal_fill_cmd"
	eval $create_metal_fill_cmd -auto_eco true

} else {
	puts "RM-info: Skipping metal fill reinsertion as none detected in source design."
}

################################################
## Check if design is clean
################################################
redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/post_check_legality.rpt {check_legality}
redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/post_check_routes.rpt {check_routes}

################################################
## Check and show PT QoR
## - Reset work_dir for post ECO reporting.
## - It will otherwise overwrite the eco_opt working dir.
################################################
set_pt_options -reset
eval $pre_eco_pt_options -work_dir post_eco_pt
redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_pt_qor.post.rpt $check_pt_qor_cmd
redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/check_pt_qor.post.summary.rpt "$check_pt_qor_cmd -type summary"

################################################
## Restore pre-eco settings
################################################
set_app_options -name extract.starrc_mode -value $extraction_mode

####################################
## Post-PT ECO customizations
####################################
rm_source -file $TCL_USER_TIMING_ECO_POST_SCRIPT -optional -print "TCL_USER_TIMING_ECO_POST_SCRIPT"

if {![rm_source -file $TCL_USER_CONNECT_PG_NET_SCRIPT -optional -print "TCL_USER_CONNECT_PG_NET_SCRIPT"]} {
## Note : the following executes only if TCL_USER_CONNECT_PG_NET_SCRIPT is not sourced
	connect_pg_net
        # For non-MV designs with more than one PG, you should use connect_pg_net in manual mode.
}

save_block
save_lib

####################################
## Report and output
####################################
if {$REPORT_QOR} {
        set REPORT_STAGE post_route
        set REPORT_ACTIVE_SCENARIOS $REPORT_TIMING_ECO_ACTIVE_SCENARIO_LIST
	if {$REPORT_PARALLEL_SUBMIT_COMMAND != ""} {
		## Generate a file to pass necessary RM variables for running report_qor.tcl to the report_parallel command
		rm_generate_variables_for_report_parallel -work_directory ${REPORTS_DIR}/${REPORT_PREFIX} -file_name rm_tcl_var.tcl

		## Parallel reporting using the report_parallel command (requires a valid REPORT_PARALLEL_SUBMIT_COMMAND)
		report_parallel -work_directory ${REPORTS_DIR}/${REPORT_PREFIX} -submit_command ${REPORT_PARALLEL_SUBMIT_COMMAND} -max_cores ${REPORT_PARALLEL_MAX_CORES} -user_scripts [list "${REPORTS_DIR}/${REPORT_PREFIX}/rm_tcl_var.tcl" "[which report_qor.tcl]"]
	} else {
		## Classic reporting
		rm_source -file report_qor.tcl
	}
}
redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/run_end.rpt {run_end}

report_msg -summary
print_message_info -ids * -summary
rm_logparse $LOGS_DIR/timing_eco.log
echo [date] > timing_eco

exit

