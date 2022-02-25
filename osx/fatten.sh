#!/bin/bash

# Little helper script to find all bundles to make them universal
# * find all bundles in x86_64/ folder
# * if file of same path/name exists in arm64/, glue them together
# * store resulting binaries in fat/ sub-folder

for lib in $(find x86_64/lib -name "*bundle"); do
	lib=`echo $lib | cut -d'/' -f2-`

	if [ -f "x86_64/$lib" -a -f "arm64/$lib" ]; then
		fatlib=`dirname fat/$lib`
		mkdir -p $fatlib
		lipo -create "x86_64/$lib" "arm64/$lib" -output "fat/$lib"
	fi
done

