#! /bin/sh
SERVER_RUNNING=`ps -axww | grep "slimp3\.pl\|slimp3d\|slimserver\.pl\|slimd" | grep -v grep | cat`
if [ z"$SERVER_RUNNING" != z ] ; then
	kill `echo $SERVER_RUNNING | sed -n 's/^[ ]*\([0-9]*\)[ ]*.*$/\1/p'`
fi