#!/bin/bash

ADDON_HOME=/etc/frontview/addons
UEML=UEML

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

###########  Addon specific action go here ###########

# tell user to uninstall LMS before installing UEMLfull
if [ z"$UEML" = z ] && grep -q SQUEEZEBOX $ADDON_HOME/addons.conf; then
	bye "ERROR: Please uninstall Logitech Media Server before installing UE Music Library."
fi 

######################################################

if grep -q ${name} $ADDON_HOME/addons.conf; then
  orig_vers=`awk -F'!!' '/UEML/ { print $3 }' $ADDON_HOME/addons.conf | cut -f1 -d'.'`
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
# enable UEML by default
grep -v UEML /etc/default/services > /tmp/services
echo "UEML=1" >> /tmp/services
cp /tmp/services /etc/default/services
rm -f /tmp/services

# try to migrate LMS prefs to UEML
if [ ! -e /c/.uemusiclibrary/prefs/server.prefs ] && [ -f /c/.squeezeboxserver/prefs/server.prefs ]; then
	# remove invalid dbsource definition
	grep -v "dbsource.*/c/sq" | grep -v "squeezeboxserver" /c/.squeezeboxserver/prefs/server.prefs > /tmp/server.prefs 2> /dev/null
	mv /tmp/server.prefs /c/.uemusiclibrary/prefs/server.prefs > /dev/null 2>&1
	#rm -f /tmp/server.prefs > /dev/null 2>&1
fi
######################################################


eval $run

friendly_name=`awk -F'!!' '{ print $2 }' $orig_dir/addons.conf`

# Remove the installation files
cd /
rm -rf $orig_dir

exit 0
