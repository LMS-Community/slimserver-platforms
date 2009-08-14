#! /bin/sh
SERVER_RUNNING=`ps -axww | grep "squeezecenter\.pl|slimp3\.pl\|slimp3d\|slimserver\.pl\|slimserver" | grep -v grep | cat`
if [ z"$SERVER_RUNNING" = z ] ; then
    # Check to see if we're publishing with Rendezvous -- if not, use daemon mode.

    if [ z"$#" == z"0" ] ; then
	if [ ! -e ~/Library/Logs ] ; then mkdir ~/Library/Logs ; fi
        # Temporary workaround for 64bit OSX 10.6 systems, sets perl to run in 32bit mode
        VERSIONER_PERL_PREFER_32_BIT=yes ./slimserver.pl --daemon $1 &> /dev/null &
    else
        # Temporary workaround for 64bit OSX 10.6 systems, sets perl to run in 32bit mode
        VERSIONER_PERL_PREFER_32_BIT=yes ./slimserver.pl $1 & >> /tmp/squeezeboxerror.log 2>&1
    fi
fi
