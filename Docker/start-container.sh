#!/bin/bash

#Set user and group
umask 0002
PUID=${PUID:-`id -u squeezeboxserver`}
PGID=${PGID:-`id -g squeezeboxserver`}

usermod -o -u "$PUID" squeezeboxserver
groupmod -o -g "$PGID" nogroup

#Add permissions
chown -R squeezeboxserver:nogroup /config /playlist

if [[ -f /config/custom-init.sh ]]; then
	echo "Running custom initialization script..."
	sh /config/custom-init.sh
fi

echo Starting Lyrion Music Server on port $HTTP_PORT...
if [[ -n "$EXTRA_ARGS" ]]; then
	echo "Using additional arguments: $EXTRA_ARGS"
fi
su squeezeboxserver -c '/usr/bin/perl /lms/slimserver.pl --prefsdir /config/prefs --logdir /config/logs --cachedir /config/cache --httpport $HTTP_PORT $EXTRA_ARGS'
