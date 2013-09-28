HOUR=$(shell /bin/bash -c "echo {0,1}{0,1,2,3,4,5,6,7,8,9} 2{0,1,2,3}")
MINUTE=$(shell /bin/bash -c "echo {0,1,2,3,4,5}{0,1,2,3,4,5,6,7,8,9}")
WEATHER=01d 02d 03d 04d 09d 10d 11d 13d 50d 01n 02n 03n 04n 09n 10n 11n 13n 50n

all:	png/clock-background.png $(HOUR:%=png/clock-hour-%.png) $(MINUTE:%=png/clock-minute-%.png) \
	$(WEATHER:%=png/weather-%.png)	  png/clock-hour-XX.png            png/clock-minute-XX.png

.SECONDARY:

%/.dir:
	mkdir -p $*
	touch $*/.dir

png/%.png:	png/.dir svg/%.svg
	rm -f png/$*.png
	inkscape -z --export-png=png/$*.png --file=svg/$*.svg

svg/clock-minute-%.svg:	svg/.dir clock.awk clock.svg
	gawk -v N=$* -v LAYER=Minute -f clock.awk clock.svg >svg/clock-minute-$*.svg

svg/clock-hour-%.svg:	svg/.dir clock.awk clock.svg
	gawk -v N=$* -v LAYER=Hour -f clock.awk clock.svg >svg/clock-hour-$*.svg

svg/clock-background.svg:	svg/.dir clock.awk clock.svg
	gawk -v N=$* -v LAYER=Background -f clock.awk clock.svg >svg/clock-background.svg

svg/weather-%.svg:	svg/.dir clock.awk clock.svg weather/%.png
	gawk -v I=$* -v LAYER=Weather -f clock.awk clock.svg >svg/weather-$*.svg

# http://bugs.openweathermap.org/projects/api/wiki/Weather_Condition_Codes
weather/%.png:
	mkdir -p weather
	wget -O weather/$*.png http://openweathermap.org/img/w/$*.png

#======================================================================

mobile:	all
	cp png/*.png /media/emmc/Tasker/clock2/
	rm -f /mnt/sdcard/Zoom/cache/*
	umount /media/emmc /media/ATRIX-SDHC

pack:
	rm -f ZOOM-CLOCK.7z
	7z a ZOOM-CLOCK.7z Tasker* Zoom* clock.awk clock.svg Makefile png/ WIKI.txt

clean:
	find . -name "*~" -delete

purge:	clean
	rm -fR svg png
