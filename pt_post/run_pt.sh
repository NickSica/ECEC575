TOP_LIST="ibex_top"
for top in $TOP_LIST; do
	TOP=$top pt_shell -f pt_post.tcl | tee logs/${top}.log 
done
