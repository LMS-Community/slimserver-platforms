#!/bin/sh
#
# $FreeBSD: ports/audio/squeezeboxserver/files/squeezeboxserver.sh.in,v 1.3 2010/03/27 00:12:43 dougb Exp $
#

# PROVIDE: squeezeboxserver
# REQUIRE: LOGIN
# KEYWORD: shutdown

#
# Add the following lines to /etc/rc.conf to enable squeezeboxserver:
#
#squeezeboxserver_enable="YES"
#

. /etc/rc.subr

name=squeezeboxserver
start_precmd="squeezeboxserver_start_precmd"
stop_postcmd="squeezeboxserver_stop_postcmd"
rcvar=`set_rcvar`

command=/usr/local/squeezeboxserver/slimserver.pl
command_interpreter=/usr/bin/perl
pidfile=/var/run/${name}/${name}.pid
logdir=/var/log/${name}
statedir=/var/db/squeezeboxserver
cachedir=${statedir}/cache
prefsdir=${statedir}/prefs
playlistdir=${statedir}/playlists
u=slimserv
g=slimserv
command_args="--daemon --pidfile=${pidfile}"
squeezeboxserver_user=${u}
squeezeboxserver_group=${g}

squeezeboxserver_start_precmd()
{
	# This is stuff is here and not in pkg-install because
	# /var/run may be destroyed at any time and we've had issues
	# with permissions on the various directories under /var getting
 	# screwed up in the past.

	mkdir -p /var/run/${name}
	chown -RH ${u}:${g} /var/run/${name}

	mkdir -p ${logdir}
	chown -RH ${u}:${g} ${logdir}

	mkdir -p ${statedir}
	mkdir -p ${cachedir}
	mkdir -p ${prefsdir}
	mkdir -p ${playlistdir}
	chown -RH ${u}:${g} ${statedir}
}

squeezeboxserver_stop_postcmd()
{
	pids=`pgrep -u $u`
	if [ -n "${pids}" ]; then
		sleep 1
		kill $pids > /dev/null 2>&1
	fi
	pids=`pgrep -u $u`
	if [ -n "${pids}" ]; then
		wait_for_pids $pids
	fi
}

load_rc_config ${name}

squeezeboxserver_enable=${squeezeboxserver_enable:-"NO"}
squeezeboxserver_flags=${squeezeboxserver_flags:-""}

run_rc_command "$1"
