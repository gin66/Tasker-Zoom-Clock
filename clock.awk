BEGIN {
	if (N == "XX")
		N="??"
	else {
		# Calculate binary mask to filter layers
		i = 0
		b = 1
		x = N
		while (x > 0) {
			if (int(x/(2*b)) != x/(2*b)) {
				m[i] = 1
				x -= b
			}
			i++
			b *= 2
		}
	}
}

{	gsub(">00<",">" N "<")	}

/<g/ {
	ingroup++
}

(ingroup >= 1) {
	group = group $0 "\n"
}

(ingroup >= 1) && /<\/g>/ {
	ingroup--
	if (ingroup == 0) {
		# Apply filter
		if (group ~ ("inkscape:label=\"" LAYER)) {
			p = 1
			if (match(group,"inkscape:label=\"" LAYER "-B([0-5])",bit) > 0)
				p = (m[bit[1]] == 1)
print p,bit[1]
			if (p == 1)
				printf("%s",group)
		}
		group = ""
	}
	next
}

(ingroup >= 1) {next}


{
#	gsub(/width="[0-9]*"/,"width=\"264\"")
#	gsub(/height="[0-9]*"/,"height=\"323\"")
	
	print
}
