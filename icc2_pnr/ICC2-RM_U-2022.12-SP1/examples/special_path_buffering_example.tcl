##########################################################################################
# Script: special_path_buffering_example.tcl (example)
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################

## Description:
# For timing_paths that need specific handling to minimize the buffer chain delay
#
# Use the global router and add_buffer_on_route to use a buffer reference of your choice 
# to get the optimial timing on a prerouted design. For two-pin nets traversing long 
# distances to priority use the faster, higher routing layers

# 1. Identify the driver/sink pin pair 
set driver_pin <STARTPOINT_PIN>
set sink_pin <ENDPOINT_PIN>
set min_layer <MIN_ROUTING_LAYER>
set max_layer <MAX_ROUTING_LAYER>
set buffer_lib_cell <BUFFER_LIB_CELL>
set buffer_distance <DISTANCE_BETWEEN_BUFFERS>

# 2. Remove the existing buffer chain
remove_buffer_trees -from $driver_pin -source_of $sink_pin
set net [get_flat_nets -of_objects $driver_pin]

# 3. Remove any existing routing shapes from the net
remove_shapes [get_shapes -quiet -of_objects $net]

# 4. Optionally apply min/max constraints on the net to keep the global routes on specific layers
set_routing_rule $net -min_routing_layer $min_layer -max_routing $max_layer

# 5. Global route the net to let the router find the optimal path on your preferred layers
route_group -nets $net -stop_after_global_route true

# 6. Add buffers on the route at your specified buffer distances.
add_buffer_on_route -lib_cell $buffer_lib_cell -cell_prefix special_buffer -net_prefix special_buffer -respect_blockages -repeater_distance $buffer_distance -only_global_routed_nets -snap_to_sites -first_distance 1 $net 

# 7. Legalize the newly inserted buffers
legalize_placement -incremental

# 8. Patch the new global routes after legalization displacement
set new_nets [add_to_collection $net [get_nets -hierarchical special_buffer*]]
route_group -nets $new_nets -stop_after_global_route true -reuse_existing_global_route true

# 9. Set newly added buffers as legalize_only to keep your special buffers in place
set new_cells [get_cells -hierarchical special_buffer*]
set_attribute $new_cells physical_status legalize_only

