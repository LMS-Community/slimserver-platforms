#! /bin/sh
/usr/sbin/arp -s $2 $1 2>&1
./update_firmware.pl --embedded-tool $1 $2 2>&1
/usr/sbin/arp -d $2 2>&1 >/dev/null