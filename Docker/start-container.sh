#!/bin/bash

#Set user and group
umask 0002
PUID=${PUID:-`id -u squeezeboxserver`}
PGID=${PGID:-`id -g squeezeboxserver`}

usermod -o -u "$PUID" squeezeboxserver
groupmod -o -g "$PGID" squeezeboxserver

umask 0002

#Add permissions
chown -R squeezeboxserver:users /config /playlist

/usr/bin/perl /lms/slimserver.pl --user squeezeboxserver --prefsdir /config/prefs --logdir /config/logs --cachedir /config/cache
