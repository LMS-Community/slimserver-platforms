#!/bin/sh

SERVER_RUNNING=`ps -ax | grep "slimserver\.pl\|slimserver\|squeezecenter\.pl" | grep -v grep | cat`
PREFPANE_FROM="$1/Squeezebox.prefPane"
PREFPANE_TO="/Library/PreferencePanes/Squeezebox.prefPane"

# Check for OSX 10.5 or later, and strip quarantine information if so
DITTOARGS=""
if [ `sw_vers -productVersion | grep -o "^10\.[5678]"` ] ; then
	DITTOARGS="--noqtn"
fi


if [ z"$SERVER_RUNNING" != z ] ; then
	echo "Please stop the server before running the installer."
	exit 1
fi

SERVER_RUNNING=`ps -ax | grep "System Preferences" | grep -v grep | cat`
if [ z"$SERVER_RUNNING" != z ] ; then
	echo "Please quit System Preferences before running the installer."
	exit 1
fi

for NAME in "SLIMP3 Server" "Slim Server" SqueezeCenter SlimServer "Squeezebox Server" Squeezebox; do

	if [ -e "$HOME/Library/PreferencePanes/$NAME.prefPane" ]; then
		rm -r "$HOME/Library/PreferencePanes/$NAME.prefPane" 2>&1
	fi
	
	if [ -e "/Library/PreferencePanes/$NAME.prefPane" ]; then
		rm -r "/Library/PreferencePanes/$NAME.prefPane" 2>&1
	fi

done


# try to migrate existing settings
if [ ! -e ~/Library/Application\ Support/Squeezebox ]; then

	if [ -e ~/Library/Application\ Support/SqueezeCenter ] ; then
		ditto $DITTOARGS ~/Library/Application\ Support/SqueezeCenter ~/Library/Application\ Support/Squeezebox
		grep -v "/SqueezeCenter" ~/Library/Application\ Support/SqueezeCenter/server.prefs > ~/Library/Application\ Support/Squeezebox/server.prefs
	elif [ -e /Library/Application\ Support/SqueezeCenter ] ; then
		ditto $DITTOARGS /Library/Application\ Support/SqueezeCenter ~/Library/Application\ Support/Squeezebox
		grep -v "/SqueezeCenter" /Library/Application\ Support/SqueezeCenter/server.prefs > /Library/Application\ Support/Squeezebox/server.prefs
	elif [ -e ~/Library/Application\ Support/Squeezebox\ Server ] ; then
		ditto $DITTOARGS /Library/Application\ Support/Squeezebox\ Server ~/Library/Application\ Support/Squeezebox
		grep -v "/Squeezebox\ Server" /Library/Application\ Support/Squeezebox\ Server/server.prefs > /Library/Application\ Support/Squeezebox/server.prefs
	elif [ -e /Library/Application\ Support/Squeezebox\ Server ] ; then
		ditto $DITTOARGS /Library/Application\ Support/Squeezebox\ Server ~/Library/Application\ Support/Squeezebox
		grep -v "/Squeezebox\ Server" /Library/Application\ Support/Squeezebox\ Server/server.prefs > /Library/Application\ Support/Squeezebox/server.prefs
	fi

fi

# delete some of the bulkier legacy cache files/folders
for MAIN in "$HOME/" "/"; do
	
	for NAME in Artwork FileCache icons MySQL DownloadedPlugins InstalledPlugins iTunesArtwork templates; do

		if [ -e $MAIN/Library/Caches/SqueezeCenter/$NAME ] ; then
			rm -r $MAIN/Library/Caches/SqueezeCenter/$NAME
		fi

		if [ -e $MAIN/Library/Caches/Squeezebox\ Server/$NAME ] ; then
			rm -r $MAIN/Library/Caches/Squeezebox\ Server/$NAME
		fi

	done

	for NAME in "Squeezebox Server" SqueezeCenter Squeezebox; do

		if [ -e "$MAIN/Library/Caches/$NAME/updates/" ] ; then
			rm "$MAIN/Library/Caches/$NAME/updates/*.bin"
			rm "$MAIN/Library/Caches/$NAME/updates/*.version"
		fi
		
	done

done


# remove the version file triggering the update prompt
if [ -e ~/Library/Caches/Squeezebox/updates/server.version ] ; then
	rm -f ~/Library/Caches/Squeezebox/updates/server.version
fi

if [ -e /Library/Caches/Squeezebox/updates/server.version ] ; then
	rm -f /Library/Caches/Squeezebox/updates/server.version
fi


ditto $DITTOARGS "$PREFPANE_FROM" "$PREFPANE_TO"

if [ -e "$PREFPANE_TO" ] ; then
	cd "$PREFPANE_TO/Contents/server"

	# install SC to start at boot time if it hasn't been configured yet; update startupitem if we're updating
	if [ ! -e ~/Library/Preferences/com.slimdevices.slim.plist ] || [ -e /Library/StartupItems/SqueezeCenter ] || [ -e /Library/StartupItems/Squeezebox\ Server ] ; then
		../Resources/create-startup.sh
	fi

	sudo -b -H -u $USER "../Resources/start-server.sh"

	# if we're on OSX 10.3 we'll use an old version of the prefpane...	
	if [ `sw_vers -productVersion | grep "^10\.3"` ] ; then
		cd "$PREFPANE_TO/Contents/"
		rm -rf Resources/*lproj
		rm -f MacOS/Squeezebox
		cp -r 10.3/* .
	fi

	echo "Logitech Media Server installed successfully."
	exit 0
else
	echo "Logitech Media Server install failed."
	exit 1
fi
