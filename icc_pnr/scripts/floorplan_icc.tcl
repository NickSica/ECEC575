###########################################################################
### Floorplanning
###########################################################################

create_floorplan -core_utilization 0.6 -left_io2core 5 -bottom_io2core 5 -right_io2core 5 -top_io2core 5

save_mw_cel -as init_fp

remove_net $power_net
remove_net $ground_net

derive_pg_connection -power_net $power_net -ground_net $ground_net
derive_pg_connection -power_net $power_net -ground_net $ground_net -tie

##Create GND ring
create_rectangular_rings  -nets $ground_net -left_offset 0.5  -left_segment_layer M6 -left_segment_width 1.0 -extend_ll -extend_lh -right_offset 0.5 -right_segment_layer M6 -right_segment_width 1.0 -extend_rl -extend_rh -bottom_offset 0.5  -bottom_segment_layer  M7 -bottom_segment_width 1.0 -extend_bl -extend_bh -top_offset 0.5 -top_segment_layer M7 -top_segment_width 1.0 -extend_tl -extend_th

## Create VDD Ring
create_rectangular_rings -nets $power_net -left_offset 1.8  -left_segment_layer M6 -left_segment_width 1.0 -extend_ll -extend_lh -right_offset 1.8 -right_segment_layer M6 -right_segment_width 1.0 -extend_rl -extend_rh -bottom_offset 1.8  -bottom_segment_layer M7 -bottom_segment_width 1.0 -extend_bl -extend_bh -top_offset 1.8 -top_segment_layer M7 -top_segment_width 1.0 -extend_tl -extend_th

## Creates Power Strap 
create_power_strap -nets $power_net -layer M6 -direction vertical -width 3  
create_power_strap -nets $ground_net -layer M6 -direction vertical  -width 3

save_mw_cel -as pow_rings

## Save the design
create_fp_placement

save_mw_cel -as create_fp

preroute_standard_cells -route_pins_on_layer M1

save_mw_cel -as fp
report_fp_placement > $reports_dir/fp_placement.rpt
