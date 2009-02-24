#!/bin/sh
if [ -e "$HOME/Library/PreferencePanes/SqueezeCenter.prefPane/Contents/server" ] ; then
	cd "$HOME/Library/PreferencePanes/SqueezeCenter.prefPane/Contents/server"
else
	cd "/Library/PreferencePanes/SqueezeCenter.prefPane/Contents/server"
fi

wxPerl cleanup.pl &

for (( i = 0 ; i < 3 ; i++ ))
do
	osascript -e 'tell application "wxPerl.app" to activate'
	sleep 1
done