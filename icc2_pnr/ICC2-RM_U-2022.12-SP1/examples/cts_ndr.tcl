##########################################################################################
# Script: cts_ndr.tcl
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################

########################################################################
## Variables to control clock NDR
########################################################################
## For root clock nets
set CTS_NDR_RULE_NAME			"" ;# Specify a clock NDR rule for root nets;
					;# required for the example script to work on the root and internal nets.
					;# Below are the 3 predefined rules supported:  
					;# rm_2w2s : double width double spacing 
					;# rm_2w2s_shield_default : double width double spacing + shielding with default width and spacing
					;# rm_2w2s_shield_list : double width double spacing + shielding with customized per layer width and spacing
set CTS_NDR_SHIELDING_LAYER_WIDTH_LIST 	"" ;# A list of layer_name shield_width ,for ex, "M1 0.1 M2 0.1 M3 0.1";
					;# required if you specify rm_2w2s_shield_list as CTS_NDR_RULE_NAME.
set CTS_NDR_SHIELDING_LAYER_SPACING_LIST "" ;# A list of layer_name shield_spacing, for ex, "M1 0.1 M2 0.1 M3 0.1";
					;# required if you specify rm_2w2s_shield_list as CTS_NDR_RULE_NAME.
set CTS_NDR_MIN_ROUTING_LAYER		"" ;# Min routing layer for set_clock_routing_rules to which CTS_NDR_RULE_NAME is applied. 
set CTS_NDR_MAX_ROUTING_LAYER		"" ;# Max routing layer for set_clock_routing_rules to which CTS_NDR_RULE_NAME is applied.

## For internal clock nets (by default same values as with the root clock nets)
set CTS_INTERNAL_NDR_RULE_NAME		"$CTS_NDR_RULE_NAME" ;# Specify a clock NDR rule for internal nets; default is same as CTS_NDR_RULE_NAME;
					;# required for the example script to work on the internal nets.
					;# Below are the 3 predefined rules supported:  
					;# rm_2w2s : double width double spacing 
					;# rm_2w2s_shield_default : double width double spacing + shielding with default width and spacing
					;# rm_2w2s_shield_list : double width double spacing + shielding with customized per layer width and spacing
set CTS_INTERNAL_NDR_SHIELDING_LAYER_WIDTH_LIST "$CTS_NDR_SHIELDING_LAYER_WIDTH_LIST" ;# A list of layer_name shield_width ,for ex, "M1 0.1 M2 0.1 M3 0.1";
					;# required if you specify rm_2w2s_shield_list as CTS_INTERNAL_NDR_RULE_NAME.
set CTS_INTERNAL_NDR_SHIELDING_LAYER_SPACING_LIST "$CTS_NDR_SHIELDING_LAYER_SPACING_LIST" ;# A list of layer_name shield_spacing, for ex, "M1 0.1 M2 0.1 M3 0.1";
					;# required if you specify rm_2w2s_shield_list as CTS_INTERNAL_NDR_RULE_NAME.
set CTS_INTERNAL_NDR_MIN_ROUTING_LAYER "$CTS_NDR_MIN_ROUTING_LAYER" ;# Min routing layer for set_clock_routing_rules to which CTS_INTERNAL_NDR_RULE_NAME is applied. 
set CTS_INTERNAL_NDR_MAX_ROUTING_LAYER "$CTS_NDR_MAX_ROUTING_LAYER" ;# Max routing layer for set_clock_routing_rules to which CTS_INTERNAL_NDR_RULE_NAME is applied.

## For leaf clock nets
set CTS_LEAF_NDR_RULE_NAME 		"" ;# Specify rm_leaf as the predefined rule for the example script to prepare a default rule for leaf nets
set CTS_LEAF_NDR_MIN_ROUTING_LAYER 	$CTS_NDR_MIN_ROUTING_LAYER ;# Min routing layer for set_clock_routing_rules to which rm_leaf is applied.
set CTS_LEAF_NDR_MAX_ROUTING_LAYER 	$CTS_NDR_MAX_ROUTING_LAYER ;# Max routing layer for set_clock_routing_rules to which rm_leaf is applied.

if {$CTS_NDR_RULE_NAME == "" && $CTS_INTERNAL_NDR_RULE_NAME == "" && $CTS_LEAF_NDR_RULE_NAME == ""} {
	puts "RM-info: [info script] is skipped. None of CTS_NDR_RULE_NAME, CTS_INTERNAL_NDR_RULE_NAME, or CTS_LEAF_NDR_RULE_NAME is specified."
} else {

##########################################################################################
# NDR for root nets (CTS_NDR_RULE_NAME)
##########################################################################################
## - specify rm_2w2s to create a double width and double spacing rule
## - specify rm_2w2s_shield_default to create a double width and spacing + shielding with default width and spacing rule
## - specify rm_2w2s_shield_list to create a double width and spacing + shielding with customized width and spacing rule

## Rule creation (create_routing_rule) for root nets ##
if {$CTS_NDR_RULE_NAME != ""} {
	redirect -var x {report_routing_rules $CTS_NDR_RULE_NAME}
	if {[regexp "Error" $x]} {
		## Create the NDR if it is not present
		if {$CTS_NDR_RULE_NAME == "rm_2w2s"} {
			create_routing_rule $CTS_NDR_RULE_NAME -default_reference_rule -multiplier_width 2 -multiplier_spacing 2
		} elseif {$CTS_NDR_RULE_NAME == "rm_2w2s_shield_default"} {
			create_routing_rule $CTS_NDR_RULE_NAME -default_reference_rule -multiplier_width 2 -multiplier_spacing 2 -shield
		} elseif {$CTS_NDR_RULE_NAME == "rm_2w2s_shield_list"} {
			if {$CTS_NDR_SHIELDING_LAYER_WIDTH_LIST != "" || $CTS_NDR_SHIELDING_LAYER_SPACING_LIST != ""} {
				set create_routing_rule_cmd "create_routing_rule $CTS_NDR_RULE_NAME -default_reference_rule -multiplier_width 2 -multiplier_spacing 2"
				if {$CTS_NDR_SHIELDING_LAYER_WIDTH_LIST != ""} {lappend create_routing_rule_cmd -shield_widths $CTS_NDR_SHIELDING_LAYER_WIDTH_LIST} 
				if {$CTS_NDR_SHIELDING_LAYER_SPACING_LIST != ""} {lappend create_routing_rule_cmd -shield_spacings $CTS_NDR_SHIELDING_LAYER_SPACING_LIST}
				puts "RM-info: $create_routing_rule_cmd"
        	                eval {			eval ${create_routing_rule_cmd}}
			} else {
				puts "RM-error : CTS_NDR_SHIELDING_LAYER_WIDTH_LIST or CTS_NDR_SHIELDING_LAYER_SPACING_LIST not specified which is required by $CTS_NDR_RULE_NAME"
			}
		} else {
			puts "RM-error : $CTS_NDR_RULE_NAME is not a supported rule name. Rule is not created. Please double check"
		}
	} else {
		puts "RM-info: CTS_NDR_RULE_NAME($CTS_NDR_RULE_NAME) already exists. Rule creation skipped."
	}
}

## Rule association (set_clock_routing_rules) for root nets ##
if {$CTS_NDR_RULE_NAME != ""} {
	# Check if the rule has been created properly
	redirect -var x {report_routing_rules $CTS_NDR_RULE_NAME}
	if {![regexp "Error" $x]} {
		# set_clock_routing_rules on root nets
		set set_clock_routing_rules_cmd_root "set_clock_routing_rules -net_type root -rule $CTS_NDR_RULE_NAME"
		if {$CTS_NDR_MIN_ROUTING_LAYER != ""} {lappend set_clock_routing_rules_cmd_root -min_routing_layer $CTS_NDR_MIN_ROUTING_LAYER}
		if {$CTS_NDR_MAX_ROUTING_LAYER != ""} {lappend set_clock_routing_rules_cmd_root -max_routing_layer $CTS_NDR_MAX_ROUTING_LAYER}
		puts "RM-info: $set_clock_routing_rules_cmd_root"
		eval {			eval ${set_clock_routing_rules_cmd_root}}
	} else {
		puts "RM-error: CTS_NDR_RULE_NAME($CTS_NDR_RULE_NAME) hasn't been created yet. Can not associate it with root nets!"
	}
}

##########################################################################################
# NDR for internal nets (CTS_INTERNAL_NDR_RULE_NAME)
##########################################################################################
## - specify rm_2w2s to create a double width and double spacing rule
## - specify rm_2w2s_shield_default to create a double width and spacing + shielding with default width and spacing rule
## - specify rm_2w2s_shield_list to create a double width and spacing + shielding with customized width and spacing rule

## Rule creation (create_routing_rule) for internal nets ##
if {$CTS_INTERNAL_NDR_RULE_NAME != ""} {
	redirect -var x {report_routing_rules $CTS_INTERNAL_NDR_RULE_NAME}
	if {[regexp "Error" $x]} {
		## Create the NDR if it is not present
		if {$CTS_INTERNAL_NDR_RULE_NAME == "rm_2w2s"} {
			create_routing_rule $CTS_INTERNAL_NDR_RULE_NAME -default_reference_rule -multiplier_width 2 -multiplier_spacing 2
		} elseif {$CTS_INTERNAL_NDR_RULE_NAME == "rm_2w2s_shield_default"} {
			create_routing_rule $CTS_INTERNAL_NDR_RULE_NAME -default_reference_rule -multiplier_width 2 -multiplier_spacing 2 -shield
		} elseif {$CTS_INTERNAL_NDR_RULE_NAME == "rm_2w2s_shield_list"} {
			if {$CTS_INTERNAL_NDR_SHIELDING_LAYER_WIDTH_LIST != "" || $CTS_INTERNAL_NDR_SHIELDING_LAYER_SPACING_LIST != ""} {
				set create_routing_rule_cmd "create_routing_rule $CTS_INTERNAL_NDR_RULE_NAME -default_reference_rule -multiplier_width 2 -multiplier_spacing 2"
				if {$CTS_INTERNAL_NDR_SHIELDING_LAYER_WIDTH_LIST != ""} {lappend create_routing_rule_cmd -shield_widths $CTS_INTERNAL_NDR_SHIELDING_LAYER_WIDTH_LIST} 
				if {$CTS_INTERNAL_NDR_SHIELDING_LAYER_SPACING_LIST != ""} {lappend create_routing_rule_cmd -shield_spacings $CTS_INTERNAL_NDR_SHIELDING_LAYER_SPACING_LIST}
				puts "RM-info: $create_routing_rule_cmd"
        	                eval {			eval ${create_routing_rule_cmd}}
			} else {
				puts "RM-error : CTS_INTERNAL_NDR_SHIELDING_LAYER_WIDTH_LIST or CTS_INTERNAL_NDR_SHIELDING_LAYER_SPACING_LIST not specified which is required by $CTS_INTERNAL_NDR_RULE_NAME"
			}
		} else {
			puts "RM-error : $CTS_INTERNAL_NDR_RULE_NAME is not a supported rule name. Rule is not created. Please double check"
		}
	} else {
		puts "RM-info: CTS_INTERNAL_NDR_RULE_NAME($CTS_INTERNAL_NDR_RULE_NAME) already exists. Rule creation skipped."
	}
}

## Rule association (set_clock_routing_rules) for internal nets ##
if {$CTS_INTERNAL_NDR_RULE_NAME != ""} {
	# Check if the rule has been created properly
	redirect -var x {report_routing_rules $CTS_INTERNAL_NDR_RULE_NAME}
	if {![regexp "Error" $x]} {
		# set_clock_routing_rules on internal nets
		set set_clock_routing_rules_cmd_internal "set_clock_routing_rules -net_type internal -rule $CTS_INTERNAL_NDR_RULE_NAME"
		if {$CTS_INTERNAL_NDR_MIN_ROUTING_LAYER != ""} {lappend set_clock_routing_rules_cmd_internal -min_routing_layer $CTS_INTERNAL_NDR_MIN_ROUTING_LAYER}
		if {$CTS_INTERNAL_NDR_MAX_ROUTING_LAYER != ""} {lappend set_clock_routing_rules_cmd_internal -max_routing_layer $CTS_INTERNAL_NDR_MAX_ROUTING_LAYER}
		puts "RM-info: $set_clock_routing_rules_cmd_internal"
		eval {			eval ${set_clock_routing_rules_cmd_internal}}
	} else {
		puts "RM-error: CTS_INTERNAL_NDR_RULE_NAME($CTS_INTERNAL_NDR_RULE_NAME) hasn't been created yet. Can not associate it with internal nets!"
	}
}

##########################################################################################
# NDR for leaf (sink) nets (CTS_LEAF_NDR_RULE_NAME)
##########################################################################################
## - specify rm_leaf to create a default reference rule for leaf nets

## Rule creation (create_routing_rule) for leaf nets ##
if {$CTS_LEAF_NDR_RULE_NAME != ""} {
	redirect -var x {report_routing_rules $CTS_LEAF_NDR_RULE_NAME}
	if {[regexp "Error" $x]} {
		## Create the NDR if it is not present
		if {$CTS_LEAF_NDR_RULE_NAME == "rm_leaf"} {
			create_routing_rule $CTS_LEAF_NDR_RULE_NAME -default_reference_rule
		} else {
			puts "RM-error : $CTS_LEAF_NDR_RULE_NAME is not a supported rule name. Rule is not created. Please double check"
		}
	} else {
		puts "RM-info: CTS_LEAF_NDR_RULE_NAME($CTS_LEAF_NDR_RULE_NAME) already exists. Rule creation skipped"
	}
}

## Rule association (set_clock_routing_rules) for leaf nets ##
if {$CTS_LEAF_NDR_RULE_NAME != ""} {
	# Check if the rule has been created properly
	redirect -var x {report_routing_rules $CTS_LEAF_NDR_RULE_NAME}
	if {![regexp "Error" $x]} {
		set set_clock_routing_rules_cmd_leaf "set_clock_routing_rules -net_type sink -rule $CTS_LEAF_NDR_RULE_NAME"
		if {$CTS_LEAF_NDR_MIN_ROUTING_LAYER != ""} {lappend set_clock_routing_rules_cmd_leaf -min_routing_layer $CTS_LEAF_NDR_MIN_ROUTING_LAYER}
		if {$CTS_LEAF_NDR_MAX_ROUTING_LAYER != ""} {lappend set_clock_routing_rules_cmd_leaf -max_routing_layer $CTS_LEAF_NDR_MAX_ROUTING_LAYER}
		puts "RM-info: $set_clock_routing_rules_cmd_leaf"
		eval $set_clock_routing_rules_cmd_leaf
	} else {
		puts "RM-error: CTS_LEAF_NDR_RULE_NAME($CTS_LEAF_NDR_RULE_NAME) hasn't been created yet. Can not associate it with leaf nets!"
	}
}

}

