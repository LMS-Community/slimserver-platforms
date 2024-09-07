#!/bin/bash

# Remove the LaunchAgent item for the server.

PRODUCT_NAME="Lyrion Music Server"
PRODUCT_ID=org.lyrion.lyrionmusicserver
PRODUCT_PLIST="$HOME/Library/LaunchAgents/$PRODUCT_ID.plist"

launchctl unload $PRODUCT_PLIST &> /dev/null

# the old PrefPane would read this value - keep it around for a little longer
defaults write com.slimdevices.slim StartupMenuTag 0

rm -f $PRODUCT_PLIST &> /dev/null

/usr/bin/osascript -e "tell application \"System Events\" to delete login item \"$PRODUCT_NAME\""
