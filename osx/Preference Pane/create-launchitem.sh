#!/bin/sh

# Create the LaunchAgent item for the server.

PRODUCT_NAME=Squeezebox
PRODUCT_PLIST="$HOME/Library/LaunchAgents/$PRODUCT_NAME.plist"
LOG_FILE="$HOME/Library/Logs/$PRODUCT_NAME/server.log"

mkdir -p $HOME/Library/Logs/$PRODUCT_NAME
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
		<string>$PRODUCT_FOLDER/slimserver.pl</string>
		<key>WorkingDirectory</key>
		<string>$PRODUCT_FOLDER</string>
		<key>StandardOutPath</key>
		<string>$LOG_FILE</string>
		<key>StandardErrorPath</key>
		<string>$LOG_FILE</string>
	</dict>
</plist>
!!

launchctl load $PRODUCT_PLIST &> /dev/null
