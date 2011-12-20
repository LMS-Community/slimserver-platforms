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
            /var/lib/mysql/slimserver \
            /c/squeezeboxserver \
            /c/.squeezeboxserver"

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
  # Remove old packages first. Their conf dirs are left in place, will deal with that next
  for package in $OLD_PACKAGE_NAMES; do
    if dpkg -s $package > /dev/null 2>&1 ; then
      dpkg -P $package &>/dev/null
    fi
  done

  # Doing an upgrade. Look for old config files. If we find them, copy them, then remove them
  for package in $OLD_PACKAGE_NAMES; do
    if [ -e /var/lib/$package/prefs ]; then 
      mkdir -p /c/.squeezeboxserver/prefs
      mv -n /var/lib/$package/prefs/* /c/.squeezeboxserver/prefs &>/dev/null 
      rm -rf /var/lib/$package
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
