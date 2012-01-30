#!/bin/bash
#
# This should contain necessary code to start the service

start-stop-daemon -S -b -m --pidfile /var/run/SQUEEZEBOX.pid -q -x /etc/frontview/addons/bin/SQUEEZEBOX/SQUEEZEBOX_service
