#!/bin/bash

#Set user and group
umask 0002
PUID=${PUID:-`id -u squeezeboxserver`}
PGID=${PGID:-`id -g squeezeboxserver`}

usermod -o -u "$PUID" squeezeboxserver
groupmod -o -g "$PGID" nogroup

umask 0002

#Add permissions
chown -R squeezeboxserver:nogroup /config /playlist /lms

su squeezeboxserver -c '/usr/bin/perl /lms/slimserver.pl --prefsdir /config/prefs --logdir /config/logs --cachedir /config/cache'