#! /bin/sh
SERVER_RUNNING=`ps -axww | grep "ueml\.pl" | grep -v grep | cat`
if [ z"$SERVER_RUNNING" = z ] ; then
    # Check to see if we're publishing with Rendezvous -- if not, use daemon mode.

    if [ z"$#" == z"0" ] ; then
	if [ ! -e ~/Library/Logs ] ; then mkdir ~/Library/Logs ; fi
        ./ueml.pl --daemon $1 &> /dev/null &
    else
        ./ueml.pl $1 & >> /tmp/uemlerror.log 2>&1
    fi
fi
