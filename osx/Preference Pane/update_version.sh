#! /bin/sh
# update_version.sh <current version> <new version>
find . -type f -name 'objects.nib' -print | while read i
do
	sed "s|$1|$2|g" ${i} > $i.tmp && mv $i.tmp $i
done
find . -type f -name '*.strings' -print | while read i
do
	sed "s|$1|$2|g" ${i} > $i.tmp && mv $i.tmp $i
done