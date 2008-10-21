#!/bin/sh

SERVER_RUNNING=`ps -ax | grep "slimserver\.pl\|slimserver\|squeezecenter\.pl" | grep -v grep | cat`

if [ z"$SERVER_RUNNING" != z ] ; then
    echo "Please stop the SqueezeCenter before running the installer."
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

if [ -e /Library/PreferencePanes/SqueezeCenter.prefPane ] ; then
    rm -r /Library/PreferencePanes/SqueezeCenter.prefPane 2>&1
fi

if [ -e ~/Library/PreferencePanes/SqueezeCenter.prefPane ] ; then
    rm -r ~/Library/PreferencePanes/SqueezeCenter.prefPane 2>&1
fi

if [ -e /Library/PreferencePanes/SlimServer.prefPane ] ; then
    rm -r /Library/PreferencePanes/SlimServer.prefPane 2>&1
fi

if [ -e ~/Library/PreferencePanes/SlimServer.prefPane ] ; then
    rm -r ~/Library/PreferencePanes/SlimServer.prefPane 2>&1
fi

ditto "$1" "$2"

if [ -e "$2" ] ; then
	cd "$2/Contents/server"
	sudo -H -u \$USER "../Resources/start-server.sh"

    echo "SqueezeCenter installed successfully."
    exit 0
else
    echo "SqueezeCenter install failed."
    exit 1
fi
