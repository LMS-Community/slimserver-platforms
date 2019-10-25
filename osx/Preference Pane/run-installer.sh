#!/bin/bash

# this script is being called from the PrefPane to launch the installer

syslog -s -k Facility com.apple.console \
             Level Error \
             Sender "Logitech Media Server installer" \
             Message "Launching: $1"

if [ -e $1 ] ; then
	xattr -d com.apple.quarantine $1 &> /dev/null

	open $1
else
	syslog -s -k Facility com.apple.console \
	             Level Error \
	             Sender "Logitech Media Server installer" \
	             Message "Didn't find $1"
fi
	
