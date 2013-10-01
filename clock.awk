BEGIN {
	ZOOM += 0
	if (length(N) > 0) {
		# Calculate binary mask to filter layers
		i = 0;	b = 1;	x = N
		while (x > 0) {
			if (int(x/(2*b)) != x/(2*b)) {
				m[i] = 1;	x -= b
			}
			i++;	b *= 2
		}
	}
}
(length(N)>0)	{gsub(">00<",">" N "<") }
(length(I)>0) 	{gsub("weather/[0-9dn]*.png","weather/" I ".png") }
/<g/ 		{ingroup++; group=""	}
(ingroup >= 1)	{
	group = group $0 "\n"
	if (/<\/g>/) {
		ingroup--
		if (ingroup == 0) {
			if (group ~ "inkscape:groupmode=\"layer\"") {
				if (match(group,"inkscape:label=\"([^\"]*)\"",fld) > 0) {
					_layer = fld[1]
					zoomel[++z] = _layer
				}
				if (ZOOM == 0) {
					# Print group, if _layer fits to filter
					if (_layer ~ LAYER) {
						p = 1
						if (match(_layer,LAYER "-B([0-5])",bit) > 0)
							p = (m[bit[1]] == 1)
						if (p == 1)
							printf("%s",group)
					}
				}
			}
		}
	}
	next
}
(ZOOM == 0) 	{print	}

END {
	if (ZOOM == 1) {
		for (i = 1;i <= z;i++)
			print i,zoomel[i]
	}
}
