{
	if( $0 ~ /Total Negative Slack/ ){
		if( tns == "" || $NF < tns){
			tns = $NF
		}
	}

	if( $0 ~ /Design Area/ ) {
		area = $NF 
	}

	if( $0 ~ /Critical Path Slack/ ) {
		if(wns == "" || $NF < wns) {
			wns = $NF
		} 
	}

        if( $0 ~ /Leaf Cell Count/ ) {
		cell_count = $NF
	}

        if( $0 ~ /No\. of Violating Paths/ ){
		if(drc == "" || $NF > drc) {
			drc = $NF
		}
	}
}

END {
	print "wns="wns
	print "tns="tns
	print "area="area
	print "cell_count="cell_count
	print "drc="drc
}
