src_dir=src
ibex_dir=~/ibex
mkdir $src_dir
cp $ibex_dir/rtl/* $src_dir
cp $ibex_dir/syn/rtl/latch_map.v $src_dir

mkdir $src_dir/prim_uvm
cp $ibex_dir/dv/uvm/core_ibex/common/prim/* $src_dir/prim_uvm/

mkdir $src_dir/prim_generic_rtl
cp $ibex_dir/vendor/lowrisc_ip/ip/prim_generic/rtl/* $src_dir/prim_generic_rtl/
rm $src_dir/prim_generic_rtl/prim_generic_flash.sv
rm $src_dir/prim_generic_rtl/prim_generic_flash_bank.sv
rm $src_dir/prim_generic_rtl/prim_generic_ram_2p.sv
rm $src_dir/prim_generic_rtl/prim_generic_otp.sv

mkdir $src_dir/prim_rtl
cp $ibex_dir/vendor/lowrisc_ip/ip/prim/rtl/* $src_dir/prim_rtl/
