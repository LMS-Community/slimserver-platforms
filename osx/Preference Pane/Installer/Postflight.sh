#!/bin/sh

# Under Panther, it takes a while for LaunchServices to prep the prefPane for
# startup. So, we take a new approach to starting it. Basically, we manually
# start System Preferences, and then ask it to load it.

# 10.1 doesn't have a scriptable system preferences application, so we ask
# it by starting it manually, and then using open. Later versions allow
# a direct request.

if /usr/bin/sw_vers | grep "10.1" >/dev/null; then
	osascript <<ENDSCRIPT
		tell application "System Preferences" to activate
ENDSCRIPT
	open $1
else
	osascript <<ENDSCRIPT
	tell application "System Preferences"
		set current pane to pane "com.slimdevices.slim"
		activate
	end tell
ENDSCRIPT
fi
