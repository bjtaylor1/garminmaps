#!/bin/bash

java -jar mkgmap/dist/mkgmap.jar --style-file=styles --style=default --check-styles
java -jar mkgmap/dist/mkgmap.jar --style-file=styles --style=clean --check-styles
