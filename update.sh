#!/bin/bash
set -e

echo "  running osmupdate"
./osmupdate $1.osm.pbf $1.updated.osm --day --verbose 1
echo "  converting $1 to binary format"
./osmconvert $1.updated.osm --out-pbf>$1.osm.pbf
rm $1.updated.osm

