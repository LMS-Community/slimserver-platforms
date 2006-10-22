#! /bin/sh

SERVER_RUNNING=`ps -axww | grep "slimserver\.pl" | grep -v grep | cat`

if [ z"$SERVER_RUNNING" = z ] ; then

    # Check to see if we're publishing with Rendezvous -- if not, use daemon mode.
    if [ z"$#" == z"0" ] ; then
	if [ ! -e ~/Library/Logs/SlimServer ] ; then mkdir ~/Library/Logs/SlimServer ; fi
	./slimserver.pl --daemon --logdir ~/Library/Logs/SlimServer
    else
	./slimserver.pl >> /tmp/slimerror.log 2>&1 
    fi
fi
