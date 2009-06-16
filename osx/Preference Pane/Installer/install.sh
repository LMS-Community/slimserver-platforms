#!/bin/sh

SERVER_RUNNING=`ps -ax | grep "slimserver\.pl\|slimserver\|squeezecenter\.pl" | grep -v grep | cat`
PREFPANE_FROM="$1/Squeezebox Server.prefPane"
PREFPANE_TO="/Library/PreferencePanes/Squeezebox Server.prefPane"

# Check for OSX 10.5 or later, and strip quarantine information if so
DITTOARGS=""
if [ `sw_vers -productVersion | grep -o "^10\.[5678]"` ] ; then
	DITTOARGS="--noqtn"
fi


if [ z"$SERVER_RUNNING" != z ] ; then
	echo "Please stop the  before running the installer."
	exit 1
fi

SERVER_RUNNING=`ps -ax | grep "System Preferences" | grep -v grep | cat`
if [ z"$SERVER_RUNNING" != z ] ; then
	echo "Please quit System Preferences before running the installer."
	exit 1
fi

for NAME in "SLIMP3 Server" "Slim Server" SqueezeCenter SlimServer "Squeezebox Server"; do

	if [ -e "$HOME/Library/PreferencePanes/$NAME.prefPane" ]; then
		rm -r "$HOME/Library/PreferencePanes/$NAME.prefPane" 2>&1
	fi
	
	if [ -e "/Library/PreferencePanes/$NAME.prefPane" ]; then
		rm -r "/Library/PreferencePanes/$NAME.prefPane" 2>&1
	fi

done


# try to migrate existing settings
if [ ! -e ~/Library/Application\ Support/Squeezebox\ Server ]; then

	if [ -e ~/Library/Application\ Support/SqueezeCenter ] ; then
		ditto $DITTOARGS ~/Library/Application\ Support/SqueezeCenter ~/Library/Application\ Support/Squeezebox\ Server
		grep -v "/SqueezeCenter" ~/Library/Application\ Support/SqueezeCenter/server.prefs > ~/Library/Application\ Support/Squeezebox\ Server/server.prefs
	elif [ -e /Library/Application\ Support/SqueezeCenter ] ; then
		ditto $DITTOARGS /Library/Application\ Support/SqueezeCenter ~/Library/Application\ Support/Squeezebox\ Server
		grep -v "/SqueezeCenter" /Library/Application\ Support/SqueezeCenter/server.prefs > /Library/Application\ Support/Squeezebox\ Server/server.prefs
	fi

fi

# delete some of the bulkier cache files/folders
for MAIN in "$HOME/" "/"; do
	
	for NAME in Artwork FileCache icons MySQL DownloadedPlugins InstalledPlugins iTunesArtwork templates; do
		if [ -e $MAIN/Library/Caches/SqueezeCenter/$NAME ] ; then
			rm -r $MAIN/Library/Caches/SqueezeCenter/$NAME
		fi
	done

	if [ -e $MAIN/Library/Caches/SqueezeCenter/updates/ ] ; then
		rm $MAIN/Library/Caches/SqueezeCenter/updates/*.bin
		rm $MAIN/Library/Caches/SqueezeCenter/updates/*.version
	fi

done


# remove the version file triggering the update prompt
if [ -e ~/Library/Caches/Squeezebox\ Server/updates/server.version ] ; then
	rm -f ~/Library/Caches/Squeeze\ Server/updates/server.version
fi

if [ -e /Library/Caches/Squeeze\ Server/updates/server.version ] ; then
	rm -f /Library/Caches/Squeeze\ Server/updates/server.version
fi


ditto $DITTOARGS "$PREFPANE_FROM" "$PREFPANE_TO"

if [ -e "$PREFPANE_TO" ] ; then
	cd "$PREFPANE_TO/Contents/server"

	# install SC to start at boot time if it hasn't been configured yet
	if [ ! -e ~/Library/Preferences/com.slimdevices.slim.plist ] ; then
		../Resources/create-startup.sh
	fi

	sudo -b -H -u $USER "../Resources/start-server.sh"

	echo "Installed successfully."
	exit 0
else
	echo "Install failed."
	exit 1
fi
