#/bin/bash
set -e

mkdir -p temp && cd temp && \
		java -Xmx4000M -jar ../splitter/dist/splitter.jar ../output/sorteddata.osm.pbf --output-dir=../output/splitter 2>&1 >split.runlog
rm -rf output/sorteddata.osm.pbf
