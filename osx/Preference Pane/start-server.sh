#!/bin/bash
SERVER_RUNNING=`ps -axww | grep "squeezecenter\.pl|slimp3\.pl\|slimp3d\|slimserver\.pl\|slimserver" | grep -v grep | cat`

PRODUCT_NAME=Squeezebox
LOG_FOLDER="$HOME/Library/Logs/$PRODUCT_NAME"

if [ z"$SERVER_RUNNING" = z ] ; then
	if [ ! -e $LOG_FOLDER ] ; then
		mkdir -p $LOG_FOLDER;
	fi

	if [ z"$USER" != zroot ] ; then
		chown -R $USER $LOG_FOLDER
	fi
    
	cd "`dirname $0`/../server"
	
	# on Apple Silicon based systems (macOS 11+) we need to enforce use of Rosetta
	OS_MAJOR_VERSION=`sw_vers -productVersion | cut -d'.' -f1`
	if [ $OS_MAJOR_VERSION -ge 11 ]; then
		SETARCH="arch -x86_64"
	fi
	
	$SETARCH ./slimserver.pl --daemon $1 &> /dev/null &
fi
