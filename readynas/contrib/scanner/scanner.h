//=========================================================================
// FILENAME	: scanner.h
// DESCRIPTION	: Header for Scanner
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

#include <time.h>

#define PROGRESS_DIRECTORY 0
#define PROGRESS_PLAYLIST 1
#define PROGRESS_ARTWORK 2
#define PROGRESS_NR 3

// determin how often update 'progress' table in db
#define PROGRESS_MASK 127


struct _g {
  int wipe;
  int show_progress;
  time_t lastrescantime;

  unsigned long progress_total[PROGRESS_NR];
  unsigned long progress_done[PROGRESS_NR];
  unsigned long long progress_start[PROGRESS_NR];
  unsigned long long progress_finish[PROGRESS_NR];

  unsigned long skipped_songs;
  unsigned long added_songs;
  unsigned long updated_songs;
  unsigned long deleted_songs;

  char *no_genre_str;
  char *no_album_str;
  char *no_title_str;
  char *no_artist_str;
  char *variousartists_str;
};

extern struct _g G;
