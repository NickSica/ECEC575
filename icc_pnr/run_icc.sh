TOP_LIST="ibex_top"
for top in $TOP_LIST; do
	TOP=$top icc_shell -64bit -shared_license -f icc_pnr.tcl | tee logs/${top}.log 
done
