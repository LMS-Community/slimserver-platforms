#!/bin/sh
SERVER_RUNNING=`ps -axww | grep "slimp3\.pl\|slimp3d\|slimserver\.pl\|slimserver" | grep -v grep | cat`
if [ z"$SERVER_RUNNING" != z ] ; then
	kill `echo $SERVER_RUNNING | sed -n 's/^[ ]*\([0-9]*\)[ ]*.*$/\1/p'`
fi

# Wait for it to stop

for (( i = 0 ; i < 10 ; i++ ))
do
    SERVER_RUNNING=`ps -axww | grep "slimp3\.pl\|slimp3d|slimserver\.pl\|slimserver" | grep -v grep | cat`
    if [ z"$SERVER_RUNNING" == z ] ; then
	break
    fi
    sleep 1
done

# If it didn't quit, fail
SERVER_RUNNING=`ps -axww | grep "slimp3\.pl\|slimp3d\|slimserver\.pl\|slimserver" | grep -v grep | cat`
if [ z"$SERVER_RUNNING" != z ] ; then
    exit 1
fi


SERVER_RUNNING=`ps -axww | grep "System Preferences" | grep -v grep | cat`
if [ z"$SERVER_RUNNING" != z ] ; then
    osascript -e "tell application \"System Preferences\" to quit"
fi
exit 0