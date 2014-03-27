#!/bin/sh
#set -x
distdir="${1:-SlimServer_v7.8.1}"
title="$distdir"

mkdir $distdir/pkg
mkdir $distdir/pkg/etc
mkdir $distdir/pkg/etc/init.d
mkdir $distdir/pkg/etc/rc0.d
mkdir $distdir/pkg/etc/rc1.d
mkdir $distdir/pkg/etc/rc2.d
mkdir $distdir/pkg/etc/rc3.d
mkdir $distdir/pkg/etc/rcS.d
mkdir $distdir/pkg/opt

cp misc/solaris/prototype     $distdir/pkg
cp misc/solaris/postinstall   $distdir/pkg
cp misc/solaris/postremove    $distdir/pkg
cp misc/solaris/preinstall    $distdir/pkg
cp misc/solaris/preremove     $distdir/pkg
cp misc/solaris/slimserver.init   $distdir/pkg/etc/init.d/slimserver

ln -s ../init.d/slimserver $distdir/pkg/etc/rc0.d/K01slimserver
ln -s ../init.d/slimserver $distdir/pkg/etc/rc1.d/K01slimserver
ln -s ../init.d/slimserver $distdir/pkg/etc/rc2.d/K01slimserver
ln -s ../init.d/slimserver $distdir/pkg/etc/rc3.d/S99slimserver
ln -s ../init.d/slimserver $distdir/pkg/etc/rcS.d/K01slimserver
ln -s $distdir $distdir/pkg/opt/slimserver
#touch $distdir/pkg/etc/slimserver.pref

#chmod 0644 $distdir/pkg/etc/slimserver.pref
chmod 0744 $distdir/pkg/etc/init.d/slimserver
chmod 0755 $distdir/pkg/opt

cd $distdir/pkg/opt
gzcat ../../$title.tar.gz | tar xf -
cd ..
find ./opt -print | pkgproto | awk '{print $1" "$2" "$3" "$4" root root"}' | \
  sed 's/^d none opt 0755 root root/d none opt 0755 root sys/' >> prototype
#find ./opt -print | pkgproto | awk '{print $1" "$2" "$3" "$4" root root"}' >> prototype
cd ../../..


#awk '/^d /{print $1" "$2" "$3" "$4" root root"}' prototype 
#awk '/^f /{print $1" "$2" "$3" "$4" root root"}' prototype 
#awk '/^d /{print $1" "$2" "$3" "$4" root root"} /^f /{print $1" "$2" "$3" "$4" root root"}' prototype
#awk '{if ($1 ~ /^d/) print $1" "$2" "$3" "$4" root root"}' prototype|more

