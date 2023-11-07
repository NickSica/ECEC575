set_tlu_plus_files -max_tluplus $tlupnom -tech2itf_map $tech2itf

set lib_name $top.mw

create_mw_lib $lib_dir/$lib_name \
		 -technology $techfile \
		 -mw_reference_library $ref_lib 
open_mw_lib $lib_dir/$lib_name

#set design_data ../dc_synth/$output_dir/fifo.ddc
set cell_name $top
#import_designs $design_data -format ddc -top $cell_name

read_verilog $top.v

uniquify_fp_mw_cel

link

read_sdc ../dc_synth/$const_dir/$top.sdc

save_mw_cel -as initial
