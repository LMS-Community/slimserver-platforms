#!/bin/sh

# Create the LaunchAgent item for the server.

PRODUCT_NAME=UEMusicLibrary
PRODUCT_PLIST="$HOME/Library/LaunchAgents/$PRODUCT_NAME.plist"

launchctl unload $PRODUCT_PLIST &> /dev/null

rm -f $PRODUCT_PLIST &> /dev/null