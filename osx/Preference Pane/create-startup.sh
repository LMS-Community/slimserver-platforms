#!/bin/sh

#
#  Create the StartupItem for the . This script, when expanded, includes the current user's ID
# and home directory, as set, to ensure proper functioning of the server (which needs the right
# user and home directory for its own process). We don't blithely assume /Users/$user because the
# user's home directory could be on a network, and set differently in NetInfo.
#
#  This script is designed to be run authenticated.
#

mkdir -p -m go-w /Library/StartupItems/SqueezeCenter

cat >/Library/StartupItems/SqueezeCenter/StartupParameters.plist << '!!'
{
    Description		= "";
    Provides		= ("");
    Requires		= ("Disks");
    Uses		= ("mDNSResponder", "Resolver", "DirectoryServices", "NFS", "Network Time");
    OrderPreference	= "Late";
    Messages =
    {
	start = "Starting ";
	stop = "Stopping ";
    };
}
!!

cat >/Library/StartupItems/SqueezeCenter/SqueezeCenter << !!
#!/bin/sh
. /etc/rc.common

SLIMUSER=$USER
SERVER_RUNNING=\`ps -axww | grep "squeezecenter\.pl|slimp3\.pl\|slimp3d\|slimserver\.pl\|slimserver" | grep -v grep | cat\`
HOME=$HOME
home=$HOME
export HOME
export home

StartService() {
ConsoleMessage "Starting "
if [ z"\$SERVER_RUNNING" = z ] ; then
	if [ -e "$HOME/Library/PreferencePanes/SqueezeCenter.prefPane/Contents/server" ] ; then
		pushd "$HOME/Library/PreferencePanes/SqueezeCenter.prefPane/Contents/server"
	else
		pushd "/Library/PreferencePanes/SqueezeCenter.prefPane/Contents/server"
	fi
	sudo -H -u \$SLIMUSER "SqueezeCenter.app/Contents/Resources/start-server.sh"
	popd
fi
if [ z"\$#" != z"0" ] ; then
	ConsoleMessage -S
fi
}

StopService() {
if [ z"\$SERVER_RUNNING" != z ] ; then
    ConsoleMessage "Stopping "
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

chmod +x /Library/StartupItems/SqueezeCenter/SqueezeCenter

mkdir -p -m go-w /Library/StartupItems/SqueezeCenter/Resources/French.lproj

cat >/Library/StartupItems/SqueezeCenter/Resources/French.lproj/Localizable.strings << '!!'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Starting </key>
	<string>Démarrage du </string>
	<key>Stopping </key>
	<string>Arrêt du </string>
</dict>
</plist>
!!


mkdir -p -m go-w /Library/StartupItems/SqueezeCenter/Resources/German.lproj

cat >/Library/StartupItems/SqueezeCenter/Resources/English.lproj/Localizable.strings << '!!'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Starting </key>
	<string>Starting </string>
	<key>Stopping </key>
	<string>Stopping </string>
</dict>
</plist>
!!

mkdir -p -m go-w /Library/StartupItems/SqueezeCenter/Resources/English.lproj

cat >/Library/StartupItems/SqueezeCenter/Resources/English.lproj/Localizable.strings << '!!'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Starting </key>
	<string>Starting </string>
	<key>Stopping </key>
	<string>Stopping </string>
</dict>
</plist>
!!
