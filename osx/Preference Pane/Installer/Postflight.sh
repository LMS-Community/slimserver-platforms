#!/bin/sh

if [ -e "$HOME/Library/PreferencePanes/Squeezebox.prefPane/Contents/server/Bin/darwin" ] ; then
	cd "$HOME/Library/PreferencePanes/Squeezebox.prefPane/Contents/server/Bin/darwin"
else
	cd "/Library/PreferencePanes/Squeezebox.prefPane/Contents/server/Bin/darwin"
fi

osascript openprefs.scpt &
