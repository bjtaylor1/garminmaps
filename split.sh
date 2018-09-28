#/bin/bash
set -e
set -x

mkdir -p temp
cd temp
java -Xmx4000M -jar ../splitter/dist/splitter.jar ../output/sorteddata.osm.pbf --output-dir=../output/splitter 2>&1
