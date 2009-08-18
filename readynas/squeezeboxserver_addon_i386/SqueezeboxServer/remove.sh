#!/bin/bash

SERVICE=SLIMSERVER
PACKAGENAME=squeezeboxserver
OLD_PACKAGE_NAMES="slimserver \
	      squeezecenter \
	      squeezeboxserver-readynas"
DIRECTORIES="/var/log/squeezeboxserver \
            /var/lib/squeezeboxserver \
            /etc/squeezeboxserver \
            /usr/share/squeezeboxserver \
            /usr/sbin/squeezeboxserver* \
	    ./etc/init.d/squeezeboxserver \
	    ./etc/default/squeezeboxserver \
	    ./usr/share/perl5/Slim \
            /var/lib/mysql/slimserver"

# Stop service from running
eval `awk -F'!!' "/$SERVICE/ { print \\$5 }" /etc/frontview/addons/addons.conf`

# Remove all files, unless we're upgrading
if ! [ "$1" = "-upgrade" ]; then
  # Remove debian package
  dpkg -P $PACKAGENAME &>/dev/null

  # Remove old packages as well
  for package in $OLD_PACKAGE_NAMES; do
    if dpkg -s $package > /dev/null 2>&1 ; then
      dpkg -P $package &>/dev/null
    fi
  done

  # Forcefully remove any directories where we would have put files
  for i in $DIRECTORIES; do
    rm -rf $i &>/dev/null
  done
else
  # Doing an upgrade. Look for old config files
  for package in $OLD_PACKAGE_NAMES; do
    if [ -e /var/lib/$package/prefs ]; then 
      mkdir -p /var/lib/squeezeboxserver/prefs
      mv -n /var/lib/$package/prefs/* /var/lib/squeezeboxserver/prefs &>/dev/null 
      rm -rf /var/lib/$package/prefs
    fi
  done
 
  # Now remove all the old packages before install the new one
  for package in $OLD_PACKAGE_NAMES; do
    if dpkg -s $package > /dev/null 2>&1 ; then
      dpkg -P $package &>/dev/null
    fi
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
