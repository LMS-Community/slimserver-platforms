#!/bin/bash

# Create the LaunchDaemon item for the server.

PRODUCT_NAME=Squeezebox
PRODUCT_PLIST="/Library/LaunchDaemons/$PRODUCT_NAME.plist"
LOG_FOLDER="$HOME/Library/Logs/$PRODUCT_NAME"
LOG_FILE="$LOG_FOLDER/server.log"

mkdir -p $LOG_FOLDER
mkdir -p /Library/LaunchDaemons

if [ -e "$HOME/Library/PreferencePanes/PRODUCT_NAME.prefPane/Contents/server" ] ; then
	PRODUCT_FOLDER="$HOME/Library/PreferencePanes/$PRODUCT_NAME.prefPane/Contents/server"
else
	PRODUCT_FOLDER="/Library/PreferencePanes/$PRODUCT_NAME.prefPane/Contents/server"
fi

launchctl unload $PRODUCT_PLIST &> /dev/null

# on Apple Silicon based systems (macOS 11+) we need to enforce use of Rosetta
OS_MAJOR_VERSION=`sw_vers -productVersion | cut -d'.' -f1`
if [ $OS_MAJOR_VERSION -ge 11 ]; then
	SETARCH="<string>arch</string><string>-x86_64</string>"
fi

cat >/Library/LaunchDaemons/$PRODUCT_NAME.plist << !!
<plist version="1.0">
	<dict>
		<key>Label</key>
		<string>$PRODUCT_NAME</string>
		<key>RunAtLoad</key>
		<true />
		<key>ProgramArguments</key>
		<array>
			$SETARCH
			<string>$PRODUCT_FOLDER/slimserver.pl</string>
		</array>
		<key>WorkingDirectory</key>
		<string>$PRODUCT_FOLDER</string>
		<key>StandardOutPath</key>
		<string>$LOG_FILE</string>
		<key>StandardErrorPath</key>
		<string>$LOG_FILE</string>
		<key>UserName</key>
		<string>$USER</string>
    	</dict>
</plist>
!!

launchctl load $PRODUCT_PLIST &> /dev/null

if [ z"$USER" != zroot ] ; then
	chown -R $USER $LOG_FOLDER
fi
