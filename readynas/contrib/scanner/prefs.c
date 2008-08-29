//=========================================================================
// FILENAME	: prefs.c
// DESCRIPTION	: Preference file reader
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

#include <string.h>
#include <ctype.h>
#include <stdio.h>

#include "misc.h"
#include "prefs.h"
#include "textutils.h"
#include "log.h"

static void
_read_prefs_ignoredwords(const char *words)
{
  char *words_dup = strdup(words);		// dont free(words_dup) !
  char *p, *w;
  int i, n;

  // count
  p = words_dup;
  n = 0;
  while (1) {
    while (*p && !isalnum(*p)) p++;
    if (!(*p))
      break;
    while (*p && isalnum(*p)) p++;
    n++;
    if (!(*p))
      break;
  }

  prefs.ignoredwords = (struct _ignoredwords *) calloc((n+1), sizeof(struct _ignoredwords));

  // read
  p = words_dup;
  n = 0;
  i = 0;
  while (1) {
    while (*p && !isalnum(*p)) p++;
    if (!(*p))
      break;
    n = 0;
    w = p;
    while (*p && isalnum(*p)) {p++; n++;}
    prefs.ignoredwords[i].word = w;
    prefs.ignoredwords[i].n = n;
    if (!(*p))
      break;
    *p++ = '\0';
    i++;
  }
}

int
read_prefs(const char *prefsfile)
{
  FILE *fp;
  char buf[256];

  DPRINTF(E_INFO, L_PREFS, "prefsfile=%s\n", prefsfile);

  if (!(fp = fopen(prefsfile, "r")))
    return -1;

  bzero(&prefs, sizeof(prefs));

  while (fgets(buf, sizeof(buf), fp)) {
    int len = strlen(buf);

    if (buf[len-1]=='\n') buf[len-1] = '\0';

    if (!strncmp(buf, "ignoredarticles:", 16))
      _read_prefs_ignoredwords(buf+16);
    else if (!strncmp(buf, "audiodir:", 9))
      prefs.audiodir = strdup(skipspaces(buf+9));
    else if (!strncmp(buf, "playlistdir:", 12))
      prefs.playlistdir = strdup(skipspaces(buf+12));
    else if (!strncmp(buf, "cachedir:", 9))
      prefs.cachedir = strdup(skipspaces(buf+9));
    else if (!strncmp(buf, "language:", 9))
      // CS/DA/DE/EN/ES/FI/FR/HE/IT/JA/NL/NO/PT/SV/ZH_CN/ZH_TW
      prefs.language = strdup(skipspaces(buf+9));
  }

  fclose(fp);
  return 0;
}
