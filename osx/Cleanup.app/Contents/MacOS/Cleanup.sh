#!/bin/sh
if [ -e "$HOME/Library/PreferencePanes/SqueezeCenter.prefPane/Contents/server" ] ; then
	cd "$HOME/Library/PreferencePanes/SqueezeCenter.prefPane/Contents/server"
else
	cd "/Library/PreferencePanes/SqueezeCenter.prefPane/Contents/server"
fi

wxPerl cleanup.pl &
osascript -e 'tell application "wxPerl.app" to activate'