TOP_LIST="s1238 s15850 s35932 s386 s9234"
for top in $TOP_LIST; do
	TOP=$top dc_shell -f dc_synth.tcl 
done
