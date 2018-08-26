gmapsupp.img : $(countries) output/splitter
	@echo step 4 of 4 - compiling...
	java -Xmx4000M -jar mkgmap/dist/mkgmap.jar --gmapsupp --route --style-file=styles --style=clean output/splitter/*.osm.pbf

dependencies: mkgmapbuild splitterbuild osmconvert osmupdate

clean : 
	rm -rf temp osmupdate_temp output *.runlog *6324*.img osmmap.img osmmap.tdb

output/splitter : $(countries) output/sorteddata.osm.pbf
	@echo step 3 of 4 - splitting...
	@./split.sh

output/sorteddata.osm.pbf : $(countries) output/mergeddata.osm.pbf
	@echo step 2 of 4 - sorting...
	osmosis/package/bin/osmosis --read-pbf file=output/mergeddata.osm.pbf --sort --write-pbf file=output/sorteddata.osm.pbf

output/mergeddata.osm.pbf : output
	cp countries.osm.pbf output/mergeddata.osm.pbf

mkgmap:
	svn co http://svn.mkgmap.org.uk/mkgmap/trunk mkgmap

splitter:
	svn co http://svn.mkgmap.org.uk/splitter/trunk splitter

osmosis:
	git clone https://github.com/openstreetmap/osmosis osmosis

osmconvert:
	cc -x c - -lz -O3 -o osmconvert osmconvert.c

osmupdate:
	cc -x c -o osmupdate osmupdate.c

mkgmapbuild: mkgmap always
	cd mkgmap && svn update && ant

splitterbuild: splitter always
	cd splitter && svn update && ant

osmosisbuild: osmosis always
	cd osmosis && git pull && ./gradlew assemble

output :
	mkdir output
	 
always:
