#!/bin/bash

# Remove the LaunchAgent item for the server.

PRODUCT_NAME=Squeezebox
PRODUCT_PLIST="$HOME/Library/LaunchAgents/$PRODUCT_NAME.plist"

launchctl unload $PRODUCT_PLIST &> /dev/null

# the old PrefPane would read this value - keep it around for a little longer
defaults write com.slimdevices.slim StartupMenuTag 0

rm -f $PRODUCT_PLIST &> /dev/null