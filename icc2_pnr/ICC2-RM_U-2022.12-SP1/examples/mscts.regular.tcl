##########################################################################################
# Script: mscts.regular.tcl
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################

#### Variables related to Regular MSCTS
set MSCTS_CLOCK ""                              ;# MSCTS Clock name
set MSCTS_SOURCE ""                             ;# MSCTS Clock root
set MSCTS_TOPOLOGY "htree"              	;# Use htree or subtree_only 
						;# htree will create global clock tree with htree topology and integrated tap assignment  
						;# subtree_only will do user driven tap assignment 
### Variables for the global clock tree (Htree) 
set MSCTS_NET ""                                ;# Optional: Specify net if tap driver should be inserted on a net different than the clock root net
set MSCTS_HTREE_NDR_RULE_NAME ""             	;# Htree NDR rule name
set MSCTS_HTREE_MIN_ROUTING_LAYER ""          	;# Htree min routing layer
set MSCTS_HTREE_MAX_ROUTING_LAYER ""          	;# Htree max routing layer
set MSCTS_HTREE_LIB_CELLS ""                    ;# Htree driver lib cells

#### Variables for the tap driver insertion
set MSCTS_PITCH "100"                           ;# Distance used to configures Tap driver location boxes
set MSCTS_TAP_DRIVER_LIB_CELLS ""               ;# Tap driver lib cells
set MSCTS_TAP_DRIVER_MAX_DISPLACEMENT ""        ;# Optional: Tap driver max displacement distance; in most cases max displacement does not need to be specified. By default no maximum displacement is in effect
						;# and cells will be legalized as close as possible to the preferred location
set MSCTS_TAP_BOUNDARY ""                       ;# Optional: Recommended to allow the tool to derive appropriate boundary for tap driver insertion 
						;# Specifies the area in which tap drivers and htree are created, bbox format "{ll_x ll_y} {ur_x ur_y}" 
set MSCTS_MACRO_KEEPOUT "false"			;# Optional: true/false - RM default is false; When true creates list of poly_rects based on macro placement where no driver cells should be placed

#### Variables for subtree_only
set MSCTS_MESH_NET "" 				;# Mesh net clock net name
set MSCTS_MESH_NET_PORT ""			;# Port driving mesh net clock net
set MSCTS_MESH_NET_PORT_TRANSITION ""		;# Defines transition annotated to the port driving the mesh net
set MSCTS_MESH_NET_PORT_DELAY "" 		;# Defines delay annotated to the port driving the mesh net 
set MSCTS_INPUT_TRANSITION ""			;# Defines transition annotated to the input of the tap driver
set MSCTS_NET_DELAY ""				;# Defines net delay annotated from mesh net port to input of the tap driver
set TCL_USER_MESH_ANNOTATION_SCRIPT ""		;# Optional: User provided clock mesh annotation script

##########################################################################################
#  The following is a sample script for regular MSCTS construction.
#  The script is intended for the following clock structure :
#  clock root -> global clock tree (HTree) -> tap drivers -> subtrees
##########################################################################################

if {$MSCTS_CLOCK  == ""} {
        puts "RM-error: MSCTS clock not defined."
                set icc2rm_error_mscts 1
}
if {$MSCTS_SOURCE == ""} {
        puts "RM-error: MSCTS clock source not defined."
                set icc2rm_error_mscts 1
}
if {$MSCTS_PITCH == ""} {
        puts "RM-error: MSCTS pitch not defined."
                set icc2rm_error_mscts 1
}
if {$MSCTS_TAP_DRIVER_LIB_CELLS == ""} {
        puts "RM-error: MSCTS tap drivers not defined."
                set icc2rm_error_mscts 1
}

if {$MSCTS_TOPOLOGY == "htree"} {
	if {$MSCTS_HTREE_LIB_CELLS == ""} {
	        puts "RM-error: MSCTS htree lib cells not defined."
	                set icc2rm_error_mscts 1
	}
	if {$MSCTS_HTREE_NDR_RULE_NAME  == ""} {
	        puts "RM-error: MSCTS NDR rule not defined."
	                set icc2rm_error_mscts 1
	}
	if {$MSCTS_HTREE_MIN_ROUTING_LAYER == ""} {
	        puts "RM-error: MSCTS min routing layer not defined."
	                set icc2rm_error_mscts 1
	}
	if {$MSCTS_HTREE_MAX_ROUTING_LAYER  == ""} {
	        puts "RM-error: MSCTS max routing layer not defined."
	                set icc2rm_error_mscts 1
	}
}

if {$MSCTS_TOPOLOGY == "subtree_only"} {
	if {$MSCTS_INPUT_TRANSITION == ""} {
	        puts "RM-error: Input transition for tap driver not defined."
	                set icc2rm_error_mscts 1
	}
	if {$MSCTS_NET_DELAY  == ""} {
	        puts "RM-error: Delay from clock source to tap driver not defined."
	                set icc2rm_error_mscts 1
	}
	if {$MSCTS_MESH_NET == ""} {
	        puts "RM-error: Mesh net not defined."
	                set icc2rm_error_mscts 1
	}
	if {$MSCTS_MESH_NET_PORT  == ""} {
	        puts "RM-error: Mesh net port not defined."
	                set icc2rm_error_mscts 1
	}
}

if {[info exists icc2rm_error_mscts]} {

                puts "RM-info: Errors encountered. There are requirements not met."
                puts "RM-info: Please check the RM-error messages in the log and correct the missing information and try it again."
}

## Application option to enable MSCTS support for MV designs
#  This punches port on power domain boundaries and merges/clones power management cells (isolation and level shifters)
set_app_options -name cts.multisource.enable_full_mv_support -value true
#  Enable below application option for physical feedthrough nets and power domain on instances support
set_app_options -name opt.common.allow_physical_feedthrough -value true

foreach source $MSCTS_SOURCE {
	set_dont_touch_network -clear $source
}

mark_clock_trees -clear -dont_touch

#Ensure that current_scenario is an active scenario
set active_scenarios [get_object_name [get_scenarios -filter "setup&&active"]]
set first_active [lindex $active_scenarios 0]
current_scenario $first_active
 
if {$MSCTS_TOPOLOGY == "htree"} {
	## Remove constraints like dont_touch, fixed, locked and user_size_only on nets/cells to allow merging/splitting of clock cells for tap assignment
	set_lib_cell_purpose -include cts [get_lib_cell $MSCTS_HTREE_LIB_CELLS]
	set_lib_cell_purpose -include cts [get_lib_cell $MSCTS_TAP_DRIVER_LIB_CELLS]
	set_dont_touch [get_lib_cell $MSCTS_HTREE_LIB_CELLS] false
	set_dont_touch [get_lib_cell $MSCTS_TAP_DRIVER_LIB_CELLS] false

	if {$MSCTS_NET != ""} {
		set load_cells [get_cells -of_objects [get_flat_pins -of_objects [get_nets $MSCTS_NET] -filter "direction==in"]]
		set_dont_touch $load_cells false
		set_dont_touch [get_lib_cells -of_objects $load_cells] false
		set_size_only $load_cells false
		set_placement_status placed $load_cells
		set net_driver [get_flat_cell -of_objects [get_flat_pins -filter "direction==out" -of_objects $MSCTS_NET]]
        	set net_driver_status [get_attribute [get_cells $net_driver] physical_status] 

 		if {$net_driver_status == "placed"} { 
			legalize_placement -cells $net_driver
		}
	} else {
		set load_cells [get_cells -of_objects [get_flat_pins -of_objects [get_nets -of_objects $MSCTS_SOURCE] -filter "direction==in"]]
		set_dont_touch $load_cells false
		set_dont_touch [get_lib_cells -of_objects $load_cells] false
		set_size_only $load_cells false
		set_placement_status placed $load_cells
	}

	## Controls the placement of inserted cells such that they are accessibe from the selected Htree routing layers. This ensures good global clock tree (Htree) routing topology.
	set_app_options -name cts.multisource.enable_pin_accessibility_for_global_clock_trees -value true


	###########################################################################################################################
	## STEP 1: Define options to perform auto tap synthesis and global clock tree synthesis for regular multisource clock trees 
	###########################################################################################################################
	
	# Determine number of columns and rows of tap driver location grid based on specified pitch. Bounding box of the boundary is subdivided into equally sized boxes
	# based on number of columns and rows
	
	proc get_width_from_bbox {bbox} {
	            return [expr [lindex $bbox 1 0] - [lindex $bbox 0 0]]
	        }
	proc get_height_from_bbox {bbox} {
	            return [expr [lindex $bbox 1 1] - [lindex $bbox  0 1]]
	        }
	proc PROC_return_next_binary_number {x} {
               puts "input number: $x"
               if {$x <=2 && $x <4} {
                              puts "output number: 2"
                              return 2
               } elseif {$x <=4 && $x <8} {
                              puts "output number: 4"
                              return 4
               } elseif {$x <=8 && $x <16} {
                              puts "output number: 8"
                              return 8
               } elseif {$x <=16 && $x <32} {
                              puts "output number: 16"
                              return 16
               } elseif {$x <=32 && $x <64} {
                              puts "output number: 32"
                              return 32
               } elseif {$x <=64 && $x <128} {
                              puts "output number: 64"
                              return 64
               }
	}
	
	if {$MSCTS_TAP_BOUNDARY != ""} {
		set width [get_width_from_bbox $MSCTS_TAP_BOUNDARY]
		set height [get_height_from_bbox $MSCTS_TAP_BOUNDARY]
		
		set x [expr round($width/($MSCTS_PITCH*2.0))]
		set y [expr round($height/($MSCTS_PITCH*2.0))]
		puts "DEBUG: x is $x and y is $y"
			if {$x < 1} {set x 1}
			if {$y < 1} {set y 1}
		puts "DEBUG: x is $x and y is $y"

	} else {
		set bbox [get_attribute [current_design] boundary_bbox]
		set width [lindex $bbox 1 0]
		set height [lindex $bbox 1 1]
		
		set x [expr round($width/($MSCTS_PITCH*2.0))]
		set y [expr round($height/($MSCTS_PITCH*2.0))]
		puts "DEBUG: x is $x and y is $y"
			if {$x < 1} {set x 1}
			if {$y < 1} {set y 1}
		puts "DEBUG: x is $x and y is $y"
	}

	set x_binary_row_count [PROC_return_next_binary_number $x]
	set y_binary_column_count [PROC_return_next_binary_number $y]
	
	foreach clock $MSCTS_CLOCK {
		if {$MSCTS_NET != "" && $MSCTS_TAP_DRIVER_MAX_DISPLACEMENT != ""} {
			set_regular_multisource_clock_tree_options -clock $clock \
				-net $MSCTS_NET  \
				-topology htree_only  \
				-prefix htree  \
				-tap_boxes [list $x_binary_row_count $y_binary_column_count]  \
				-htree_layers [list $MSCTS_HTREE_MIN_ROUTING_LAYER $MSCTS_HTREE_MAX_ROUTING_LAYER]  \
				-htree_routing_rule $MSCTS_HTREE_NDR_RULE_NAME  \
				-tap_lib_cells [get_lib_cells $MSCTS_TAP_DRIVER_LIB_CELLS]  \
				-htree_lib_cells [get_lib_cells $MSCTS_HTREE_LIB_CELLS]  \
				-max_displacement $MSCTS_TAP_DRIVER_MAX_DISPLACEMENT 
		} elseif {$MSCTS_TAP_DRIVER_MAX_DISPLACEMENT != ""} {
			set_regular_multisource_clock_tree_options -clock $clock \
				-topology htree_only \
				-prefix htree \
				-tap_boxes [list $x_binary_row_count $y_binary_column_count] \
				-htree_layers [list $MSCTS_HTREE_MIN_ROUTING_LAYER $MSCTS_HTREE_MAX_ROUTING_LAYER] \
				-htree_routing_rule $MSCTS_HTREE_NDR_RULE_NAME \
				-tap_lib_cells [get_lib_cells $MSCTS_TAP_DRIVER_LIB_CELLS] \
				-htree_lib_cells [get_lib_cells $MSCTS_HTREE_LIB_CELLS] \
				-max_displacement $MSCTS_TAP_DRIVER_MAX_DISPLACEMENT
		} elseif {$MSCTS_NET != ""} {
			set_regular_multisource_clock_tree_options -clock $clock \
				-net $MSCTS_NET \
				-topology htree_only \
				-prefix htree \
				-tap_boxes [list $x_binary_row_count $y_binary_column_count] \
				-htree_layers [list $MSCTS_HTREE_MIN_ROUTING_LAYER $MSCTS_HTREE_MAX_ROUTING_LAYER] \
				-htree_routing_rule $MSCTS_HTREE_NDR_RULE_NAME \
				-tap_lib_cells [get_lib_cells $MSCTS_TAP_DRIVER_LIB_CELLS] \
				-htree_lib_cells [get_lib_cells $MSCTS_HTREE_LIB_CELLS]
		} else {
			set_regular_multisource_clock_tree_options -clock $clock  \
				-topology htree_only \
				-prefix htree \
				-tap_boxes [list $x_binary_row_count $y_binary_column_count] \
				-htree_layers [list $MSCTS_HTREE_MIN_ROUTING_LAYER $MSCTS_HTREE_MAX_ROUTING_LAYER] \
				-htree_routing_rule $MSCTS_HTREE_NDR_RULE_NAME \
				-tap_lib_cells [get_lib_cells $MSCTS_TAP_DRIVER_LIB_CELLS] \
				-htree_lib_cells [get_lib_cells $MSCTS_HTREE_LIB_CELLS]
		}
	}
	
	foreach clock $MSCTS_CLOCK {
		if {$MSCTS_TAP_BOUNDARY != "" && $MSCTS_NET != ""} {
			set_regular_multisource_clock_tree_options -clock $clock \
				-topology htree_only \
				-tap_boxes [list $x_binary_row_count $y_binary_column_count] \
				-tap_boundary $MSCTS_TAP_BOUNDARY \
				-net $MSCTS_NET
		} elseif {$MSCTS_TAP_BOUNDARY != ""} {
			set_regular_multisource_clock_tree_options -clock $clock \
				-topology htree_only \
				-tap_boxes [list $x_binary_row_count $y_binary_column_count] \
				-tap_boundary $MSCTS_TAP_BOUNDARY
		}
	}
	
	foreach clock $MSCTS_CLOCK {
		if { [sizeof_collection [get_cells -physical_context -filter design_type==macro]] > 0} {	
			set gm [resize_polygons -objects [create_geo_mask -objects [get_cells -physical_context -filter design_type==macro]] -size {10}]
			set keepouts [get_attribute [get_attribute $gm poly_rects] point_list]

			if {$MSCTS_MACRO_KEEPOUT == "true" && $MSCTS_NET != ""} {
				set_regular_multisource_clock_tree_options -clock $clock \
					-topology htree_only \
					-tap_boxes [list $x_binary_row_count $y_binary_column_count] \
					-keepouts $keepouts \
					-net $MSCTS_NET
			} elseif {$MSCTS_MACRO_KEEPOUT == "true"} {
				set_regular_multisource_clock_tree_options -clock $clock \
					-topology htree_only \
					-tap_boxes [list $x_binary_row_count $y_binary_column_count] \
					-keepouts $keepouts
			}
		}
	}

	report_regular_multisource_clock_tree_options
	
	synthesize_regular_multisource_clock_trees
	
	########################################################################################## 
	## STEP 2: Define Tap assignment settings for integrated tap assignment
	##########################################################################################
	## Define tap assignment settings 
	# Use -dont_merge_cells to provide list of cells which should not get merged with other cells during tap assignment merge stage
	# Use -relax_split_restrictions_for_cells to provide list of cells that can be split during tap assignment even if set with user_dont_touch/user_size_only
	set active_scenarios [get_object_name [get_scenarios -filter "setup&&active"]]
	set first_active [lindex $active_scenarios 0]
	current_scenario $first_active

	update_timing	
	foreach clock $MSCTS_CLOCK {
		set tap_drivers [get_pins -of_objects  [get_cells -physical_context *htree_r*c*] -filter "direction==out && related_clock==$clock"]
		set_multisource_clock_tap_options -clock $clock -num_taps [sizeof_collection $tap_drivers] -driver_objects $tap_drivers
	}
} elseif {$MSCTS_TOPOLOGY == "subtree_only"} {
        set_dont_touch [get_lib_cell $MSCTS_TAP_DRIVER_LIB_CELLS] false
	set tap_lib_cells [get_lib_cell $MSCTS_TAP_DRIVER_LIB_CELLS]
	foreach lc [get_object_name $tap_lib_cells] {set save_dont_use($lc) [get_attribute $lc dont_use]}
	set_lib_cell_purpose -include cts $tap_lib_cells; set_attribute $tap_lib_cells dont_use false

	set load_cells [get_cells -of_objects [get_flat_pins -of_objects [get_nets $MSCTS_MESH_NET] -filter "direction==in"]]
	set_dont_touch $load_cells false
	set_dont_touch [get_lib_cells -of_objects $load_cells] false
	set_size_only $load_cells false
        set_placement_status placed $load_cells

	###########################################################################################################################
	## STEP 1: Define options to perform only tap driver insertion for regular multisource clock trees 
	###########################################################################################################################
	
	# Determine number of columns and rows of tap driver location grid based on specified pitch. Bounding box of the boundary is subdivided into equally sized boxes
	# based on number of columns and rows

	proc get_width_from_bbox {bbox} {
	            return [expr [lindex $bbox 1 0] - [lindex $bbox 0 0]]
	        }
	proc get_height_from_bbox {bbox} {
	            return [expr [lindex $bbox 1 1] - [lindex $bbox  0 1]]
	        }
	
	if {$MSCTS_TAP_BOUNDARY != ""} {
		set width [get_width_from_bbox $MSCTS_TAP_BOUNDARY]
		set height [get_height_from_bbox $MSCTS_TAP_BOUNDARY]
		
		set x [expr round($width/($MSCTS_PITCH*2.0))]
		set y [expr round($height/($MSCTS_PITCH*2.0))]
		puts "DEBUG: x is $x and y is $y"
			if {$x < 1} {set x 1}
			if {$y < 1} {set y 1}
		puts "DEBUG: x is $x and y is $y"

	} else {
		set bbox [get_attribute [current_design] boundary_bbox]
		set width [lindex $bbox 1 0]
		set height [lindex $bbox 1 1]
		
		set x [expr round($width/($MSCTS_PITCH*2.0))]
		set y [expr round($height/($MSCTS_PITCH*2.0))]
		puts "DEBUG: x is $x and y is $y"
			if {$x < 1} {set x 1}
			if {$y < 1} {set y 1}
		puts "DEBUG: x is $x and y is $y"
	
	}

	if {$MSCTS_TAP_DRIVER_MAX_DISPLACEMENT != "" && $MSCTS_MACRO_KEEPOUT == "true"} {
                if { [sizeof_collection [get_cells -physical_context -filter design_type==macro]] > 0} {
			set gm [resize_polygons -objects [create_geo_mask -objects [get_cells -physical_context -filter design_type==macro]] -size {10}]
			set keepouts [get_attribute [get_attribute $gm poly_rects] point_list]

			if {$MSCTS_TAP_BOUNDARY != ""} {
				create_clock_drivers -loads [get_nets $MSCTS_MESH_NET] \
					-boxes [list $x $y] \
					-prefix {mstap} \
        				-lib_cells $tap_lib_cells \
					-max_displacement $MSCTS_TAP_DRIVER_MAX_DISPLACEMENT \
					-keepouts $keepouts \
					-boundary $MSCTS_TAP_BOUNDARY
			} else {
				create_clock_drivers -loads [get_nets $MSCTS_MESH_NET] \
					-boxes [list $x $y] \
					-prefix {mstap} \
        				-lib_cells $tap_lib_cells \
					-max_displacement $MSCTS_TAP_DRIVER_MAX_DISPLACEMENT \
					-keepouts $keepouts
			}
		} 
	} elseif {$MSCTS_TAP_DRIVER_MAX_DISPLACEMENT != ""} {
		if {$MSCTS_TAP_BOUNDARY != ""} {
			create_clock_drivers -loads [get_nets $MSCTS_MESH_NET] \
				-boxes [list $x $y] \
				-prefix {mstap} \
        			-lib_cells $tap_lib_cells \
				-max_displacement $MSCTS_TAP_DRIVER_MAX_DISPLACEMENT \
				-boundary $MSCTS_TAP_BOUNDARY
		} else {
			create_clock_drivers -loads [get_nets $MSCTS_MESH_NET] \
				-boxes [list $x $y] \
				-prefix {mstap} \
        			-lib_cells $tap_lib_cells \
				-max_displacement $MSCTS_TAP_DRIVER_MAX_DISPLACEMENT 
		}
	} elseif {$MSCTS_MACRO_KEEPOUT == "true"} {
        	if { [sizeof_collection [get_cells -physical_context -filter design_type==macro]] > 0} {
			set gm [resize_polygons -objects [create_geo_mask -objects [get_cells -physical_context -filter design_type==macro]] -size {10}]
			set keepouts [get_attribute [get_attribute $gm poly_rects] point_list]
			if {$MSCTS_TAP_BOUNDARY != ""} {
				create_clock_drivers -loads [get_nets $MSCTS_MESH_NET] \
			        	-boxes [list $x $y] \
			        	-prefix {mstap} \
			        	-lib_cells $tap_lib_cells \
					-keepouts $keepouts \
					-boundary $MSCTS_TAP_BOUNDARY
			} else {
				create_clock_drivers -loads [get_nets $MSCTS_MESH_NET] \
			        	-boxes [list $x $y] \
			        	-prefix {mstap} \
			        	-lib_cells $tap_lib_cells \
					-keepouts $keepouts
			}
		}
	} elseif {$MSCTS_TAP_BOUNDARY != ""} {
			create_clock_drivers -loads [get_nets $MSCTS_MESH_NET] \
                                -boxes [list $x $y] \
                                -prefix {mstap} \
                                -lib_cells $tap_lib_cells \
                                -boundary $MSCTS_TAP_BOUNDARY
	} else {

        	create_clock_drivers -loads [get_nets $MSCTS_MESH_NET] \
                	-boxes [list $x $y] \
                	-prefix {mstap} \
                	-lib_cells $tap_lib_cells 
	}	
        
	##Annotate transition and delay for mesh net
        if {![rm_source -file $TCL_USER_MESH_ANNOTATION_SCRIPT -optional -print "TCL_USER_MESH_ANNOTATION_SCRIPT"]} {
	## Note : The following executes only if TCL_USER_MESH_ANNOTATION_SCRIPT is not sourced
        	puts "RM-info: TCL_USER_MESH_ANNOTATION_SCRIPT($TCL_USER_MESH_ANNOTATION_SCRIPT) is not defined. Applying default annotation"
		set anchor [get_port $MSCTS_MESH_NET_PORT]
		set_annotated_transition -rise -max $MSCTS_MESH_NET_PORT_TRANSITION $anchor		
		set_annotated_transition -fall -max $MSCTS_MESH_NET_PORT_TRANSITION $anchor		
		set_annotated_transition -rise -min $MSCTS_MESH_NET_PORT_TRANSITION $anchor	
		set_annotated_transition -fall -min $MSCTS_MESH_NET_PORT_TRANSITION $anchor
		set_annotated_delay -cell -rise -max -from $anchor -to $anchor $MSCTS_MESH_NET_PORT_DELAY  	
		set_annotated_delay -cell -fall -max -from $anchor -to $anchor $MSCTS_MESH_NET_PORT_DELAY 	
		set_annotated_delay -cell -rise -min -from $anchor -to $anchor $MSCTS_MESH_NET_PORT_DELAY	
		set_annotated_delay -cell -fall -min -from $anchor -to $anchor $MSCTS_MESH_NET_PORT_DELAY	
		foreach_in_collection scn [get_scenarios] {
			current_scenario $scn
			foreach_in_collection itm [get_pins -physical_context -of_objects [get_flat_cells mstap_*] -filter "direction==in && port_type==signal"] {
				#transition for all tap pins in subcircuit
				set_annotated_transition -rise -max $MSCTS_INPUT_TRANSITION $itm;
				set_annotated_transition -fall -max $MSCTS_INPUT_TRANSITION $itm;
				set_annotated_transition -rise -min $MSCTS_INPUT_TRANSITION $itm;
				set_annotated_transition -fall -min $MSCTS_INPUT_TRANSITION $itm;
				#Net delay from anchor driver to each tap
				set_annotated_delay -net -rise -max -from $anchor -to $itm $MSCTS_NET_DELAY
				set_annotated_delay -net -fall -max -from $anchor -to $itm $MSCTS_NET_DELAY  	
				set_annotated_delay -net -rise -min -from $anchor -to $itm $MSCTS_NET_DELAY  	
				set_annotated_delay -net -fall -min -from $anchor -to $itm $MSCTS_NET_DELAY
			}
		}	
	}	
	#Lock mesh net to prevent net from being routed and buffered 	
	define_user_attribute -classes net -type string -one_of {true false} -name is_mesh_net
	set_attribute [get_nets $MSCTS_MESH_NET] is_mesh_net true
	set_attribute [get_nets $MSCTS_MESH_NET] physical_status locked
	set_dont_touch [get_nets $MSCTS_MESH_NET] true
	
	########################################################################################## 
	## STEP 2: Define Tap assignment settings for integrated tap assignment
	##########################################################################################
	## Define tap assignment settings 
	# Use -dont_merge_cells to provide list of cells which should not get merged with other cells during tap assignment merge stage
	# Use -relax_split_restrictions_for_cells to provide list of cells that can be split during tap assignment even if set with user_dont_touch/user_size_only
	set active_scenarios [get_object_name [get_scenarios -filter "setup&&active"]]
	set first_active [lindex $active_scenarios 0]
	current_scenario $first_active

        update_timing
	set tap_drivers [get_pins -of_objects  [get_cells -physical_context *mstap_r*c*] -filter "direction==out && related_clock==$MSCTS_CLOCK"]
	set_multisource_clock_tap_options -clock $MSCTS_CLOCK -driver_objects $tap_drivers -num_taps [sizeof_collection $tap_drivers] 
	
	set_lib_cell_purpose -exclude cts $tap_lib_cells
	set_attribute $tap_lib_cells dont_use true
	foreach lc [array names save_dont_use] {set_attribute [get_lib_cell $lc] dont_use $save_dont_use($lc)} 

} else {
 	puts "RM-error: Specified MSCTS_TOPOLOGY($MSCTS_TOPOLOGY) is not supported"
}

