if { ![file exists ${lib_name}.dlib] } {
	create_lib ${lib_name}.dlib \
		-technology $techfile \
		-ref_libs ${ref_lib}
}
open_lib ${lib_name}.dlib

#set design_data ../dc_synth/output/fifo.ddc
set cell_name $top
#import_designs $design_data -format ddc -top $cell_name

set logic0_net VSS
set logic1_net VDD

#read_verilog -top $cell_name ../dc_synth/icc2/FIFO.v
read_verilog -top $cell_name $top.v

#uniquify_fp_mw_cel

link_block

read_sdc ../dc_synth/$const_dir/$top.sdc

read_parasitic_tech -tlup $tlupnom -layermap $tech2itf -name tlup_nom
set_parasitic_parameters -early_spec tlup_nom -late_spec tlup_nom
# -corners { default } 

save_block -as ${lib_name}_initial
