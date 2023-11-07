##########################################################################################
## Script: multi_vth_constraint_script.tcl
## Version: U-2022.12
## Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
###########################################################################################


set VT_CLASS_HVT_LIB_regexp             [list ] ; # defines high_vt voltage group
set VT_CLASS_SVT_LIB_regexp             [list ] ; # defines normal_vt voltage group
set VT_CLASS_LVT_LIB_regexp             [list ] ; # defines low_vt voltage group

foreach lib $VT_CLASS_HVT_LIB_regexp  { set_attribute [get_lib_cells -quiet $lib ] threshold_voltage_group hvt -quiet}
foreach lib $VT_CLASS_SVT_LIB_regexp  { set_attribute [get_lib_cells -quiet $lib ] threshold_voltage_group svt -quiet}
foreach lib $VT_CLASS_LVT_LIB_regexp  { set_attribute [get_lib_cells -quiet $lib ] threshold_voltage_group lvt -quiet}

if {[sizeof [get_lib_cells -filter "threshold_voltage_group == hvt"]]} {
        set_threshold_voltage_group_type -type high_vt   {hvt}
}

if {[sizeof [get_lib_cells -filter "threshold_voltage_group == svt"]]} {
        set_threshold_voltage_group_type -type normal_vt {svt}
}

if {[sizeof [get_lib_cells -filter "threshold_voltage_group == lvt"]]} {
        set_threshold_voltage_group_type -type low_vt    {lvt}
}

set ENABLE_AUTO_MULTI_VT_CONSTRAINT	false ; # Enable multi vth constraint on the design 
set LVT_percentage                      ""  ; # User defined percentage of LVT to constrain. 

##Usage: auto_multi_vth_constraint    # Automatically assigns a multi vth constraint on the design
##        [-force]               (Apply constraint even if previously set)
##        [-apply]               (Add the constraint to the design)
##        [-cost cost]           (Which cost to use for auto applying multi vth constraint. (Default: cell_count): 
##                                Values: cell_count, area)
##        [-percentage percentage]
##                               (Percentage of LVT to constrain (Default 30 if >3 VT groups. 90 if only 2 VT groups))

## Apply multi vth constraint on the design.  If the LVT_percentage variable is undefined, the auto_multi_vth_cmd command will automatically constrain the percentage of LVT to 30%
## for > 3 VT groups and 90% if only 2 VT groups. 
if {$ENABLE_AUTO_MULTI_VT_CONSTRAINT} {
   if {$SET_QOR_STRATEGY_METRIC != "timing"} {
      set auto_multi_vth_cmd "auto_multi_vth_constraint -apply"
      if {$LVT_percentage != "" } {lappend auto_multi_vth_cmd -percentage ${LVT_percentage} }
      puts "RM-info: Running ${auto_multi_vth_cmd}"
      eval ${auto_multi_vth_cmd}
   }
}
