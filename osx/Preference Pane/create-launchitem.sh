#!/bin/sh

# Create the LaunchAgent item for the server.

PRODUCT_NAME=UEMusicLibrary
PRODUCT_PLIST="$HOME/Library/LaunchAgents/$PRODUCT_NAME.plist"

mkdir -p $HOME/Library/LaunchAgents

if [ -e "$HOME/Library/PreferencePanes/PRODUCT_NAME.prefPane/Contents/server" ] ; then
	PRODUCT_FOLDER="$HOME/Library/PreferencePanes/$PRODUCT_NAME.prefPane/Contents/server"
else
	PRODUCT_FOLDER="/Library/PreferencePanes/$PRODUCT_NAME.prefPane/Contents/server"
fi

launchctl unload $PRODUCT_PLIST &> /dev/null

cat >$HOME/Library/LaunchAgents/$PRODUCT_NAME.plist << !!
<plist version="1.0">
	<dict>
		<key>Label</key>
		<string>$PRODUCT_NAME</string>
		<key>RunAtLoad</key>
		<true />
		<key>Program</key>
		<string>$PRODUCT_FOLDER/ueml.pl</string>
		<key>WorkingDirectory</key>
		<string>$PRODUCT_FOLDER</string>
	</dict>
</plist>
!!

launchctl load $PRODUCT_PLIST &> /dev/null
