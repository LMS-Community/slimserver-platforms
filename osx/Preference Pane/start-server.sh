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

	./slimserver.pl --daemon $1 &> /dev/null &
fi
