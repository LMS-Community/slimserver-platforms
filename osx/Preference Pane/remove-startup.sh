#!/bin/sh

rm -r /Library/StartupItems/Slim
rm -r /Library/StartupItems/SqueezeCenter
rm -r /Library/StartupItems/Squeezebox
rm /tmp/slimerror.log
rm /tmp/squeezecentererror.log
rm /tmp/squeezeboxerror.log

# Remove the LaunchDaemon item for the server.

PRODUCT_NAME=Squeezebox
PRODUCT_PLIST="/Library/LaunchDaemons/$PRODUCT_NAME.plist"

launchctl unload $PRODUCT_PLIST &> /dev/null

rm -f $PRODUCT_PLIST &> /dev/null