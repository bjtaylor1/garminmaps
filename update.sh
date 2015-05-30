#!/bin/bash
set -e

echo "  running osmupdate"
./osmupdate $1.osm.pbf $1.updated.osm.pbf --day --verbose 1
mv $1.updated.osm.pbf $1.osm.pbf
