#!/bin/sh

# this script is being called from the PrefPane to launch the installer

if [ -e $1 ] ; then
	xattr -d com.apple.quarantine $1 &> /dev/null

	open $1
fi
	
