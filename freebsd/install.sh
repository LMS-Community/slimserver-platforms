#! /bin/sh
# install.sh -- Logitech Media Server (LMS) FreeBSD installer.
# *** Copyleft (C) 2012 Ian Pallfreeman, XenoPsyche, Inc. ***
#
# This is a simple script to install Logitech (nee Slim Devices) Media Server
# onto a vanilla FreeBSD box. Ripped off SlimNAS8Pro ZFS FreeNAS8 installer.

# I really can't be arsed to keep changing the names...

MYDIR=/usr/local/squeezeboxserver
LOGDIR=/var/log/squeezeboxserver
DATADIR=/var/db/squeezeboxserver
MYGROUP=slimserv; MYGID=104
MYUSER=slimserv; MYUID=75

# wibble

yesno() {
    local question answer

    question=$1
    read -p "$question (y/N)? " answer
    case "${answer}" in
        [Yy]*)          return 0;;
    esac
    return 1
}

# get set

if [ `id -u` -ne 0 ]; then
    echo "You need to be root."; exit 1
fi

if ! which perl > /dev/null 2>&1; then
    echo "I don't see perl out there. Make sure it's installed and in your \$PATH."; exit 1
fi

perlver=perl-`perl -v | grep ^This | awk '{print $9}' | sed -e 's/[)v(]//'g`
rel=`uname -r | cut -f1 -d-`
arch=`uname -m`

echo "This looks like FreeBSD-$rel $arch $perlver."; echo ""

# find which file to install from

if [ -n "$1" ]; then
    if [ -f "$1" ]; then
	tarfile=$1
    else
        echo "$1: not found"; exit 1
    fi
else
    poss=`echo logitechmediaserver-*-$perlver-FreeBSD-$rel-*-$arch.tgz`
    if [ "$poss" = "logitechmediaserver-*-$perlver-FreeBSD-$rel-*-$arch.tgz" ]; then
	echo "I see no suitable tarfile to install."; exit 1
    fi
    cnt=`for i in $poss;do echo "$i"; done | wc -l`;
    if [ $cnt -eq 1 ]; then
	tarfile=$poss; 
    else
	echo "Several versions were found which could be installed. Please select one."
	echo ""
	tarfile=""
	for f in $poss; do 
	    if yesno $f; then
		tarfile=$f; break;
            fi
        done
	if [ -z "$tarfile" ]; then
	    echo ""; echo "No version selected. Bye."; exit 1
        fi
    fi
    echo ""
fi

if ! yesno "Install $tarfile"; then
    exit
fi

# fiddle with the user and group

if pw group show $MYGROUP > /dev/null 2>&1; then
    echo "Group \"$MYGROUP\" already exists, we'll use it."
else 
    if pw group show $MYGID > /dev/null 2>&1; then
	echo "GID $MYGID is already in use. Please create the \"$MYGROUP\" group manually."; exit 1
    fi
    pw groupadd $MYGROUP -g $MYGID
    echo "Group \"$MYGROUP\" added."
fi

if pw user show $MYUSER > /dev/null 2>&1; then
    echo "User \"$MYUSER\" already exists, we'll use it"
else 
    if pw user show $MYUID > /dev/null 2>&1; then
	echo "UID $MYUID is already in use. Please create the \"$MYUSER\" user manually."; exit 1
    fi
    pw useradd $MYUSER -u $MYUID -g $MYGROUP -h - -s /bin/sh -c "Logitech Media Server" -d $MYDIR
    echo "User \"$MYUSER\" added."
fi

if [ -e $MYDIR ]; then
    if [ ! -L $MYDIR ]; then
	echo "$MYDIR exists but isn't a symlink. Please make it go away."; exit 1
    fi
    echo "$MYDIR link found, so we'll upgrade."
    newinstall=false
else
    echo "$MYDIR doesn't exist, we'll do a new installation."
    newinstall=true
fi

if $newinstall; then                  # XXX created by rc script, so... ???
    echo "Creating directories..."
    mkdir -p $LOGDIR; chown -RH $MYUSER:$MYGROUP $LOGDIR
    for f in perfmon scanner server; do 
	touch $LOGDIR/$f.log; chown $MYUSER:$MYGROUP $LOGDIR/$f.log
    done
    for d in cache playlists prefs; do
	mkdir -p $DATADIR/$d
    done
    chown -RH $MYUSER:$MYGROUP $DATADIR
    rcf=/usr/local/etc/rc.d/squeezeboxserver
    if [ -f $rcf ]; then
	echo "$rcf exists, I won't overwrite it."
    else
	if [ -f squeezeboxserver.tpl ]; then 
	    echo "Installing rc script..."
	    cat squeezeboxserver.tpl | sed -e "s/^u=slimserv/u=$MYUSER/" | sed -e "s/^g=slimserv/g=$MYGROUP/" > $rcf
	    chown root:wheel $rcf
	    chmod 555 $rcf
	else
	    echo "No rc script found."
	fi
    fi
    if [ -f server.prefs ]; then
	if yesno "I see a server.prefs. Do you want me to install it"; then
	    dpsp=$DATADIR/prefs/server.prefs
	    sed -e '/^server_uuid:/ d' server.prefs > $dpsp
	    chown $MYUSER:$MYGROUP $dpsp
	    chmod 644 $dpsp
       fi
    fi
fi

echo "Installing tarfile..."
tmpf=/tmp/instsq$$
cat $tarfile | (cd /usr/local; tar zxvf - 2>$tmpf)
newver=`head -1 $tmpf | sed -e 's/^x //' | sed -e 's@/$@@'`
rm -f $tmpf

cd /usr/local/$newver
rm -rf Cache Logs prefs
ln -s $DATADIR/cache ./Cache
ln -s $DATADIR/prefs ./prefs
ln -s $LOGDIR ./Logs

cd ..
chown -Rh $MYUSER:$MYGROUP $newver
rm -f squeezeboxserver
ln -s ./$newver ./squeezeboxserver

echo "$newver installed."
