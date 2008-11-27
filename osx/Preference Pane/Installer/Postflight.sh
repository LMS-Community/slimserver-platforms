#!/bin/sh

# try to detect SC's web port, and verify whether it's available or not
# don't try more than 15 seconds
# open SC web UI in Safari, if SC is available

if [ -e "$HOME/Library/PreferencePanes/SqueezeCenter.prefPane/Contents/Resources" ] ; then
	cd "$HOME/Library/PreferencePanes/SqueezeCenter.prefPane/Contents/Resources"
else
	cd "/Library/PreferencePanes/SqueezeCenter.prefPane/Contents/Resources"
fi

PORT=`./check-web.pl`
i=0

while [ $PORT -eq 0 ] && [ $i -lt 15 ]
do
	i=`expr $i + 1`
	sleep 1
	
	PORT=`./check-web.pl`	
done

if [ $PORT -ne 0 ]; then
	osascript <<ENDSCRIPT
		open location "http://localhost:$PORT/"
ENDSCRIPT
fi
