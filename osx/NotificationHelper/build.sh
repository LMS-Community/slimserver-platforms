#!/bin/sh

platypus \
--name="lms-notify" \
--interface-type=None \
--author="Lyrion Community, Michael Herger" \
--bundle-identifier=org.lyrion.lms-notify \
--app-version=1.0.0 \
--app-icon=../MenuBarItem/icon.icns \
--overwrite \
NotificationHelper.sh
