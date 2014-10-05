#!/bin/bash
set -e

test `find $1.osm.pbf -mtime -30 -size +10M 2>/dev/null` && \
	( echo "$1 exists and is worth patching (less than 30 days old and over 10MB)  - updating"  && ./update.sh $1 ) ||
  ( echo "$1 doesn't exist, is under 10MB or is older than 30 days - redownloading" && ./redownload.sh $1 )
