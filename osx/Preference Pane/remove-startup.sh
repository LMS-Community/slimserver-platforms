#!/bin/sh

rm -r /Library/StartupItems/UEMusicLibrary
rm /tmp/uemlerror.log

# Remove the LaunchDaemon item for the server.

PRODUCT_NAME=UEMusicLibrary
PRODUCT_PLIST="/Library/LaunchDaemons/$PRODUCT_NAME.plist"

launchctl unload $PRODUCT_PLIST &> /dev/null

rm -f $PRODUCT_PLIST &> /dev/null
