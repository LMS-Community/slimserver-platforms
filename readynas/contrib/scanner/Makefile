#=========================================================================
# FILENAME	: Makefile
# DESCRIPTION	: makefile for scanner
#=========================================================================
# Copyright (c) 2008- NETGEAR, Inc. All Rights Reserved.
#=========================================================================


# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


# locale
LANG=C

#CC = sparc-linux-gcc
CC = gcc
LDFLAGS := -lmysqlclient -lid3tag -logg -lvorbis -lFLAC -lssl -lgd

ifeq (${DEBUG},1)
  CFLAGS = ${EXTRACFLAGS} -O -Wall -ggdb
  STRIP = touch
else
  CFLAGS = ${EXTRACFLAGS} -O2 -Wall
  STRIP = strip
  LDFLAGS := ${EXTRALDFLAGS} ${LDFLAGS} -s
endif


EXES = scanner
OBJS = tagutils.o tagutils-plist.o log.o sqlprintf.o textutils.o prefs.o artwork.o db.o \
	misc.o filecache.o

.PHONY: usage all clean TAGS

usage:
	@echo
	@echo "Usage:"
	@echo "  make all                        ... build normally"
	@echo "  make EXTRACFLAGS='-I xxxl all   ... build normally with EXTRACFLAGS"
	@echo "  make EXTRALDFLAGS='-I xxxl all  ... build normally with EXTRALDFLAGS"
	@echo "  make DEBUG=1 all                ... build with -ggdb"
	@echo "  make clean                      ... clean"
	@echo "  make TAGS                       ... create tag file for emacs"
	@echo

all: .depend ${EXES}

# 
scanner: $(OBJS) scanner.o
	$(CC) $(CFLAGS) $(LDFLAGS) $(OBJS) scanner.o -o $@

#
TAGS:
	etags *.[ch]

clean:
	rm -f *.o *~ $(EXES) TAGS \#* .depend

.depend:
	gcc -MM ${OBJS:%.o=%.c} ${EXE:%=%.c} > .depend

ifneq ($(wildcard .depend),)
-include .depend
endif
