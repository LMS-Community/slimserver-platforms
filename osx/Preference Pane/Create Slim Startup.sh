#!/bin/sh

#
#  Create the StartupItem for the Slim server. This script, when expanded, includes the current user's ID
# and home directory, as set, to ensure proper functioning of the server (which needs the right
# user and home directory for its own process). We don't blithely assume /Users/$user because the
# user's home directory could be on a network, and set differently in NetInfo.
#
#  This script is designed to be run authenticated.
#

mkdir -p -m go-w /Library/StartupItems/Slim

cat >/Library/StartupItems/Slim/StartupParameters.plist << '!!'
{
    Description		= "Slim Server";
    Provides		= ("Slim Server");
    Requires		= ("Disks");
    Uses		= ("mDNSResponder", "Resolver", "DirectoryServices", "NFS", "Network Time");
    OrderPreference	= "Late";
    Messages =
    {
	start = "Starting Slim Server";
	stop = "Stopping Slim Server";
    };
}
!!

cat >/Library/StartupItems/Slim/Slim << !!
#!/bin/sh
. /etc/rc.common

SLIMP3USER=$USER
SERVER_RUNNING=\`ps -axww | grep "slimp3\.pl\|slimp3d|slimserver|slimd" | grep -v grep | cat\`
HOME=$HOME
home=$HOME
export HOME
export home

StartService() {
ConsoleMessage "Starting Slim Server"
if [ z"\$SERVER_RUNNING" = z ] ; then
    if [ -e "$HOME/Library/PreferencePanes/Slim Server.prefPane/Contents/server" ] ; then
	pushd "$HOME/Library/PreferencePanes/Slim Server.prefPane/Contents/server"
    else
	pushd "/Library/PreferencePanes/Slim Server.prefPane/Contents/server"
    fi
    sudo -u \$SLIMP3USER "Slim Launcher.app/Contents/Resources/Start Slim Server.sh"
    popd
fi
if [ z"\$#" != z"0" ] ; then
    ConsoleMessage -S
fi
}

StopService() {
if [ z"\$SERVER_RUNNING" != z ] ; then
    ConsoleMessage "Stopping Slim Server"
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