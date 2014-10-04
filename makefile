countries=great-britain-latest.osm.pbf france-latest.osm.pbf
#countries=great-britain-latest.osm.pbf
#countries=monaco-latest.osm.pbf liechtenstein-latest.osm.pbf
osmosiscmd=osmosis/package/bin/osmosis
mem=-Xmx8000M
dependencies: mkgmapbuild splitterbuild osmosisbuild osmconvert osmupdate

osmosisreadcountries=$(patsubst %.osm.pbf, --read-pbf file=%.osm.pbf, $(countries))

clean : 
	rm -rf temp osmupdate_temp output

gmapsupp.img : $(countries) output/splitter
	./compile.sh output/splitter/*.osm.pbf 2>&1 >compile.runlog

output/splitter : $(countries) output/sorteddata.osm.pbf
	./split.sh

output/sorteddata.osm.pbf : $(countries) output/mergeddata.osm.pbf
	@echo sorting...
	@$(osmosiscmd) --read-pbf file=output/mergeddata.osm.pbf --sort --write-pbf file=output/sorteddata.osm.pbf>sort.runlog
	@rm -rf output/mergeddata.osm.pbf

output/mergeddata.osm.pbf : output $(countries)
ifneq (,$(word 2,$(countries)))
	@echo merging...
	@$(osmosiscmd) $(osmosisreadcountries) --merge --write-pbf output/mergeddata.osm.pbf
else
	@echo no need to merge - copying country to output
	@cp $(osmosisreadcountries) output/mergeddata.osm.pbf
endif

%.osm.pbf.md5: output always
	@echo refreshing md5 for $*...
	@curl download.geofabrik.de/europe/$@>$@ 2>downloadmd5-$*.runlog

%.osm.pbf : %.osm.pbf.md5
	@md5sum -c $<  || \
		(test `find $@ -mtime -30` && \
			(echo updating $@ && ./osmupdate $@ $*.updated.osm && echo converting && ./osmconvert $*.updated.osm --out-pbf>$@ && rm $*.updated.osm) || \
			(echo redownloading $@ && curl download.geofabrik.de/europe/$@>$@) )

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
