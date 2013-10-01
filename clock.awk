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

/width=/ && (widthLand == "") { 
	match($0,/.*width="([0-9]*)".*/,fld)
	widthLand = fld[1]
	widthPort = fld[1]
	xLand      = 0
}
/height=/ && (heightLand == "") { 
	match($0,/.*height="([0-9]*)".*/,fld)
	heightLand = fld[1]
	heightPort = fld[1]
	yLand      = 0
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
					zoomsvg[z]  = group
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
	if (ZOOM == 0)
		exit(0)

	# Do the elements from back to front (same as layers)
	xmlcount = 0

	for (i = 1;i <= z;i++) {
		if (match(zoomel[i],"(Background|Hour|Minute|Weather)",fld) > 0) {
			if (!(fld[1] in done)) {
				xml[xmlcount++] = simple_image(fld[1])
				done[fld[1]] = 0
			}
		}
		if (zoomel[i] ~ /Sensor/) {
			xml[xmlcount++] = sensor(zoomsvg[i],"Sensor" (++sens))
		}
		if (zoomel[i] ~ /Battery/) {
			xml[xmlcount++] = sensor(zoomsvg[i],"Battery")
		}
#		print i,zoomel[i]
	}


	# Pre/postamble
	xsize = 4
	ysize = 2
	name  = "Clock.image.w"
	pre = "<class name=\"Template\" index=\"\">"
	pre = pre "\n\t<backColour>#00000000</backColour>"
	pre = pre "\n\t<borderColour>#FFFFFFFF</borderColour>"
	pre = pre "\n\t<borderWidth>0</borderWidth>"
	pre = pre "\n\t<cellData>122,154,16,14;159,111,0,0</cellData>"
	pre = pre "\n\t<cellsHigh>" ysize "</cellsHigh>"
	pre = pre "\n\t<cellsWide>" xsize "</cellsWide>"
	pre = pre "\n\t<marginWidth>4</marginWidth>"
	pre = pre "\n\t<name>" name "</name>"
	post = "</class>"

	# Do the printing
	print pre
	for (i=0;i < xmlcount;i++)
		print xml[i]
	print post
}


# SIMPLE IMAGE
function simple_image(layer) {
	x =     "\t<class name=\"Element\" index=\"elements" xmlcount "\">"
	x = x "\n\t\t<elementType>Image</elementType>"
	x = x "\n\t\t<name>" layer "</name>"
	x = x "\n\t\t<visible>true</visible>"
	x = x "\n\t\t<heightLand>" heightLand "</heightLand>"
	x = x "\n\t\t<widthLand>" widthLand "</widthLand>"
	x = x "\n\t\t<xLand>" xLand "</xLand>"
	x = x "\n\t\t<yLand>" yLand "</yLand>"
	x = x "\n\t\t<heightPort>" heightPort "</heightPort>"
	x = x "\n\t\t<widthPort>" widthPort "</widthPort>"
	x = x "\n\t\t<xPort>0</xPort>"
	x = x "\n\t\t<yPort>0</yPort>"
	x = x "\n\t\t<class name=\"ImageElement\" index=\"state0\">"
	x = x "\n\t\t\t<alpha>255</alpha>"
	x = x "\n\t\t\t<stateName></stateName>"
	x = x "\n\t\t\t<uri>file:/mnt/emmc/Tasker/clock2/clock-background.png</uri>"
	x = x "\n\t\t</class>"
	x = x "\n\t</class>"
	return x
}

function sensor(group,name) {
	match(group,"<rect([^/]*)/>",fld)
	rect = fld[1]
	match(rect,/.*width="([0-9\.]*)".*/,fld) ;rect_w = int(fld[1])
	match(rect,/.*height="([0-9\.]*)".*/,fld);rect_h = int(fld[1])
	match(rect,/.*x="([0-9\.]*)".*/,fld)     ;rect_x = int(fld[1])
	match(rect,/.*y="([0-9\.]*)".*/,fld)     ;rect_y = int(fld[1])

	match(group,"<text(.*)</text>",fld)
	txt = fld[1]
	has_sensor = match(txt,/.*>([a-zA-Z\.]*)<.*/,fld)
	if (has_sensor > 0) {
		action = fld[1]; package = action
		gsub(/\.[^\.]*$/,"",package)
	}
	# print rect_w,rect_h,rect_x,rect_y,action

	x =     "\t<class name=\"Element\" index=\"elements" xmlcount "\">"
	x = x "\n\t\t<elementType>Rect</elementType>"
	x = x "\n\t\t<name>" name "</name>"
	x = x "\n\t\t<visible>true</visible>"
	x = x "\n\t\t<heightLand>" heightLand "</heightLand>"
	x = x "\n\t\t<widthLand>" widthLand "</widthLand>"
	x = x "\n\t\t<xLand>" xLand "</xLand>"
	x = x "\n\t\t<yLand>" yLand "</yLand>"
	x = x "\n\t\t<heightPort>" rect_h "</heightPort>"
	x = x "\n\t\t<widthPort>" rect_w "</widthPort>"
	x = x "\n\t\t<xPort>" rect_x "</xPort>"
	x = x "\n\t\t<yPort>" rect_y "</yPort>"
	x = x "\n\t\t<class name=\"RectElement\" index=\"state0\">"
	x = x "\n\t\t\t<cornerRadius>0</cornerRadius>"
	x = x "\n\t\t\t<corners>all</corners>"
	x = x "\n\t\t\t<endColour>#00000000</endColour>"
#	x = x "\n\t\t\t<endColour>#FFFFFFFF</endColour>"
	x = x "\n\t\t\t<shade>none</shade>"
	x = x "\n\t\t\t<startColour>#00000000</startColour>"
#	x = x "\n\t\t\t<startColour>#FFFFFFFF</startColour>"
	if (has_sensor > 0) {
		x = x "\n\t\t\t<class name=\"LoadAppAction\" index=\"onClick0\">"
		x = x "\n\t\t\t\t<class name=\"AppData\" index=\"AppData\">"
		x = x "\n\t\t\t\t\t<className>" action "</className>"
		x = x "\n\t\t\t\t\t<packageName>" package "</packageName>"
		x = x "\n\t\t\t\t</class>"
		x = x "\n\t\t\t</class>"
	}
	x = x "\n\t\t\t<stateName></stateName>"
	x = x "\n\t\t</class>"
	x = x "\n\t</class>"
	return x
}
