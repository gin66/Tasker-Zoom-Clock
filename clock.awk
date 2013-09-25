BEGIN {
	if (N == "XX")
		N="??"
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
		if (group ~ ("inkscape:label=\"" LAYER))
			printf("%s",group)
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
