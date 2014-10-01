#/bin/bash
set -e

echo compiling...
mkdir -p temp
cd temp
java -Xmx4000M -jar ../mkgmap/dist/mkgmap.jar $1 --gmapsupp --style-file=styles --style=default 2>&1 >compile.runlog
cd ..
cp temp/gmapsupp.img ./

