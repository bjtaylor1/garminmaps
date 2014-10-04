#/bin/bash
set -e

echo compiling...
java -Xmx4000M -jar mkgmap/dist/mkgmap.jar --gmapsupp --style-file=styles --style=default $1

