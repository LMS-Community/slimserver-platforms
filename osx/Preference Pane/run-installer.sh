#!/bin/sh

# this script is being called from the PrefPane to launch the installer

UPDATEFOLDER=`dirname $1`
PRODUCT_PREFIX=Squeezebox
INSTALLER="$UPDATEFOLDER/$PRODUCT_PREFIX*.pkg"

# clean up remnants of earlier installations
rm -rf $UPDATEFOLDER/$PRODUCT_PREFIX*.pkg

if [ -e "$1" ] ; then
#	unzip -oq $1 -d $UPDATEFOLDER

	xattr -d com.apple.quarantine $INSTALLER &> /dev/null
fi

if [ -e $INSTALLER ] ; then
	open $INSTALLER
fi
	
