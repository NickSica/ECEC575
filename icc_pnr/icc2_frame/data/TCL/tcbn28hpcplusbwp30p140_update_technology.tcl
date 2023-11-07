set layer [get_layers M1]
set_attribute -objects $layer -name routing_direction -value vertical
set_attribute -objects $layer -name track_offset -value 0.070
set layer [get_layers M2]
set_attribute -objects $layer -name routing_direction -value horizontal
set_attribute -objects $layer -name track_offset -value 0.000
set layer [get_layers M3]
set_attribute -objects $layer -name routing_direction -value vertical
set_attribute -objects $layer -name track_offset -value 0.070
set layer [get_layers M4]
set_attribute -objects $layer -name routing_direction -value horizontal
set_attribute -objects $layer -name track_offset -value 0.000
set layer [get_layers M5]
set_attribute -objects $layer -name routing_direction -value vertical
set_attribute -objects $layer -name track_offset -value 0.070
set layer [get_layers M6]
set_attribute -objects $layer -name routing_direction -value horizontal
set_attribute -objects $layer -name track_offset -value 0.000
set layer [get_layers M7]
set_attribute -objects $layer -name routing_direction -value vertical
set_attribute -objects $layer -name track_offset -value 0.070
set layer [get_layers M8]
set_attribute -objects $layer -name routing_direction -value horizontal
set_attribute -objects $layer -name track_offset -value 0.000
set layer [get_layers M9]
set_attribute -objects $layer -name routing_direction -value vertical
set_attribute -objects $layer -name track_offset -value 0.070
set layer [get_layers M10]
set_attribute -objects $layer -name routing_direction -value horizontal
set_attribute -objects $layer -name track_offset -value 0.000
set layer [get_layers AP]
set_attribute -objects $layer -name routing_direction -value vertical
set_attribute -objects $layer -name track_offset -value 0.070
set site_def [get_site_defs gaunit]
set_attribute -objects $site_def -name symmetry -value "X Y"
set site_def [get_site_defs unit]
set_attribute -objects $site_def -name symmetry -value "X Y"
set_attribute -objects [get_site_defs] -name is_default -value false
set_attribute -objects $site_def -name is_default -value true
