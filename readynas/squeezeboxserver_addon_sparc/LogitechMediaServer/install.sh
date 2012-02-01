#!/bin/bash

bye() {
  . /frontview/bin/functions
  cd /
  rm -rf $orig_dir
  echo -n "$1 "

  rm -f /.update_success
  rm -f /var/spool/frontview/boot/*_UpdateStatus
  send_email_alert "Addon Package Progress" "$1"
  log_status "$1" 1

  exit
}

orig_dir=`pwd`
name=`awk -F'!!' '{ print $1 }' addons.conf`
stop=`awk -F'!!' '{ print $5 }' addons.conf`
run=`awk -F'!!' '{ print $4 }' addons.conf`
friendly_name=`awk -F'!!' '{ print $2 " " $3 }' addons.conf`

[ -z "$name" ] && bye "ERROR: No addon name!"

MAJOR=$((`sed -e 's/.*version=//' -e 's/\..*//' /etc/raidiator_version`))
MINOR=$((`sed -e 's/.*version=//' -e 's/.*\.//' -e 's/[a-z,-].*//' /etc/raidiator_version`))

VERS=$(printf "%04d%04d" $MAJOR $MINOR)
[ $VERS -lt 40001 ] && bye "ERROR: Addon is not compatible with this RAIDiator version!"

eval $stop && sleep 1

# Kill the squeezebox DB - we're now using SQLite
mysql -s -uslimserver -e 'DROP DATABASE slimserver'

# Remove old versions of our addon
if [ -f "/etc/frontview/addons/${name}.remove" ]; then
  sh /etc/frontview/addons/${name}.remove -upgrade &>/dev/null
fi

# Extract program files
tar xfz $orig_dir/files.tgz || bye "ERROR: Could not extract addon files!"

# Add ourself to the main addons.conf file
[ -d /etc/frontview/addons ] || mkdir /etc/frontview/addons
chown -R admin.admin /etc/frontview/addons
grep -v ^$name /etc/frontview/addons/addons.conf >/tmp/addons.conf$$ 2>/dev/null
cat $orig_dir/addons.conf >>/tmp/addons.conf$$ || bye "ERROR: Could not append addon to configuration!"
cp /tmp/addons.conf$$ /etc/frontview/addons/addons.conf || bye "ERROR: Could not include addon configuration!"
rm -f /tmp/addons.conf$$ || bye "ERROR: Could not clean up temporary space!"

# Copy our removal script to the default directory
cp $orig_dir/remove.sh /etc/frontview/addons/${name}.remove

# Turn ourselves on in the services file
grep -v $name /etc/default/services >/tmp/services$$ || bye "ERROR: Could not locate default services!"
echo "${name}_SUPPORT=1" >>/tmp/services$$ || bye "ERROR: Could not add addon to service configuration!"
echo "${name}=1" >>/tmp/services$$ || bye "ERROR: Could not add addon to service configuration!"
cp /tmp/services$$ /etc/default/services || bye "ERROR: Could not add addon to service configuration!"
rm -f /tmp/services$$ || bye "ERROR: Could not clean up temporary space!"

dpkg -i --force-all squeezeboxserver*.deb &>/dev/null || bye "ERROR: $friendly_name installation failed"
>/etc/debian_version && chattr +i /etc/debian_version

mkdir /c/.squeezeboxserver > /dev/null 2>&1

# Argh... ReadyNAS messes up the Samba configuration if there are folders in /c/ - let's hide ours
# http://bugs.slimdevices.com/show_bug.cgi?id=17819
if [ ! -e /c/.squeezeboxserver/prefs/server.prefs ]; then
  cp -rf /c/squeezeboxserver/* /c/.squeezeboxserver/ > /dev/null 2>&1
fi

# we can't leave our files on the root partition, it's too small
if [ ! -e /c/.squeezeboxserver/prefs/server.prefs ]; then
  cp -rf /var/lib/squeezeboxserver/* /c/.squeezeboxserver/ > /dev/null 2>&1
  cp -rf /var/log/squeezeboxserver/* /c/.squeezeboxserver/log/ > /dev/null 2>&1
fi

# remove invalid dbsource definition
grep -v "dbsource.*/c/sq" /c/.squeezeboxserver/prefs/server.prefs > /tmp/server.prefs
cp /tmp/server.prefs /c/.squeezeboxserver/prefs/server.prefs
rm -f /tmp/server.prefs

rm -rf /var/lib/squeezeboxserver
rm -rf /var/log/squeezeboxserver
rm -rf /c/squeezeboxserver

# Symlink the new log file to the old location, so the log .zip file picks it up
rm -f /var/log/slimserver.log
ln -sf /c/.squeezeboxserver/log/server.log /var/log/slimserver.log 

# Start up the addon program
eval $run || bye "ERROR: Could not start $friendly_name service"

bye "Successfully installed $friendly_name addon package."
