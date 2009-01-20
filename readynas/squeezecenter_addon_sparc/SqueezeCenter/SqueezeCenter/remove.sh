#!/bin/bash

SERVICE=SLIMSERVER

CONF_FILES="/var/log/squeezecenter \
            /var/lib/squeezecenter \
            /etc/squeezecenter \
            /usr/share/squeezecenter \
            /usr/sbin/squeezecenter* \
	    ./etc/init.d/squeezecenter \
	    ./etc/default/squeezecenter \
	    ./usr/share/perl5/Slim \
            /var/lib/mysql/slimserver"

# Stop service from running
eval `awk -F'!!' "/$SERVICE/ { print \\$5 }" /etc/frontview/addons/addons.conf`

# Remove all files, unless we're upgrading
if ! [ "$1" = "-upgrade" ]; then
  # Remove debian package
  dpkg -P squeezecenter-readynas
  for i in $CONF_FILES; do
    rm -rf $i &>/dev/null
  done
fi

# Remove entry from services file
grep -v $SERVICE /etc/default/services >/tmp/services$$
cp /tmp/services$$ /etc/default/services
rm -f /tmp/services$$

# Remove entry from addons.conf file
grep -v ^$SERVICE /etc/frontview/addons/addons.conf >/tmp/addons.conf$$
cp /tmp/addons.conf$$ /etc/frontview/addons/addons.conf
rm -f /tmp/addons.conf$$

# Now remove ourself
rm -f $0
