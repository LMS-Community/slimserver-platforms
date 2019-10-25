#!/bin/bash

PREFS_DIR="/Library/Application Support/Squeezebox"
HTTP_PORT=

for DIR in "$HOME$PREFS_DIR" "$PREFS_DIR"
do
	PREFS_FILE="$DIR/server.prefs"
	if [ -f "$PREFS_FILE" ]; then
		HTTP_PORT=`grep -Ei '^httpport: (\d+)' "$PREFS_FILE" | grep -oEi '\d+'`
	fi
	
	if [ "$HTTP_PORT" != "" ]; then
		break
	fi
done

check_port() {
	eval "nc -nz 127.0.0.1 $HTTP_PORT 2>/dev/null"
}

if ! check_port; then
	printf "0\n"
else
	printf "$HTTP_PORT\n"
fi