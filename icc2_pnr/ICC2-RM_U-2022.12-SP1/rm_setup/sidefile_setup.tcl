##########################################################################################
# Script: sidefile_setup.tcl
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################

## NOTE:
## This rm_setup/sidefile_setup.tcl is intended for established nodes.
## For advanced nodes, the sidefile bundle to be downlaoded will include a separate rm_tech_scripts/sidefile_setup.tcl,
## which will take precedence and be pre-polulated with pointers to the sidefiles

########################################################################################## 
## Node specific sidefile variables 
##########################################################################################
set TECHNOLOGY_NODE                                     "" ;# technology node for set_technology command ;# used in some nodes
set SET_TECHNOLOGY_AFTER_FLOORPLAN                      false ;# used in some nodes
set SIDEFILE_CREATE_FLOORPLAN_FLAT_FLOORPLANNING        "init_design.tcl.default.floorplanning" ;# used in some nodes
set SIDEFILE_CREATE_FLOORPLAN_FLAT_BOUNDARY_CELLS       "" ;# used in some nodes
set SIDEFILE_CREATE_FLOORPLAN_FLAT_TAP_CELLS            "" ;# used in some nodes
set SIDEFILE_CREATE_FLOORPLAN_FLAT_NODE_SUPPLEMENT      "" ;# Used in some nodes
set SIDEFILE_INIT_DP_FLOORPLANNING                      "init_design.tcl.default.floorplanning" ;# used in some nodes
set SIDEFILE_INIT_DP_TECH_SETTINGS                      "" ;# used in some nodes
set SIDEFILE_CREATE_FLOORPLAN_FLOORPLANNING             "init_design.tcl.default.floorplanning" ;# used in some nodes
set SIDEFILE_PLACE_PINS					"" ;# used in some nodes

set SIDEFILE_INIT_DESIGN                                "" ;# used in some nodes
set SIDEFILE_CLOCK_OPT_CTS                              "" ;# used in some nodes
set SIDEFILE_ROUTE_AUTO                                 "" ;# used in some nodes
set SIDEFILE_ROUTE_OPT                                  "" ;# used in some nodes
set SIDEFILE_CHIP_FINISH_1                              "chip_finish.tcl.default" ;# used in some nodes
set SIDEFILE_CHIP_FINISH_2                              "" ;# used in some nodes
set SIDEFILE_TIMING_ECO_1                               "" ;# used in some nodes
set SIDEFILE_TIMING_ECO_2                               "chip_finish.tcl.default" ;# used in some nodes
set SIDEFILE_TIMING_ECO_3                               "" ;# used in some nodes
set SIDEFILE_ICV_IN_DESIGN_1                            "" ;# used in some nodes
set SIDEFILE_ICV_IN_DESIGN_2                            "icv_in_design.tcl.default" ;# used in some nodes
set SIDEFILE_ICV_IN_DESIGN_CUSTOM_METAL_FILL            "" ;# Used in some nodes
set SIDEFILE_WRITE_DATA                                 "" ;# used in some nodes
set SIDEFILE_WRITE_FULL_CHIP_DATA                       "" ;# used in some nodes
set SIDEFILE_FUNCTIONAL_ECO                             "" ;# used in some nodes

########################################################################################## 
## Node specific variables 
##########################################################################################

set ADVANCED_NODE_LIBRARY_TYPE                          "" ;# Optional; used in some nodes; select the type of library in your design 

set SYNOPSYS_LOGIC_LIBRARY_MODE                         "" ;# Optional; applicable if Synopsys library is used; select the type of library in your design 

set HASH_VIA_FLOW                                       false ;# Optional; Default false; false|true; used in some nodes 

set MIXED_FLOW                                          false ;# Optional; Default false; false|true; used in some nodes

set ROUTING_LAYER_MASK_NUMBER_LIST                      "" ;# Specify the routing layer and number of masks for each layer in a list of space delimited pairs;
                                                        ;# Syntax is "{metal_layer_1 numer_of_masks} {metal_layer_2 number_of_masks} ..."; 
                                                        ;# Example: "{CM0 2} {CM1 2} {CM2 2} {M0 2} {M1 2} {M2 2}";

set ROUTING_LAYER_DIRECTION_OFFSET_LIST                 "{M1 vertical} {M2 horizontal} {M3 vertical} {M4 horizontal} {M5 vertical} {M6 horizontal} {M7 vertical} {M8 horizontal} {M9 vertical}" ;# Specify the routing layers as well as their direction and offset in a list of space delimited pairs;
                                                        ;# This variable should be defined for all metal routing layers in technology file;
                                                        ;# Syntax is "{metal_layer_1 direction offset} {metal_layer_2 direction offset} ...";
                                                        ;# It is required to at least specify metal layers and directions. Offsets are optional. 
                                                        ;# Example1 is with offsets specified: "{M1 vertical 0.2} {M2 horizontal 0.0} {M3 vertical 0.2}"
                                                        ;# Example2 is without offsets specified: "{M1 vertical} {M2 horizontal} {M3 vertical}"

set SITE_DEFAULT                                        "" ;# Optional; Specify the default site name if there are multiple site defs in the technology file;
                                                        ;# this is to be used by initialize_floorplan command; example: set SITE_DEFAULT "unit";
                                                        ;# this is applied in the init_design.tech_setup.tcl script

set MIN_ROUTING_LAYER                                   "" ;# Optional; Min routing layer name; normally should be specified; otherwise tool can use all metal layers

set MAX_ROUTING_LAYER                                   "" ;# Optional; Max routing layer name; normally should be specified; otherwise tool can use all metal layers

set TCL_TRACK_CREATION_FILE                             "" ;# a script for track creation after initialize_floorplan; please get it from your foundry vender 


set TCL_PLACEMENT_CONSTRAINT_FILE_LIST                  "" ;# Optional; A list of files for your placement spacing labels, spacing rules, or abutment rules
                                                        ;# Example : set_placement_spacing_label -name X -side both -lib_cells [get_lib_cells -of [get_cells]]
                                                        ;# Example : set_placement_spacing_rule -labels {X SNPS_BOUNDARY} {0 1}

set TCL_USER_CONNECT_PG_NET_SCRIPT                      [file join $root_dir "icc2_pnr/scripts/pg_connect.tcl"] ;# An optional Tcl file for customized connect_pg_net command and options, such as for bias pins of cells added by opto;
                                                        ;# sourced by all the main scripts prior to the save_block command

set TCL_COMPILE_PG_FILE                                 "" ;# An optional pg file

set PG_STAPLING_VIA                                     false ;# Optional; Default false; false|true; used in some nodes; sources PG stapling via sidefile

set TCL_LIB_CELL_DONT_USE_FILE                          "" ;# Optional; A Tcl file for customized don't use ("set_lib_cell_purpose -exclude <purpose>" commands)
                                                        ;# sourced by set_lib_cell_purpose.tcl; only applicable if TCL_LIB_CELL_PURPOSE_FILE is set to set_lib_cell_purpose.tcl

set TCL_CTS_NDR_RULE_FILE                               "" ;# Specify a script for clock NDR creation and association, to be sourced at place_opt
                                                        ;# By default the variable is set to ./examples/cts_ndr.tcl, which is an RM provided example.
                                                        ;# All the variables for customizing the clock NDR are defined within the example script.

set TCL_VIA_LADDER_DEFINITION_FILE                      "" ;# Optional; A file to specify your performance via ladder definitions; only needed if they are not included

set TCL_SET_VIA_LADDER_CANDIDATE_FILE                   "" ;# Optional; A file to specify your library specific set_via_ladder_candidate commands

set CHIP_FINISH_METAL_FILLER_LIB_CELL_LIST              "" ;# Optional; A list of metal filler (decap) lib cells, including the library name, for ex, 
                                                        ;# Example: "hvt/DCAP_HVT lvt/DCAP_LVT". Recommended to specify decaps from largest to smallest.
set CHIP_FINISH_NON_METAL_FILLER_LIB_CELL_LIST          "" ;# Optional; A list of non-metal filler lib cells, including the library name, for ex,
                                                        ;# Example: hvt/FILL_HVT lvt/FILL_LVT. Recommended to specify them from largest to smallest.

set CHIP_FINISH_CREATE_CUT_METALS                       false ;# Optional; Default false; true|false; used in some nodes; runs create_cut_metals command at end of chip_finish.tcl 

set ICV_IN_DESIGN_CREATE_CUT_METALS                     false ;# Optional; Default false; true|false; used in some nodes; true runs create_cut_metals at start of icv_in_design.tcl 
                                                        ;# skipped if CHIP_FINISH_CREATE_CUT_METALS is true, as it only needs to be run once.

set ICV_IN_DESIGN_PATTERN_MATCHING                      false ;# Optional; Default false; true|false; true runs In-design ICV pattern matching. 

set WRITE_GDS_DPT_LAYERS                                "" ;# Optional; List of DPT layers for write_gds -write_default_layers option

set WRITE_GDS_LAYER_MAP_FILE                            "" ;# Optional; A layer map file which provides a mapping between the tool and GDS layers

set WRITE_GDS_RENAME_CELL_FILE                          "" ;# Optional; A file; if specified, will be used in write_gds and write_verilog with -rename_cell option to output cell names according to the file

set WRITE_GDS_MASK_SHIFTED_SUFFIX                       "" ;# Optional; Specify the suffix string of mask shifted cell master. Tool default is SHIFT.

set WRITE_GDS_PROPAGATE_PIN_MASK_TO_VIA_METAL           false ;# Optional; Default false; true|false; used in some nodes; set true to propagate the mask property of metal1 pin to the corresponding
                                                        ;# metal1 layer enclosure of the dropped via (runtime-only).
                                                        ;# For stitched pins, propagation is for the mask that via surround is fully contained 
                                                        ;# inside with; otherwise, propagation is for latest geometry that partially covers it.

set WRITE_OASIS_LAYER_MAP_FILE                          "" ;# Optional; A layer map file which provides a mapping between the tool and OASIS layers

set WRITE_OASIS_DPT_LAYERS                              "" ;# Optional; A list of DPT layers for write_oasis -write_default_layers option

set WRITE_OASIS_RENAME_CELL_FILE                        "" ;# Optional; A file; if specified, will be used in write_oasis with -rename_cell option to output cell names according to the file

set WRITE_OASIS_MASK_SHIFTED_SUFFIX                     "" ;# Optional; Specify the suffix string of mask shifted cell master. Tool default is SHIFT.

set WRITE_OASIS_PROPAGATE_PIN_MASK_TO_VIA_METAL         false ;# Optional; Default false; true|false; used in some nodes; set true to propagate the mask property of metal1 pin to the corresponding
                                                        ;# metal1 layer enclosure of the dropped via (runtime-only).
                                                        ;# For stitched pins, propagation is for the mask that via surround is fully contained 
                                                        ;# inside with; otherwise, propagation is for latest geometry that partially covers it.

