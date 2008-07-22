//=========================================================================
// FILENAME	: artwork.c
// DESCRIPTION	: Search artwork file
//=========================================================================
// Copyright (c) 2008- NETGEAR, Inc. All Rights Reserved.
//=========================================================================

/* This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <limits.h>
#include <sys/stat.h>
#include <string.h>
#include <stdio.h>

#include "artwork.h"
#include "log.h"
#include "textutils.h"

char *basenames[] = {
  "cover", "Cover",
  "thumb", "Thumb",
  "album", "Album",
  "folder", "Folder",
  0
};

char *extentions[] = {
  "png", "jpg", "jpeg", "gif", 0
};

char *
artwork_find_file(const char *url)
{
  char buf[PATH_MAX], *dirend;
  struct stat stat;
  int i, j;

  DPRINTF(E_INFO, L_ARTWORK, "Looking artwork <%s>\n", url);

  urldecode((char*)url);
  if ((strncmp("file://", url, 7)))
    return 0;

  strncpy(buf, url+7, sizeof(buf)-1);

  dirend = rindex(buf, '/');

  if (!dirend)
    return 0;

  *dirend = '\0';
  lstat(buf, &stat);
  if (!(stat.st_mode & S_IFDIR)) {
    return 0;
  }

  // look for prefs.coverArt, then {[cC]over,[tT]humb,[aA]lbum,[fF]older}.{png,jpg,jpeg,gif}
  for (i=0; basenames[i]; i++) {
    for (j=0; extentions[j]; j++) {
      sprintf(dirend, "/%s.%s", basenames[i], extentions[j]);
      lstat(buf, &stat);
      if ((stat.st_mode & S_IFREG)) {
	DPRINTF(E_INFO, L_ARTWORK, "Found artwork file <%s> for <%s>\n", buf, url);
	return strdup(buf);
      }
    }
  }
  return 0;
}
