#!/bin/sh
SERVER_RUNNING=`ps -axww | grep "squeezecenter\.pl|slimp3\.pl\|slimp3d\|slimserver\.pl\|slimserver" | grep -v grep | cat`
if [ z"$SERVER_RUNNING" = z ] ; then

	if [ -e "$HOME/Library/PreferencePanes/Squeezebox.prefPane/Contents/server" ] ; then
		cd "$HOME/Library/PreferencePanes/Squeezebox.prefPane/Contents/server"
	else
		cd "/Library/PreferencePanes/Squeezebox.prefPane/Contents/server"
	fi

	perl cleanup.pl $1 $2 $3 $4 $5 $6 $7
fi
