TOP_LIST="ibex_top"
for top in $TOP_LIST; do
	TOP=$top icc2_shell -64bit -f icc_pnr.tcl | tee logs/${top}.log 
done
