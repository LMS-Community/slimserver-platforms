#!/bin/bash
#
# This script returns 0 if service is running, 1 otherwise.
#
# UNCOMMENT and MODIFY as necessary; return 1 for now.
#

if ! ps -ef | grep "/usr/sbin/squeezeboxserver " | grep -v grep &> /dev/null; then
  exit 1
fi

exit 0
