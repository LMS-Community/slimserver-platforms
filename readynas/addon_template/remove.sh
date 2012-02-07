#!/bin/bash

SERVICE=SQUEEZEBOX
CONF_FILES="/etc/squeezeboxserver \
            /c/.squeezeboxserver"
            
PROG_FILES="/etc/frontview/apache/addons/SQUEEZEBOX.conf* \
            /etc/frontview/addons/*/SQUEEZEBOX \
            /usr/share/squeezeboxserver \
            /usr/share/perl5/Slim \
            /usr/share/doc/squeezeboxserver \
            /etc/default/squeezeboxserver \
            /etc/init.d/squeezeboxserver \
            /usr/sbin/squeezeboxserver*"

# Stop service from running
eval `awk -F'!!' "/^${SERVICE}\!\!/ { print \\$5 }" /etc/frontview/addons/addons.conf`

# Remove program files
if ! [ "$1" = "-upgrade" ]; then
  if [ "$CONF_FILES" != "" ]; then
    for i in $CONF_FILES; do
      rm -rf $i &>/dev/null
    done
  fi
fi

if [ "$PROG_FILES" != "" ]; then
  for i in $PROG_FILES; do
    rm -rf $i
  done
fi

# Remove entries from services file
sed -i "/^${SERVICE}_SUPPORT=/d" /etc/default/services

# Remove entry from addons.conf file
sed -i "/^${SERVICE}\!\!/d" /etc/frontview/addons/addons.conf

# Reread modified service configuration files
#(/usr/sbin/apache-ssl -f /etc/frontview/apache/httpd.conf -t > /dev/null 2>&1) && (/usr/sbin/apache-ssl -f /etc/frontview/apache/httpd.conf -k graceful > /dev/null 2>&1)

# Now remove ourself
rm -f $0

exit 0
