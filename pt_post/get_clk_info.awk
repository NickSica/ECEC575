{
        if( $0 ~ /ideal_clock1/ ){
		sinks = $2
		buffs = $3
		skew  = $5
	}
}

END {
	print "sinks="sinks
	print "buffs="buffs
	print "skew="skew
}
