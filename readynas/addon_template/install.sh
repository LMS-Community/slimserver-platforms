#!/bin/bash

ADDON_HOME=/etc/frontview/addons

bye() {
  . /frontview/bin/functions
  cd /
  rm -rf $orig_dir
  echo -n ": $1 "
  log_status "$1" 1

  exit 1
}

orig_dir=`pwd`
name=`awk -F'!!' '{ print $1 }' addons.conf`
stop=`awk -F'!!' '{ print $5 }' addons.conf`
run=`awk -F'!!' '{ print $4 }' addons.conf`
version=`awk -F'!!' '{ print $3 }' addons.conf`

if grep -q ${name} $ADDON_HOME/addons.conf; then
  orig_vers=`awk -F'!!' '/SQUEEZEBOX/ { print $3 }' $ADDON_HOME/addons.conf | cut -f1 -d'.'`
fi

[ -z "$name" ] && bye "ERROR: No addon name!"

# Remove old versions of our addon
if [ -f "$ADDON_HOME/${name}.remove" ]; then
  sh $ADDON_HOME/${name}.remove -upgrade &>/dev/null
fi

# Extract program files
cd / || bye "ERROR: Could not change working directory."
tar --no-overwrite-dir -xzf $orig_dir/files.tgz || bye "ERROR: Could not extract files properly."

# Add ourself to the main addons.conf file
[ -d $ADDON_HOME ] || mkdir $ADDON_HOME
chown -R admin.admin $ADDON_HOME
grep -v ^$name $ADDON_HOME/addons.conf >/tmp/addons.conf$$ 2>/dev/null
cat $orig_dir/addons.conf >>/tmp/addons.conf$$ || bye "ERROR: Could not include addon configuration."
cp /tmp/addons.conf$$ $ADDON_HOME/addons.conf || bye "ERROR: Could not update addon configuration."
rm -f /tmp/addons.conf$$ || bye "ERROR: Could not clean up."

# Copy our removal script to the default directory
cp $orig_dir/remove.sh $ADDON_HOME/${name}.remove

# Turn ourselves on in the services file
grep -v ^$name /etc/default/services >/tmp/services$$ || bye "ERROR: Could not back up service configuration."
echo "${name}_SUPPORT=1" >>/tmp/services$$ || bye "ERROR: Could not add service configuration."
cp /tmp/services$$ /etc/default/services || bye "ERROR: Could not update service configuration."
rm -f /tmp/services$$ || bye "ERROR: Could not clean up."


###########  Addon specific action go here ###########

# enable LMS by default
grep -v SQUEEZEBOX /etc/default/services > /tmp/services
echo "SQUEEZEBOX=1" >> /tmp/services
cp /tmp/services /etc/default/services
rm -f /tmp/services

# Some ReadyNAS firmware builds mess up the Samba configuration if there are folders in /c/ - let's hide ours
# http://bugs.slimdevices.com/show_bug.cgi?id=17819
if [ ! -e /c/.squeezeboxserver/prefs/server.prefs ]; then
  cp -rf /c/squeezeboxserver/* /c/.squeezeboxserver/ > /dev/null 2>&1
fi

# we can't leave our files on the root partition, it's too small
if [ ! -e /c/.squeezeboxserver/prefs/server.prefs ]; then
  cp -rf /var/lib/squeezeboxserver/* /c/.squeezeboxserver/ > /dev/null 2>&1
  cp -rf /var/log/squeezeboxserver/* /c/.squeezeboxserver/log/ > /dev/null 2>&1
else
	# remove invalid dbsource definition
	grep -v "dbsource.*/c/sq" /c/.squeezeboxserver/prefs/server.prefs > /tmp/server.prefs 2> /dev/null
	cp /tmp/server.prefs /c/.squeezeboxserver/prefs/server.prefs > /dev/null 2>&1
	rm -f /tmp/server.prefs > /dev/null 2>&1
fi

rm -rf /var/lib/squeezeboxserver > /dev/null 2>&1
rm -rf /var/log/squeezeboxserver > /dev/null 2>&1
rm -rf /c/squeezeboxserver > /dev/null 2>&1

# Symlink the new log file to the old location, so the log .zip file picks it up
rm -f /var/log/slimserver.log > /dev/null 2>&1
ln -sf /c/.squeezeboxserver/log/server.log /var/log/slimserver.log  > /dev/null 2>&1

######################################################


eval $run

friendly_name=`awk -F'!!' '{ print $2 }' $orig_dir/addons.conf`

# Remove the installation files
cd /
rm -rf $orig_dir

exit 0
