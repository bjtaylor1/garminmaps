#!/bin/bash
set -e

curl download.geofabrik.de/europe/$1.osm.pbf>$1.osm.pbf 2>$1.dlprog.runlog
