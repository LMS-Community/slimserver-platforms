#!/bin/bash
#
# This should contain necessary code to start the service

start-stop-daemon -S -b -m --pidfile /var/run/%ADDON%.pid -q -x /etc/frontview/addons/bin/%ADDON%/%ADDON%_service
