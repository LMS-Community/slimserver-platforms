#!/bin/sh
SERVER_RUNNING=`ps -axww | grep "ueml\.pl" | grep -v grep | cat`
if [ z"$SERVER_RUNNING" = z ] ; then
	cd "/Library/PreferencePanes/UEMusicLibrary.prefPane/Contents/server"

	perl cleanup.pl $1 $2 $3 $4 $5 $6 $7
fi
