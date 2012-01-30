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
  orig_vers=`awk -F'!!' '/%ADDON%/ { print $3 }' $ADDON_HOME/addons.conf | cut -f1 -d'.'`
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


# Set run-time secs to 60 secs.  We'll save this in /etc/default/services.
grep -v %ADDON%_RUNTIME_SECS /etc/default/services > /tmp/services
echo "%ADDON%_RUNTIME_SECS=60" >> /tmp/services
cp /tmp/services /etc/default/services
rm -f /tmp/services


######################################################


eval $run

friendly_name=`awk -F'!!' '{ print $2 }' $orig_dir/addons.conf`

# Remove the installation files
cd /
rm -rf $orig_dir

exit 0
