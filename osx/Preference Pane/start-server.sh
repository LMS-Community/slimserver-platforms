#!/bin/sh
SERVER_RUNNING=`ps -axww | grep "ueml\.pl" | grep -v grep | cat`
if [ z"$SERVER_RUNNING" = z ] ; then
    # Check to see if we're publishing with Rendezvous -- if not, use daemon mode.

	if [ ! -e ~/Library/Logs ] ; then 
		mkdir ~/Library/Logs ;
	fi
    
	cd "`dirname $0`/../server"
	
	./ueml.pl --daemon $1 &> /dev/null &
fi
