#! /bin/sh
SERVER_RUNNING=`ps -axww | grep "slimp3\.pl\|slimp3d|slimd|slimserver" | grep -v grep | cat`
if [ z"$SERVER_RUNNING" = z ] ; then

    # Check to see if we're publishing with Rendezvous -- if not, use daemon mode.
    
    if [ z"$#" == z"0" ] ; then
	if [ ! -e ~/Library/Logs ] ; then mkdir ~/Library/Logs ; fi
	./slimserver.pl --daemon --d_server --logfile ~/Library/Logs/slimserver.log >> ~/Library/Logs/slimserver.log 2>&1
    else
	./slimserver.pl >> /tmp/slimerror.log 2>&1 
    fi
fi
