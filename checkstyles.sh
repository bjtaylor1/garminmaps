#!/bin/bash

for D in styles/*; do
	if [ -d "${D}" ]; then
		style=`basename $D`
		java -jar mkgmap/dist/mkgmap.jar --style-file=styles --style=$style --check-styles
		echo ""
	fi
done
