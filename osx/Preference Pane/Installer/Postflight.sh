#!/bin/sh

/usr/bin/osascript <<EOF
	tell application "System Preferences"

		set current pane to pane id "com.slimdevices.slim"

		activate

	end tell
EOF