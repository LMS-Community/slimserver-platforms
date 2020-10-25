#!/bin/bash

#Set user and group
umask 0002
PUID=${PUID:-`id -u squeezeboxserver`}
PGID=${PGID:-`id -g squeezeboxserver`}

usermod -o -u "$PUID" squeezeboxserver
groupmod -o -g "$PGID" nogroup

#Add permissions
chown -R squeezeboxserver:nogroup /config /playlist /lms

echo Starting Logitech Media Server on port $HTTP_PORT...
su squeezeboxserver -c 'LMS_STDIO=1 /usr/bin/perl /lms/slimserver.pl --prefsdir /config/prefs --logdir /config/logs --cachedir /config/cache --httpport $HTTP_PORT'
