#!/bin/bash


LATEST_VERSION=latest

VERSION_LIST=(latest 1.0)

cp src/SUMMARY.md src/SUMMARY_backup.md

for VERSION in ${VERSION_LIST[*]}

do
	
	sed  -e "s@$LATEST_VERSION@$VERSION@" src/SUMMARY.md > src/SUMMARY_"$VERSION".md
	
	cat src/SUMMARY_"$VERSION".md > src/SUMMARY.md
	
	mdbook build

	rm -rf src/SUMMARY_"$VERSION".md

	cp src/SUMMARY_backup.md src/SUMMARY.md
	
done

rm -rf src/SUMMARY_backup.md
