#!/bin/sh

#
#  Create the StartupItem for the SlimServer. This script, when expanded, includes the current user's ID
# and home directory, as set, to ensure proper functioning of the server (which needs the right
# user and home directory for its own process). We don't blithely assume /Users/$user because the
# user's home directory could be on a network, and set differently in NetInfo.
#
#  This script is designed to be run authenticated.
#

mkdir -p -m go-w /Library/StartupItems/Slim

cat >/Library/StartupItems/Slim/StartupParameters.plist << '!!'
{
    Description		= "SlimServer";
    Provides		= ("SlimServer");
    Requires		= ("Disks");
    Uses		= ("mDNSResponder", "Resolver", "DirectoryServices", "NFS", "Network Time");
    OrderPreference	= "Late";
    Messages =
    {
	start = "Starting SlimServer";
	stop = "Stopping SlimServer";
    };
}
!!

cat >/Library/StartupItems/Slim/Slim << !!
#!/bin/sh
. /etc/rc.common

SLIMUSER=$USER
SERVER_RUNNING=\`ps -axww | grep "slimp3\.pl\|slimp3d\|slimserver\.pl\|slimserver" | grep -v grep | cat\`
HOME=$HOME
home=$HOME
export HOME
export home

StartService() {
ConsoleMessage "Starting SlimServer"
if [ z"\$SERVER_RUNNING" = z ] ; then
    if [ -e "$HOME/Library/PreferencePanes/SlimServer.prefPane/Contents/server" ] ; then
	pushd "$HOME/Library/PreferencePanes/SlimServer.prefPane/Contents/server"
    else
	pushd "/Library/PreferencePanes/SlimServer.prefPane/Contents/server"
    fi
    sudo -u \$SLIMUSER "Slim Launcher.app/Contents/Resources/Start Slim Server.sh"
    popd
fi
if [ z"\$#" != z"0" ] ; then
    ConsoleMessage -S
fi
}

StopService() {
if [ z"\$SERVER_RUNNING" != z ] ; then
    ConsoleMessage "Stopping SlimServer"
    kill \`echo \$SERVER_RUNNING | sed -n 's/^[ ]*\([0-9]*\)[ ]*.*$/\1/p'\`
fi
}

RestartService() {
    StopService
    StartService
}

if [ z"\$#" == z"0" ] ; then
    StartService
else
    case \$1 in 
	start  ) StartService   ;;
	stop   ) StopService    ;;
	restart) RestartService ;;
	*      ) echo "$0: unknown argument: $1";;
    esac
fi

!!

chmod +x /Library/StartupItems/Slim/Slim

mkdir -p -m go-w /Library/StartupItems/Slim/Resources/French.lproj

cat >/Library/StartupItems/Slim/Resources/French.lproj/Localizable.strings << '!!'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Starting SlimServer</key>
	<string>Démarrage du SlimServer</string>
	<key>Stopping SlimServer</key>
	<string>Arrêt du SlimServer</string>
</dict>
</plist>
!!


mkdir -p -m go-w /Library/StartupItems/Slim/Resources/German.lproj

cat >/Library/StartupItems/Slim/Resources/English.lproj/Localizable.strings << '!!'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Starting SlimServer</key>
	<string>Starting SlimServer</string>
	<key>Stopping SlimServer</key>
	<string>Stopping SlimServer</string>
</dict>
</plist>
!!

mkdir -p -m go-w /Library/StartupItems/Slim/Resources/English.lproj

cat >/Library/StartupItems/Slim/Resources/English.lproj/Localizable.strings << '!!'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Starting SlimServer</key>
	<string>Starting SlimServer</string>
	<key>Stopping SlimServer</key>
	<string>Stopping SlimServer</string>
</dict>
</plist>
!!
