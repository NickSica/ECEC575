###########################################################################
### Floorplanning
###########################################################################

# -left,bottom,right,top_io2core not supported
initialize_floorplan -core_offset {5 5 5 5}
#initialize_floorplan -core_offset {10 10 10 10}
# too small -row_core_ratio 0.6
create_net -power VDD
create_net -ground VSS

set_attribute -objects [get_nets VSS] -name net_type -value ground
set_attribute -objects [get_nets VDD] -name net_type -value power

connect_pg_net -net VSS [get_pins -physical_context */VSS]
connect_pg_net -net VDD [get_pins -physical_context */VDD]
connect_pg_net

##Create VSS ring
create_pg_ring_pattern vss_ring -nets {VSS} \
	-horizontal_layer M7 -vertical_layer M6 \
	-horizontal_width 1.0 -vertical_width 1.0
set_pg_strategy vss -core \
	-pattern { \
		{name: vss_ring} \
		{nets: {VSS}} \
		{side_offset: { \
				{side: 1 2 3 4} \
				{offset: 0.5}}}} \
	-extension { \
		{{side: 1 3}{direction: T B}{stop: design_boundary}} \
	    	{{side: 2 4}{direction: L R}{stop: design_boundary}}}
 
## Create VDD Ring
create_pg_ring_pattern vdd_ring -nets {VDD} \
	-horizontal_layer M7 -vertical_layer M6 \
	-horizontal_width 1.0 -vertical_width 1.0 \
	-horizontal_spacing 1.8 -vertical_spacing 1.8
set_pg_strategy vdd -core \
	-pattern {{name: vdd_ring} \
		  {nets: {VDD}} \
		  {side_offset: {{side: 1 2 3 4}{offset: 3.5}}}} \
	-extension { \
		    {{side: 1 3}{direction: T B}{stop: design_boundary}} \
		    {{side: 2 4}{direction: L R}{stop: design_boundary}}}

create_pg_std_cell_conn_pattern M6_pattern -layers M6
create_pg_std_cell_conn_pattern M7_pattern -layers M7
#set_pg_strategy vss_rails -core \
#    -pattern {{name: M6_pattern}{nets: VSS}} \
#    -extension {stop: outermost_ring}
#set_pg_strategy vdd_rails -core \
#    -pattern {{name: M7_pattern}{nets: VDD}} \
#    -extension {stop: outermost_ring}

compile_pg -strategies {vss} -ignore_drc
compile_pg -strategies {vdd} -ignore_drc

#compile_pg -strategies {vss vss_rails} -ignore_drc
#compile_pg -strategies {vdd vdd_rails} -ignore_drc

## Creates Power Strap 

create_pg_strap -net VDD -layer M6 -start 3 -direction vertical -width 3  
create_pg_strap -net VSS -layer M6 -start 3 -direction vertical  -width 3

### Create Pins
# can be constrained using set_block_pin_constraints and create_pin_constraint
place_pins -self

## Save the design

save_block -as ${lib_name}_fp
