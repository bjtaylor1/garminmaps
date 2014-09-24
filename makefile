countries=great-britain-latest.osm.pbf france-latest.osm.pbf
#countries=monaco-latest.osm.pbf liechtenstein-latest.osm.pbf
osmosiscmd=osmosis/package/bin/osmosis
domerge=yes #has to be defined if there is more than one country

dependencies: mkgmapbuild splitterbuild osmosisbuild osmconvert osmupdate

osmosisreadcountries=$(patsubst %.osm.pbf, --read-pbf file=%.osm.pbf, $(countries))

gmapsupp.img : $(countries) output/splitter
	mkdir -p temp && cd temp && \
	java -Xmx2000m -jar ../mkgmap/dist/mkgmap.jar ../output/sorteddata.osm.pbf --gmapsupp --style-file=styles --style=default
	cp temp/gmapsupp.img ./

output/splitter : $(countries) output/sorteddata.osm.pbf
	mkdir -p temp && cd temp && \
	java -Xmx2000m -jar ../splitter/dist/splitter.jar ../output/sorteddata.osm.pbf --output-dir=../output/splitter

output/sorteddata.osm.pbf : $(countries) output/mergeddata.osm.pbf
	$(osmosiscmd) --read-pbf file=output/mergeddata.osm.pbf --sort --write-pbf file=output/sorteddata.osm.pbf

output/mergeddata.osm.pbf : output $(countries)
ifdef domerge
	$(osmosiscmd) $(osmosisreadcountries) --merge --write-pbf output/mergeddata.osm.pbf
else
	cp $(osmosisreadcountries) output/mergeddata.osm.pbf
endif

%.osm.pbf.md5: output always
	curl download.geofabrik.de/europe/$@>$@

%.osm.pbf : %.osm.pbf.md5
	md5sum -c $< || curl download.geofabrik.de/europe/$@>$@

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
	mkdir output
	 
always:
