#!/bin/sh
SERVER_RUNNING=`ps -ax | grep "slimserver\.pl\|slimp3\.pl\|slimp3d\|slimserver" | grep -v grep | cat`
if [ z"$SERVER_RUNNING" != z ] ; then
    echo "Please stop the SlimServer before running the installer."
    exit 1
fi

SERVER_RUNNING=`ps -ax | grep "System Preferences" | grep -v grep | cat`
if [ z"$SERVER_RUNNING" != z ] ; then
    echo "Please quit System Preferences before running the installer."
    exit 1
fi

if [ -e /Library/PreferencePanes/SLIMP3\ Server.prefPane ] ; then
    rm -r /Library/PreferencePanes/SLIMP3\ Server.prefPane 2>&1
fi

if [ -e ~/Library/PreferencePanes/SLIMP3\ Server.prefPane ] ; then
    rm -r ~/Library/PreferencePanes/SLIMP3\ Server.prefPane 2>&1
fi

if [ -e /Library/PreferencePanes/Slim\ Server.prefPane ] ; then
    rm -r /Library/PreferencePanes/Slim\ Server.prefPane 2>&1
fi

if [ -e ~/Library/PreferencePanes/Slim\ Server.prefPane ] ; then
    rm -r ~/Library/PreferencePanes/Slim\ Server.prefPane 2>&1
fi

if [ -e /Library/PreferencePanes/SlimServer.prefPane ] ; then
    rm -r /Library/PreferencePanes/SlimServer.prefPane 2>&1
fi

if [ -e ~/Library/PreferencePanes/SlimServer.prefPane ] ; then
    rm -r ~/Library/PreferencePanes/SlimServer.prefPane 2>&1
fi

ditto "$1" "$2"

if [ -e "$2" ] ; then
    echo SlimServer installed successfully."
    exit 0
else
    echo "SlimServer install failed."
    exit 1
fi
