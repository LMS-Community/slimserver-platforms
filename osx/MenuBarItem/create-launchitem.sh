#!/bin/bash

# Create the LaunchAgent item for the server.

PRODUCT_NAME=Squeezebox
PRODUCT_PLIST="$HOME/Library/LaunchAgents/$PRODUCT_NAME.plist"
LOG_FOLDER="$HOME/Library/Logs/$PRODUCT_NAME"
LOG_FILE="$LOG_FOLDER/server.log"

mkdir -p $LOG_FOLDER
mkdir -p $HOME/Library/LaunchAgents

PRODUCT_FOLDER="$PWD/server"

launchctl unload $PRODUCT_PLIST &> /dev/null

cat >$HOME/Library/LaunchAgents/$PRODUCT_NAME.plist << !!
<plist version="1.0">
	<dict>
		<key>Label</key>
		<string>$PRODUCT_NAME</string>
		<key>RunAtLoad</key>
		<true />
		<key>ProgramArguments</key>
		<array>
			<string>$PRODUCT_FOLDER/slimserver.pl</string>
		</array>
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

# the old PrefPane would read this value - keep it around for a little longer
defaults write com.slimdevices.slim StartupMenuTag 1

if [ z"$USER" != zroot ] ; then
	chown -R $USER $LOG_FOLDER
fi