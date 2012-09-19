#!/bin/sh

#
# Create the StartupItem for the server. This script, when expanded, includes the current user's ID
# and home directory, as set, to ensure proper functioning of the server (which needs the right
# user and home directory for its own process). We don't blithely assume /Users/$user because the
# user's home directory could be on a network, and set differently in NetInfo.
#
#  This script is designed to be run authenticated.
#

# remove legacy startup item
rm -rf /Library/StartupItems/SqueezeCenter
rm -rf /Library/StartupItems/Squeezebox\ Server

PRODUCT_NAME="UE Music Library"
PRODUCT_FOLDER=UEMusicLibrary

mkdir -p -m go-w /Library/StartupItems/$PRODUCT_FOLDER

cat >/Library/StartupItems/$PRODUCT_FOLDER/StartupParameters.plist << !!
{
	Description     = "$PRODUCT_NAME";
	Provides        = ("$PRODUCT_NAME");
	Requires        = ("Disks");
	Uses            = ("mDNSResponder", "Resolver", "DirectoryServices", "NFS", "Network Time");
	OrderPreference	= "Late";
	Messages =
	{
		start = "Starting $PRODUCT_NAME";
		stop = "Stopping $PRODUCT_NAME";
	};
}
!!

cat >/Library/StartupItems/$PRODUCT_FOLDER/$PRODUCT_FOLDER << !!
#!/bin/sh
. /etc/rc.common

SLIMUSER=$USER
SERVER_RUNNING=\`ps -axww | grep "ueml\.pl" | grep -v grep | cat\`
HOME=$HOME
home=$HOME
export HOME
export home

StartService() {
ConsoleMessage "Starting $PRODUCT_NAME"
if [ z"\$SERVER_RUNNING" = z ] ; then
	if [ -e "$HOME/Library/PreferencePanes/UEMusicLibrary.prefPane/Contents/server" ] ; then
		pushd "$HOME/Library/PreferencePanes/UEMusicLibrary.prefPane/Contents/Resources"
	else
		pushd "/Library/PreferencePanes/UEMusicLibrary.prefPane/Contents/Resources"
	fi
	sudo -H -u \$SLIMUSER ./start-server.sh
	popd
fi
if [ z"\$#" != z"0" ] ; then
	ConsoleMessage -S
fi
}

StopService() {
if [ z"\$SERVER_RUNNING" != z ] ; then
	ConsoleMessage "Stopping $PRODUCT_NAME"
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

chmod +x /Library/StartupItems/$PRODUCT_FOLDER/$PRODUCT_FOLDER

mkdir -p -m go-w /Library/StartupItems/$PRODUCT_FOLDER/Resources/French.lproj

cat >/Library/StartupItems/$PRODUCT_FOLDER/Resources/French.lproj/Localizable.strings << !!
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Starting $PRODUCT_NAME</key>
	<string>Démarrage de $PRODUCT_NAME</string>
	<key>Stopping $PRODUCT_NAME</key>
	<string>Arrêt de $PRODUCT_NAME</string>
</dict>
</plist>
!!


mkdir -p -m go-w /Library/StartupItems/$PRODUCT_FOLDER/Resources/German.lproj

cat >/Library/StartupItems/$PRODUCT_FOLDER/Resources/German.lproj/Localizable.strings << !!
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Starting $PRODUCT_NAME</key>
	<string>Starte $PRODUCT_NAME</string>
	<key>Stopping $PRODUCT_NAME</key>
	<string>Beende $PRODUCT_NAME</string>
</dict>
</plist>
!!

mkdir -p -m go-w /Library/StartupItems/$PRODUCT_FOLDER/Resources/English.lproj

cat >/Library/StartupItems/$PRODUCT_FOLDER/Resources/English.lproj/Localizable.strings << !!
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Starting $PRODUCT_NAME</key>
	<string>Starting $PRODUCT_NAME</string>
	<key>Stopping $PRODUCT_NAME</key>
	<string>Stopping $PRODUCT_NAME</string>
</dict>
</plist>
!!
