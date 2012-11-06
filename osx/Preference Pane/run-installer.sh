#!/bin/sh

# this script is being called from the PrefPane to launch the installer

UPDATEFOLDER=`dirname $1`
PRODUCT_PREFIX=Squeezebox
INSTALLER="$UPDATEFOLDER/$PRODUCT_PREFIX*.pkg"

# clean up remnants of earlier installations
rm -rf $UPDATEFOLDER/$PRODUCT_PREFIX*.pkg

if [ -e $INSTALLER ] ; then
	xattr -d com.apple.quarantine $INSTALLER &> /dev/null

	open $INSTALLER
fi
	
