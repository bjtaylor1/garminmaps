#countries=great-britain-latest.osm.pbf france-latest.osm.pbf
#countries=great-britain-latest.osm.pbf
countries=monaco-latest.osm.pbf liechtenstein-latest.osm.pbf

osmosisreadcountries=$(patsubst %.osm.pbf, --read-pbf file=%.osm.pbf, $(countries))

gmapsupp.img : $(countries) output/splitter
	@echo step 4 of 4 - compiling...
	@java -Xmx4000M -jar mkgmap/dist/mkgmap.jar --gmapsupp --style-file=styles --style=clean output/splitter/*.osm.pbf >compile.runlog 2>&1

dependencies: mkgmapbuild splitterbuild osmosisbuild osmconvert osmupdate

clean : 
	rm -rf temp osmupdate_temp output *.runlog *6324*.img osmmap.img osmmap.tdb

output/splitter : $(countries) output/sorteddata.osm.pbf
	@echo step 3 of 4 - splitting...
	@./split.sh >split.runlog

output/sorteddata.osm.pbf : $(countries) output/mergeddata.osm.pbf
	@echo step 2 of 4 - sorting...
	@osmosis/package/bin/osmosis --read-pbf file=output/mergeddata.osm.pbf --sort --write-pbf file=output/sorteddata.osm.pbf >sort.runlog 2>&1

output/mergeddata.osm.pbf : output $(countries)
ifneq (,$(word 2,$(countries)))
	@echo step 1 of 4 - merging...
	@osmosis/package/bin/osmosis $(osmosisreadcountries) --merge --write-pbf output/mergeddata.osm.pbf >merge.runlog 2>&1
else
	@echo step 1 of 4 - merging (only one country so no need to merge - copying country straight to output)
	@cp $(osmosisreadcountries) output/mergeddata.osm.pbf
endif

%.osm.pbf.md5: output always
	@echo refreshing md5 for $*...
	@curl download.geofabrik.de/europe/$@>$@ 2>downloadmd5-$*.runlog

%.osm.pbf : %.osm.pbf.md5
	@md5sum -c $<  || ./refreshsourcedata.sh $*

mkgmap:
	svn co http://svn.mkgmap.org.uk/mkgmap/trunk mkgmap>downloadmkgmap.log

splitter:
	svn co http://svn.mkgmap.org.uk/splitter/trunk splitter>downloadsplitter.log

osmosis:
	git clone https://github.com/openstreetmap/osmosis osmosis

osmconvert:
	wget -O - http://m.m.i24.cc/osmconvert.c | cc -x c - -lz -O3 -o osmconvert

osmupdate:
	wget -O - http://m.m.i24.cc/osmupdate.c | cc -x c - -o osmupdate

mkgmapbuild: mkgmap always
	cd mkgmap && svn update && ant

splitterbuild: splitter always
	cd splitter && svn update && ant

osmosisbuild: osmosis always
	cd osmosis && git pull && ./gradlew assemble

output :
	@mkdir output
	 
always:
