#! /bin/sh
SERVER_RUNNING=`ps -axww | grep "slimp3\.pl\|slimp3d" | grep -v grep | cat`
if [ z"$SERVER_RUNNING" = z ] ; then

    # Check to see if we're publishing with Rendezvous -- if not, use daemon mode.
    
    if [ z"$#" == z"0" ] ; then
	./slimp3.pl --daemon --d_server --logfile /tmp/slimp3error.log >> /tmp/slimp3error.log 2>&1
    else
	./slimp3.pl >> /tmp/slimp3error.log 2>&1 
    fi
fi
