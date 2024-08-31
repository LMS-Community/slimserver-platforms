#!/bin/bash
SERVER_RUNNING=`ps -axww | grep "slimserver\.pl\|slimserver" | grep -v grep | cat`

PRODUCT_NAME=Squeezebox
LOG_FOLDER="$HOME/Library/Logs/$PRODUCT_NAME"

if [ z"$SERVER_RUNNING" = z ] ; then
	if [ ! -e "$LOG_FOLDER" ] ; then
		mkdir -p "$LOG_FOLDER";
	fi

	if [ z"$USER" != zroot ] ; then
		chown -R $USER "$LOG_FOLDER"
	fi

	BASE_FOLDER=$(cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P)
	cd "$BASE_FOLDER/server"

	"$BASE_FOLDER/bin/perl" slimserver.pl $1 &> /dev/null &
fi
