gmapsupp.img : output/splitter
	@echo step 3 of 3- compiling...
	java -Xmx4000M -jar ~/mkgmap/mkgmap.jar --gmapsupp --style-file=styles --style=clean output/splitter/*.osm.pbf

dependencies: splitterbuild osmconvert osmupdate

clean : 
	rm -rf temp osmupdate_temp output *.runlog *6324*.img osmmap.img osmmap.tdb

output/splitter : output/sorteddata.osm.pbf
	@echo step 2 of 3 - splitting...
	./split.sh

output/sorteddata.osm.pbf: output
	@echo step 1 of 3 - removing names and sorting...
	osmosis --read-pbf countries.osm.pbf --tag-transform file=removenames.xml --sort --write-pbf file=output/sorteddata.osm.pbf

output/mergeddata.osm.pbf: output
	cp countries.osm.pbf output/mergeddata.osm.pbf

splitter:
	svn co http://svn.mkgmap.org.uk/splitter/trunk splitter

osmconvert:
	cc -x c -lz -O3 -o osmconvert osmconvert.c

osmupdate:
	cc -x c -o osmupdate osmupdate.c

splitterbuild: splitter always
	cd splitter && svn update && ant

output :
	mkdir output
	 
always:
