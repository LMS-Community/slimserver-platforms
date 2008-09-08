//=========================================================================
// FILENAME	: db.c
// DESCRIPTION	: Database interface for scanner
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

#include <mysql/mysql.h>
#include <mysql/mysqld_error.h>
#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

#include "misc.h"
#include "scanner.h"
#include "tagutils.h"
#include "log.h"
#include "sqlprintf.h"
#include "db.h"
#include "textutils.h"
#include "artwork.h"
#include "filecache.h"

struct _cache {
  int various_artists_id;
  char *va_canonicalized_str;
  int no_album_id;
  char *no_album_canonicalized_str;
  int no_artist_id;
  char *no_artist_canonicalized_str;
} cache = {
  .various_artists_id = 0,
  .va_canonicalized_str = 0,
  .no_album_id = 0
};

static char qstr[2048];

static int
_db_query(MYSQL *mysql, char *qstr, int ignore_errno)
{
  int err;
  DPRINTF(E_INFO, L_DB_SQL, "SQL=%s\n", qstr);
  err = mysql_query(mysql, qstr);

  if ((!err) || (ignore_errno && mysql_errno(mysql)==ignore_errno))
      return 0;

  DPRINTF(E_ERROR, L_DB_MYSQL, "mysql_error: %s on SQL=<%s>\n", mysql_error(mysql), qstr);
  return err;
}

static char*
_song_length_str(int len)
{
  static char str[16];
  if (len<=0) {
    strcpy(str, "NULL");
  }
  else {
    snprintf(str, sizeof(str)-1, "%d.%03d",
	     len/1000, len%1000);
  }
  return str;
}


static int
_get_various_artists(int *id, MYSQL *mysql)
{
  char *p;
  size_t room;
  int n, err;
  MYSQL_RES *result = 0;
  MYSQL_ROW row;

  // cache
  if (!cache.va_canonicalized_str)
    cache.va_canonicalized_str = canonicalize_name(G.variousartists_str);

  // check if record already exist
  p = qstr;
  room = sizeof(qstr) - 1;
  (void) sql_snprintf(p, room, "select id from contributors where name='%S'", G.variousartists_str);
  if ((err = _db_query(mysql, qstr, 0)))
    goto _exit;
  if (!(result = mysql_store_result(mysql))) {
    DPRINTF(E_DEBUG, L_DB_MYSQL, "No return result on select\n");
    err = -1;
    goto _exit;
  }
  if ((mysql_num_fields(result))) {
    if ((row = mysql_fetch_row(result))) {
      // exist, get id
      *id = atoi(row[0]);
    }
    else {
      // not exist, insert it
      p = qstr;
      room = sizeof(qstr) - 1;
      n = snprintf(p, room, "insert into contributors (name,namesort,namesearch) values ");
      p += n; room -= n;
      sql_snprintf(p, room, "('%S','%S','%S')",
		      G.variousartists_str, cache.va_canonicalized_str, cache.va_canonicalized_str);
      if ((err = _db_query(mysql, qstr, 0)))
	goto _exit;
      *id = mysql_insert_id(mysql);
    }
  }
  else {
    DPRINTF(E_INFO, L_DB_SQL, "Unexpected error\n");
    err = -1;
    goto _exit;
  }

 _exit:
  if (result)
    mysql_free_result(result);

  return err;
}

static int
_get_no_artist(int *id, MYSQL *mysql)
{
  char *p;
  size_t room;
  int n, err;
  MYSQL_RES *result = 0;
  MYSQL_ROW row;

  // cache
  if (!cache.no_artist_canonicalized_str)
    cache.no_artist_canonicalized_str = canonicalize_name(G.no_artist_str);

  // check if record already exist
  p = qstr;
  room = sizeof(qstr) - 1;
  (void) sql_snprintf(p, room, "select id from contributors where name='%S'", G.no_artist_str);
  if ((err = _db_query(mysql, qstr, 0)))
    goto _exit;
  if (!(result = mysql_store_result(mysql))) {
    DPRINTF(E_DEBUG, L_DB_MYSQL, "No return result on select\n");
    err = -1;
    goto _exit;
  }
  if ((mysql_num_fields(result))) {
    if ((row = mysql_fetch_row(result))) {
      // exist, get id
      *id = atoi(row[0]);
    }
    else {
      // not exist, insert it
      p = qstr;
      room = sizeof(qstr) - 1;
      n = snprintf(p, room, "insert into contributors (name,namesort,namesearch) values ");
      p += n; room -= n;
      sql_snprintf(p, room, "('%S','%S','%S')",
		      G.no_artist_str, cache.no_artist_canonicalized_str, cache.no_artist_canonicalized_str);
      if ((err = _db_query(mysql, qstr, 0)))
	goto _exit;
      *id = mysql_insert_id(mysql);
    }
  }
  else {
    DPRINTF(E_INFO, L_DB_SQL, "Unexpected error\n");
    err = -1;
    goto _exit;
  }

 _exit:
  if (result)
    mysql_free_result(result);

  return err;
}

static int
_insert_contributor_album_track(MYSQL *mysql, struct song_metadata *psong, int role)
{
  char *p;
  size_t room;
  int err;
  unsigned long contributor_id;

  // cache
  if (!cache.no_artist_id) {
    if ((err = _get_no_artist(&cache.no_artist_id, mysql)))
      return err;
  }

  // contributor_album
  contributor_id = 0;
  switch (role) {
  case ROLE_ARTIST:
    if (!psong->contributor_id[ROLE_ALBUMARTIST]) {
      if (psong->contributor_id[ROLE_ARTIST])
	contributor_id = psong->contributor_id[ROLE_ARTIST];
      else if (psong->contributor_id[ROLE_TRACKARTIST])
	contributor_id = psong->contributor_id[ROLE_TRACKARTIST];
      else
	contributor_id = cache.no_artist_id;
    }
    break;
  case ROLE_ALBUMARTIST:
    if (psong->contributor_id[ROLE_ALBUMARTIST] &&
	psong->contributor_id[ROLE_TRACKARTIST])
      contributor_id = psong->contributor_id[ROLE_ALBUMARTIST];
    break;
  case ROLE_TRACKARTIST:
    if (!psong->contributor_id[ROLE_ARTIST] &&
	psong->contributor_id[ROLE_ALBUMARTIST])
      contributor_id = psong->contributor_id[role];
    break;
  default:
    contributor_id = psong->contributor_id[role];
    break;
  }
  if (contributor_id) {
    p = qstr;
    room = sizeof(qstr) - 1;
    (void) snprintf(p, room, "insert ignore into contributor_album "
		    "(role,contributor,album) values (%d,%ld,%ld)",
		    role, contributor_id, psong->album_id);
    if ((err = _db_query(mysql, qstr, 0)))
      return err;
  }

  // contributor_track
  contributor_id = 0;
  switch (role) {
  case ROLE_ARTIST:
    if (!psong->contributor_id[ROLE_ARTIST]) {
      if (!psong->contributor_id[ROLE_ALBUMARTIST]) {
	if (psong->contributor_id[ROLE_TRACKARTIST])
	  contributor_id = psong->contributor_id[ROLE_TRACKARTIST];
	else
	  contributor_id = cache.no_artist_id;
      }
    }
    else {
      contributor_id = psong->contributor_id[role];
    }
    break;
  case ROLE_TRACKARTIST:
    if (psong->contributor_id[ROLE_ARTIST] ||
	psong->contributor_id[ROLE_ALBUMARTIST] ||
	!psong->contributor_id[ROLE_TRACKARTIST])
      contributor_id = psong->contributor_id[role];
    break;
  default:
    contributor_id = psong->contributor_id[role];
    break;
  }
  if (contributor_id) {
    p = qstr;
    room = sizeof(qstr) - 1;
    (void) snprintf(p, room, "insert into contributor_track "
		    "(role,contributor,track) values (%d,%ld,%ld)",
		    role, contributor_id, psong->track_id);
    if ((err = _db_query(mysql, qstr, 0)))
      return err;
  }

  return 0;
}

static int
_insert_contributor(MYSQL *mysql, struct song_metadata *psong, int role)
{
  char *p;
  size_t room;
  int n, err;
  MYSQL_RES *result;
  MYSQL_ROW row;
  char *canonicalized_contributor;
  char *contributor_sort;
  char *musicbrainz_id;

  // check if record already exist
  p = qstr;
  room = sizeof(qstr) - 1;
  (void) sql_snprintf(p, room, "select id from contributors where name='%S'", psong->contributor[role]);
  if ((err = _db_query(mysql, qstr, 0)))
    return err;
  if (!(result = mysql_store_result(mysql))) {
    DPRINTF(E_DEBUG, L_DB_MYSQL, "No return result on select\n");
    return -1;
  }
  if ((mysql_num_fields(result))) {
    if ((row = mysql_fetch_row(result))) {
      // exist, get id
      psong->contributor_id[role] = atoi(row[0]);
    }
    else {
      // not exist, insert it
      if (role==ROLE_ARTIST)
	musicbrainz_id = psong->musicbrainz_artistid;
      else if (role==ROLE_ALBUMARTIST)
	musicbrainz_id = psong->musicbrainz_albumartistid;
      else
	musicbrainz_id = 0;

      canonicalized_contributor = canonicalize_name(psong->contributor[role]);

      if (psong->contributor_sort[role])
	contributor_sort = canonicalize_name(psong->contributor_sort[role]);
      else
	contributor_sort = canonicalized_contributor;

      p = qstr;
      room = sizeof(qstr) - 1;
      n = snprintf(p, room, "insert into contributors ("
		   "name,namesort,namesearch,musicbrainz_id) values ");
      p += n; room -= n;
      sql_snprintf(p, room, "('%S','%S','%S',%T)",
		   psong->contributor[role], contributor_sort, canonicalized_contributor,
		   musicbrainz_id
		   );
      if (psong->contributor_sort[role]!=contributor_sort &&
	 canonicalized_contributor!=contributor_sort)
	free(contributor_sort);
      if (psong->contributor[role]!=canonicalized_contributor)
	free(canonicalized_contributor);

      if ((err = _db_query(mysql, qstr, 0)))
	return err;
      psong->contributor_id[role] = mysql_insert_id(mysql);
    }
  }
  else {
    DPRINTF(E_INFO, L_DB_SQL, "Unexpected error\n");
    mysql_free_result(result);
    return -1;
  }

  mysql_free_result(result);

  return 0;
}

static int
_insert_tracks(MYSQL *mysql, struct song_metadata *psong)
{
  char *p;
  size_t room;
  int n, err;

  p = qstr;
  room = sizeof(qstr) - 1;
  if (psong->track_id) {
    n = snprintf(p, room, "insert into tracks (id,");
  }
  else {
    n = snprintf(p, room, "insert into tracks (");
  }
  p += n; room -= n;
  n = snprintf(p, room,
	       "url,title,titlesort,titlesearch,"
	       "album,tracknum,content_type,timestamp,filesize,"
	       "audio_size,audio_offset,year,secs,cover,"
	       "vbr_scale,bitrate,samplerate,samplesize,channels,block_alignment,"
	       "bpm,tagversion,drm,"
	       "disc,audio,remote,lossless,musicbrainz_id"
	       ") values (");
  p += n; room -= n;
  if (psong->track_id) {
    n = snprintf(p, room, "%lu,", psong->track_id);
    p += n; room -= n;
  }
  sql_snprintf(p, room, "'file://%U','%S','%S','%S',"
	       "%I,%I,'%S',%u,%u,"		// album, ...
	       "%I,%d,%d,%S,%I,"		// audio_size, ...
	       "%D,%D,%D,%I,%I,%I,"		// vbr_scale, ...
	       "%I,%T,%d,"			// bpm, ...
	       "%I,%d,%d,%d,%T)",		// disc ...
	       psong->path,			// url
	       psong->title,
	       psong->titlesort,
	       psong->titlesearch,
	       psong->album_id,			// album
	       psong->track,
	       psong->sstype,
	       (unsigned int) psong->time_modified,
	       (unsigned int) psong->file_size,
	       psong->audio_size,		// audio_size
	       psong->audio_offset,
	       psong->year,
	       _song_length_str(psong->song_length),
	       psong->image ? 1 : 0,
	       psong->vbr_scale,		// vbr_scale
	       psong->bitrate,
	       psong->samplerate,
	       psong->samplesize,
	       psong->channels,
	       psong->blockalignment,
	       psong->bpm,			// bpm
	       psong->tagversion,
	       0,
	       psong->disc,			// disc
	       1,
	       0,
	       psong->lossless,
	       psong->musicbrainz_trackid
	       );
  if ((err = _db_query(mysql, qstr, 0)))
    return err;
  psong->track_id = mysql_insert_id(mysql);
  return 0;
}

static int
_insert_comment(MYSQL *mysql, struct song_metadata *psong)
{
  char *p;
  size_t room;
  int n;

  p = qstr;
  room = sizeof(qstr) - 1;
  n = snprintf(p, room, "insert into comments (track,value) values ");
  p += n; room -= n;
  sql_snprintf(p, room, "(%d,'%S')",
	       psong->track_id, psong->comment);
  return _db_query(mysql, qstr, ER_DUP_ENTRY);
}

static int
_insert_genre(MYSQL *mysql, struct song_metadata *psong)
{
  char *p;
  size_t room;
  int n, err = 0;
  MYSQL_RES *result;
  MYSQL_ROW row;
  char *genre_str;

  if (!psong->genre || psong->genre[0]=='\0')
    genre_str = G.no_genre_str;
  else {
    genre_str = psong->genre;
    genre_str[0] = toupper(genre_str[0]);
  }

  p = qstr;
  room = sizeof(qstr) - 1;
  (void) sql_snprintf(p, room, "select id from genres where name='%S'", genre_str);
  if ((err = _db_query(mysql, qstr, 0)))
    return err;
  if (!(result = mysql_store_result(mysql))) {
    DPRINTF(E_INFO, L_DB_SQL, "Internal Error%s\n");
    return -1;
  }
  if ((mysql_num_fields(result))) {
    if ((row = mysql_fetch_row(result))) {
      // exist, get id
      psong->genre_id = atoi(row[0]);
    }
    else {
      // not exist, insert it
      char *canonicalized_genre = canonicalize_name(genre_str);
      p = qstr;
      room = sizeof(qstr) - 1;
      n = sql_snprintf(p, room, "insert into genres (name,namesort,namesearch) values");
      p += n; room -= n;
      sql_snprintf(p, room, "('%S','%S','%S')",
		   genre_str, canonicalized_genre, canonicalized_genre);
      if (canonicalized_genre != genre_str)
	free(canonicalized_genre);
      if ((err = _db_query(mysql, qstr, 0))) {
	mysql_free_result(result);
	return err;
      }
      psong->genre_id = mysql_insert_id(mysql);
    }
  }
  mysql_free_result(result);
  return 0;
}

static int
_insert_album(MYSQL *mysql, struct song_metadata *psong)
{
  char *p;
  size_t room;
  int n, err = 0;
  MYSQL_RES *result;
  MYSQL_ROW row;
  unsigned long albumartist_id;

  // cache
  if (!cache.various_artists_id) {
    if ((err = _get_various_artists(&cache.various_artists_id, mysql))) {
      return err;
    }
  }
  if (!cache.no_artist_id) {
    if ((err = _get_no_artist(&cache.no_artist_id, mysql)))
      return err;
  }

  // select albumartist
  if (psong->contributor_id[ROLE_ALBUMARTIST])
    albumartist_id = psong->contributor_id[ROLE_ALBUMARTIST];
  else if (psong->contributor_id[ROLE_ARTIST])
    albumartist_id = psong->contributor_id[ROLE_ARTIST];
  else if (psong->contributor_id[ROLE_TRACKARTIST])
    albumartist_id = psong->contributor_id[ROLE_TRACKARTIST];
  else
    albumartist_id = cache.no_artist_id;

  // check if record already exist.
  p = qstr;
  room = sizeof(qstr) - 1;
  n = sql_snprintf(p, room, "select me.id,me.compilation,me.contributor from albums me "
		   "join tracks on (me.id=tracks.album) "
		   "where me.title='%S' and tracks.url like 'file://%K/%%' and",
		   psong->album, psong->dirpath);
  p += n; room -= n;
  if (psong->disc)
    n = snprintf(p, room, " me.disc=%d and", psong->disc);
  else
    n = snprintf(p, room, " me.disc is null and");
  p += n; room -= n;
  if (psong->total_discs)
    n = snprintf(p, room, " me.discc=%d", psong->total_discs);
  else
    n = snprintf(p, room, " me.discc is null");

  if ((err = _db_query(mysql, qstr, 0)))
    return err;
  if (!(result = mysql_store_result(mysql))) {
    DPRINTF(E_INFO, L_DB_SQL, "Internal Error%s\n");
    return -1;
  }

  if ((mysql_num_fields(result))) {
    if ((row = mysql_fetch_row(result))) {
      // exist, get id
      psong->album_id = atoi(row[0]);
      // set compilation flag, if not set yet AND different contributor
      if (!safe_atoi(row[1]) &&
	  safe_atoi(row[2]) != albumartist_id) {
	if (!cache.various_artists_id) {
	  if ((err = _get_various_artists(&cache.various_artists_id, mysql))) {
	    mysql_free_result(result);
	    return err;
	  }
	}

	p = qstr;
	room = sizeof(qstr) - 1;
	(void) sql_snprintf(p, room, "update albums set compilation=1,contributor=%d where id=%d",
			    cache.various_artists_id, psong->album_id);
	if ((err = _db_query(mysql, qstr, 0))) {
	  mysql_free_result(result);
	  return err;
	}
      }
    }
    else {
      // not exist, insert it
      char *canonicalized_album;
      p = qstr;
      room = sizeof(qstr) - 1;
      n = snprintf(p, room, "insert into albums ("
		   "title,titlesort,titlesearch,"
		   "compilation,year,"
		   "disc,discc,contributor,musicbrainz_id"
		   ") values ");
      p += n; room -= n;
      canonicalized_album = canonicalize_name(psong->album);
      sql_snprintf(p, room,
		   "('%S','%S','%S',"		// album
		   "%I,%d,"			// compilation
		  " %I,%I,%d,%T)",		// disc
		   psong->album, canonicalized_album, canonicalized_album,
		   psong->compilation, psong->year,
		   psong->disc, psong->total_discs, albumartist_id, psong->musicbrainz_albumid
		   );
      if (canonicalized_album != psong->album)
	free(canonicalized_album);
      if ((err = _db_query(mysql, qstr, 0))) {
	mysql_free_result(result);
	return err;
      }
      psong->album_id = mysql_insert_id(mysql);
    }
  }
  else {
    DPRINTF(E_INFO, L_DB_SQL, "Unexpected error\n");
    mysql_free_result(result);
    return -1;
  }
  mysql_free_result(result);
  return 0;
}

static int
_get_no_album(int *id, MYSQL *mysql)
{
  char *p;
  size_t room;
  int n, err = 0;
  MYSQL_RES *result;
  MYSQL_ROW row;

  // cache
  if (!cache.no_album_canonicalized_str)
    cache.no_album_canonicalized_str = canonicalize_name(G.no_album_str);

  if (!cache.various_artists_id) {
    if ((err = _get_various_artists(&cache.various_artists_id, mysql))) {
      return err;
    }
  }

  // check if record already exist.
  p = qstr;
  room = sizeof(qstr) - 1;
  n = sql_snprintf(p, room, "select me.id,me.compilation,me.contributor from albums me "
		   "join tracks on (me.id=tracks.album) "
		   "where me.title='%S' and compilation=1 and "
		   "me.year=0 and me.disc=0 and discc=0 and contributor=%d",
		   G.no_album_str, cache.various_artists_id);

  if ((err = _db_query(mysql, qstr, 0)))
    return err;
  if (!(result = mysql_store_result(mysql))) {
    DPRINTF(E_INFO, L_DB_SQL, "Internal Error%s\n");
    return -1;
  }

  if ((mysql_num_fields(result))) {
    if ((row = mysql_fetch_row(result))) {
      // exist, get id
      *id = atoi(row[0]);
    }
    else {
      // not exist, insert it
      p = qstr;
      room = sizeof(qstr) - 1;
      n = snprintf(p, room, "insert into albums ("
		   "title,titlesort,titlesearch,"
		   "compilation,year,"
		   "disc,discc,contributor"
		   ") values ");
      p += n; room -= n;
      sql_snprintf(p, room,
		   "('%S','%S','%S',"		// album
		   "%I,%d,"			// compilation
		  " %I,%I,%d)",			// disc
		   G.no_album_str, cache.no_album_canonicalized_str, cache.no_album_canonicalized_str,
		   1, 0,
		   0, 0, cache.various_artists_id
		   );
      if ((err = _db_query(mysql, qstr, 0))) {
	mysql_free_result(result);
	return err;
      }
      *id = mysql_insert_id(mysql);
    }
  }
  else {
    DPRINTF(E_INFO, L_DB_SQL, "Unexpected error\n");
    mysql_free_result(result);
    return -1;
  }
  mysql_free_result(result);
  return 0;
}

static int
_insert_year(MYSQL *mysql, struct song_metadata *psong)
{
  snprintf(qstr, sizeof(qstr), "insert ignore into years (id) values (%d)", psong->year);
  return _db_query(mysql, qstr, 0);
}

static int
_insert_genre_track(MYSQL *mysql, struct song_metadata *psong)
{
  snprintf(qstr, sizeof(qstr), "insert into genre_track (genre,track) values"
	   "(%lu,%lu)", psong->genre_id, psong->track_id);
  return _db_query(mysql, qstr, 0);
}

static int
_get_track_id(MYSQL *mysql, struct song_metadata *psong)
{
  char *p;
  size_t room;
  int err;
  MYSQL_RES *result;
  MYSQL_ROW row;

  p = qstr;
  room = sizeof(qstr) - 1;
  (void) sql_snprintf(p, room, "select id from tracks where url='file://%U'", psong->path);
  if ((err = _db_query(mysql, qstr, 0)))
    return err;
  if (!(result = mysql_store_result(mysql))) {
    DPRINTF(E_DEBUG, L_DB_MYSQL, "No return result on select\n");
    return -1;
  }
  if ((mysql_num_fields(result))) {
    if ((row = mysql_fetch_row(result))) {
      // exist, get id
      psong->track_id = strtoul(row[0], 0, 10);
    }
  }
  mysql_free_result(result);
  return 0;
}

int
db_get_track_by_path(MYSQL *mysql, char *path, time_t *timestamp, unsigned int *filesize)
{
  char *p;
  size_t room;
  int err;
  MYSQL_RES *result;
  MYSQL_ROW row;
  int id = 0;

  p = qstr;
  room = sizeof(qstr) - 1;
  (void) sql_snprintf(p, room, "select id,timestamp,filesize from tracks where url='file://%U'", path);
  if ((err = _db_query(mysql, qstr, 0)))
    return err;
  if (!(result = mysql_store_result(mysql))) {
    DPRINTF(E_DEBUG, L_DB_MYSQL, "No return result on select\n");
    return -1;
  }
  if ((mysql_num_fields(result))) {
    if ((row = mysql_fetch_row(result))) {
      // exist, get id
      id = atoi(row[0]);
      if (timestamp)
	*timestamp = (time_t) strtoull(row[1], 0, 10);
      if (filesize)
	*filesize = (time_t) strtoull(row[2], 0, 10);
    }
  }
  mysql_free_result(result);
  return id;
}

static int
_delete_track_by_id(MYSQL *mysql, unsigned long id)
{
  char *p;
  size_t room;

  p = qstr;
  room = sizeof(qstr) - 1;
  (void) snprintf(p, room, "delete from tracks where id=%lu", id);
  if (_db_query(mysql, qstr, 0))
    return -1;

  return 0;
}

static int
_delete_album_by_id(MYSQL *mysql, unsigned long id)
{
  char *p;
  size_t room;

  p = qstr;
  room = sizeof(qstr) - 1;
  (void) snprintf(p, room, "delete from albums where id=%lu", id);
  if (_db_query(mysql, qstr, 0))
    return -1;

  return 0;
}

static int
_delete_contributors_by_id(MYSQL *mysql, unsigned long id)
{
  char *p;
  size_t room;

  p = qstr;
  room = sizeof(qstr) - 1;
  (void) snprintf(p, room, "delete from contributors where id=%lu", id);
  if (_db_query(mysql, qstr, 0))
    return -1;

  return 0;
}

static int
_delete_contributor_track_by_track(MYSQL *mysql, unsigned long track)
{
  char *p;
  size_t room;

  p = qstr;
  room = sizeof(qstr) - 1;
  (void) snprintf(p, room, "delete from contributor_track where track=%lu", track);
  if (_db_query(mysql, qstr, 0))
    return -1;

  return 0;
}

static int
_delete_contributor_album_by_album(MYSQL *mysql, unsigned long album)
{
  char *p;
  size_t room;

  p = qstr;
  room = sizeof(qstr) - 1;
  (void) snprintf(p, room, "delete from contributor_album where album=%lu", album);
  if (_db_query(mysql, qstr, 0))
    return -1;

  return 0;
}

static int
_delete_genre_track_by_track(MYSQL *mysql, unsigned long track)
{
  char *p;
  size_t room;

  p = qstr;
  room = sizeof(qstr) - 1;
  (void) snprintf(p, room, "delete from genre_track where track=%lu", track);
  if (_db_query(mysql, qstr, 0))
    return -1;

  return 0;
}

static int
_delete_comments_by_track(MYSQL *mysql, unsigned long track)
{
  char *p;
  size_t room;

  p = qstr;
  room = sizeof(qstr) - 1;
  (void) snprintf(p, room, "delete from comments where track=%lu", track);
  if (_db_query(mysql, qstr, 0))
    return -1;

  return 0;
}

static int
_delete_years_by_id(MYSQL *mysql, unsigned long id)
{
  char *p;
  size_t room;

  p = qstr;
  room = sizeof(qstr) - 1;
  (void) snprintf(p, room, "delete from years where id=%lu", id);
  if (_db_query(mysql, qstr, 0))
    return -1;

  return 0;
}

static int
_delete_genres_by_id(MYSQL *mysql, unsigned long id)
{
  char *p;
  size_t room;

  p = qstr;
  room = sizeof(qstr) - 1;
  (void) snprintf(p, room, "delete from genres where id=%lu", id);
  if (_db_query(mysql, qstr, 0))
    return -1;

  return 0;
}

int
_insertdb_song(MYSQL *mysql, struct song_metadata *psong)
{
  int role, err;
  int update = 0;

  // disable auto commit
  if ((err = mysql_autocommit(mysql, 0))) {
    DPRINTF(E_INFO, L_DB_SQL, "autocommit=0: %s\n", mysql_error(mysql));
    return err;
  }

  // years
  if ((err = _insert_year(mysql, psong)))
    return err;

  // genre
  if ((err = _insert_genre(mysql, psong)))
    return err;

  // contributors
  for (role=ROLE_START; role<=ROLE_LAST; role++) {
    if (psong->contributor[role]) {
      if ((err = _insert_contributor(mysql, psong, role)))
	return err;
    }
  }

  // albums
  if (psong->album) {
    if ((err = _insert_album(mysql, psong)))
      return err;
  }
  else {
    if (!cache.no_album_id) {
      if ((err = _get_no_album(&cache.no_album_id, mysql)))
	return err;
    }
    psong->album_id = cache.no_album_id;
  }

  // tracks
  if (!G.wipe && !_get_track_id(mysql, psong)) {
    // track exist
    _delete_track_by_id(mysql, psong->track_id);
    update = 1;
  }
  if ((err = _insert_tracks(mysql, psong)))
    return err;

  // contributor_album, contributor_track
  for (role=ROLE_START; role<=ROLE_LAST; role++) {
    if ((err =_insert_contributor_album_track(mysql, psong, role)))
      return err;
  }

  // genre_track
  if (psong->genre_id) {
    if ((err = _insert_genre_track(mysql, psong)))
      return err;
  }


  // comments
  if (psong->comment) {
    if ((err = _insert_comment(mysql, psong)))
      return err;
  }


  // --- commit ---
  if ((err = mysql_commit(mysql))) {
    DPRINTF(E_DEBUG, L_DB_MYSQL, "commit: %s\n", mysql_error(mysql));
    return err;
  }

  if (update)
    G.updated_songs++;
  else
    G.added_songs++;

  return 0;
}

static int
_insertdb_plist(MYSQL *mysql, struct song_metadata *psong)
{
  char *p;
  size_t room;
  int n, err;
  int update = 0;
  unsigned long track_id=0;

  // disable auto commit
  if ((err = mysql_autocommit(mysql, 0))) {
    DPRINTF(E_INFO, L_DB_SQL, "autocommit=0: %s\n", mysql_error(mysql));
    return -1;
  }

  // track
  if (!G.wipe && !_get_track_id(mysql, psong)) {
    // track exist. (track is playlist, 'ssp')
    _delete_track_by_id(mysql, psong->track_id);
    update = 1;
  }
  p = qstr;
  room = sizeof(qstr) - 1;
  if (update) {
    n = snprintf(p, room, "insert into tracks (id,");
  }
  else {
    n = snprintf(p, room, "insert into tracks (");
  }
  p += n; room -= n;
  n = snprintf(p, room,
	       "url,title,titlesort,titlesearch,"
	       "content_type,timestamp,filesize,"
	       "remote,musicmagic_mixable"
	       ") values (");
  p += n; room -= n;
  if (update) {
    n = snprintf(p, room, "%lu,", track_id);
    p += n; room -= n;
  }
  sql_snprintf(p, room,
	       "'file://%U','%S','%S','%S',"	// url, ...
	       "'%S',%u,%d,"			// content_type, ...
	       "%d,%d"				// remote
	       ")",
	       psong->path,			// url
	       psong->title,
	       psong->titlesort,
	       psong->titlesearch,
	       "ssp",				// content_type
	       psong->time_modified,
	       psong->file_size,
	       0,				// remote
	       1
	       );
  if ((err = _db_query(mysql, qstr, 0))) {
    return -1;
  }
  track_id = mysql_insert_id(mysql);

  // --- commit ---
  if ((err = mysql_commit(mysql))) {
    DPRINTF(E_DEBUG, L_DB_MYSQL, "commit: %s\n", mysql_error(mysql));
    return -1;
  }

  psong->plist_id = track_id;

  return 0;
}

int
_insertdb_plist_item(MYSQL *mysql, struct song_metadata *psong)
{
  int err;

  // disable auto commit
  if ((err = mysql_autocommit(mysql, 0))) {
    DPRINTF(E_INFO, L_DB_SQL, "autocommit=0: %s\n", mysql_error(mysql));
    return err;
  }

  // tracks
  if (_get_track_id(mysql, psong)) {
    // track not exist, then insert it
    if ((err = _insert_tracks(mysql, psong)))
      return err;
    psong->track_id = mysql_insert_id(mysql);
  }

  // playlist_track
  snprintf(qstr, sizeof(qstr),
	   "insert into playlist_track (position,playlist,track) "
	   "values (%d,%d,%lu)",
	   psong->plist_position, psong->plist_id, psong->track_id);
  if ((err = _db_query(mysql, qstr, 0)))
    return err;

  // --- commit ---
  if ((err = mysql_commit(mysql))) {
    DPRINTF(E_DEBUG, L_DB_MYSQL, "commit: %s\n", mysql_error(mysql));
    return err;
  }

  return 0;
}

int
db_set_lastrescantime(MYSQL *mysql)
{
  char *p;
  size_t room;
  int err;

  // delete
  p = qstr;
  room = sizeof(qstr) - 1;
  (void) sql_snprintf(p, room, "delete from metainformation where name='lastRescanTime'");
  if ((err = _db_query(mysql, qstr, 0)))
    return err;

  // then insert
  p = qstr;
  room = sizeof(qstr) - 1;
  (void) snprintf(p, room, "insert into metainformation (name,value) values "
		  "('lastRescanTime','%llu')", (unsigned long long) time(0));
  if ((err = _db_query(mysql, qstr, 0)))
    return err;

  // commit
  if ((err = mysql_commit(mysql))) {
    DPRINTF(E_DEBUG, L_DB_MYSQL, "commit: %s\n", mysql_error(mysql));
    return err;
  }

  return 0;
}

int
db_get_lastrescantime(MYSQL *mysql, time_t *lastrescantime)
{
  char *p;
  size_t room;
  int err;
  MYSQL_RES *result;
  MYSQL_ROW row;

  *lastrescantime = 0;

  // delete
  p = qstr;
  room = sizeof(qstr) - 1;
  (void) sql_snprintf(p, room, "select value from metainformation where name='lastRescanTime'");
  if ((err = _db_query(mysql, qstr, 0)))
    return err;
  if (!(result = mysql_store_result(mysql))) {
    DPRINTF(E_DEBUG, L_DB_MYSQL, "No return result on select\n");
    return -1;
  }
  if ((mysql_num_fields(result))) {
    if ((row = mysql_fetch_row(result))) {
      // exist, get it
      *lastrescantime = strtoul(row[0], 0, 10);
    }
  }
  mysql_free_result(result);

  return 0;
}

int
db_set_scanning(MYSQL *mysql, int f)
{
  char *p;
  size_t room;
  int err;

  // delete
  p = qstr;
  room = sizeof(qstr) - 1;
  (void) sql_snprintf(p, room, "delete from metainformation where name='isScanning'");
  if ((err = _db_query(mysql, qstr, 0)))
    return err;

  // then insert
  p = qstr;
  room = sizeof(qstr) - 1;
  (void) snprintf(p, room, "insert into metainformation (name,value) values "
		  "('isScanning','%d')", f);
  if ((err = _db_query(mysql, qstr, 0)))
    return err;

  // commit
  if ((err = mysql_commit(mysql))) {
    DPRINTF(E_DEBUG, L_DB_MYSQL, "commit: %s\n", mysql_error(mysql));
    return err;
  }

  return 0;
}

int
db_set_progress(MYSQL *mysql, enum _progress_event event, int what, char *info)
{
  char *p;
  size_t room;
  int err, n;
  char name[PROGRESS_NR][16] = {
    "directory",
    "playlist",
    "artwork"
  };

  if (what<0 || what>=PROGRESS_NR)
    return -1;

  if (G.progress_total[what]<G.progress_done[what])
    G.progress_total[what] = G.progress_done[what];

  switch (event) {
  case PROGRESS_START:
  case PROGRESS_DELETE:
    // delete
    p = qstr;
    room = sizeof(qstr) - 1;
    (void) snprintf(p, room, "delete from progress where name='%s'", name[what]);
    if ((err = _db_query(mysql, qstr, 0)))
      return err;
    if (event==PROGRESS_DELETE)
      return 0;
    // then insert
    p = qstr;
    room = sizeof(qstr) - 1;
    n = snprintf(p, room, "insert into progress (type,name,active,total,done,start,finish,info) values ");
    p += n; room -= n;
    n = snprintf(p, room, "('importer','%s',1,%lu,%lu,%llu,NULL,NULL)",
		 name[what], G.progress_total[what], G.progress_done[what],
		 (long long unsigned int) time(0));
    if ((err = _db_query(mysql, qstr, 0)))
      return err;
    break;

  case PROGRESS_UPDATE:
    p = qstr;
    room = sizeof(qstr) - 1;
    n = sql_snprintf(p, room,
		     "update progress SET active=1,total=%lu,done=%lu,info='%S' "
		     "where name='%s'",
		     G.progress_total[what], G.progress_done[what], info ? info : "",
		     name[what]);
    if ((err = _db_query(mysql, qstr, 0)))
      return err;
    break;

  case PROGRESS_FINISH:
    p = qstr;
    room = sizeof(qstr) - 1;
    n = snprintf(p, room,
		 "update progress SET active=0,total=%lu,done=%lu,finish=%llu,info=NULL "
		 "where name='%s'",
		 G.progress_total[what], G.progress_done[what],
		 (long long unsigned int) time(0),
		 name[what]);
    if ((err = _db_query(mysql, qstr, 0)))
      return err;
    break;

  case PROGRESS_ALL:
    p = qstr;
    room = sizeof(qstr) - 1;
    n = snprintf(p, room, "insert into progress (type,name,active,total,done,start,finish,info) values ");
    p += n; room -= n;
    n = snprintf(p, room, "('importer','%s',0,%lu,%lu,%llu,%llu,NULL)",
		 name[what], G.progress_total[what], G.progress_done[what],
		 G.progress_start[what], G.progress_finish[what]);
    if ((err = _db_query(mysql, qstr, 0)))
      return err;
    break;

  default:
    return -1;
  }

  // commit
  if ((err = mysql_commit(mysql))) {
    DPRINTF(E_DEBUG, L_DB_MYSQL, "commit: %s\n", mysql_error(mysql));
    return err;
  }

  return 0;
}

int
db_get_scanning(MYSQL *mysql, int *scanning)
{
  char *p;
  size_t room;
  int err;
  MYSQL_RES *result;
  MYSQL_ROW row;

  *scanning = 0;

  // delete
  p = qstr;
  room = sizeof(qstr) - 1;
  (void) sql_snprintf(p, room, "select value from metainformation where name='scanning'");
  if ((err = _db_query(mysql, qstr, 0)))
    return err;
  if (!(result = mysql_store_result(mysql))) {
    DPRINTF(E_DEBUG, L_DB_MYSQL, "No return result on select\n");
    return -1;
  }
  if ((mysql_num_fields(result))) {
    if ((row = mysql_fetch_row(result))) {
      // exist, get ii
      *scanning = atoi(row[0]);
    }
  }
  mysql_free_result(result);

  return 0;
}

char *tables[] = {
  "tracks",
  "playlist_track",
  "albums",
  "years",
  "contributors",
  "contributor_track",
  "contributor_album",
  "genres",
  "genre_track",
  "comments",
  "pluginversion",
  "unreadable_tracks",
  0
};

int
db_wipe(MYSQL *mysql)
{
  int err;
  int i;

  // enable auto commit
  if ((err = mysql_autocommit(mysql, 1))) {
    DPRINTF(E_INFO, L_DB_SQL, "autocommit=1: %s\n", mysql_error(mysql));
    return err;
  }

  _db_query(mysql, "set foreign_key_checks = 0", 0);
  for (i=0; tables[i]; i++) {
    (void) snprintf(qstr, sizeof(qstr), "delete from %s", tables[i]);
    _db_query(mysql, qstr, 0);
    (void) snprintf(qstr, sizeof(qstr), "alter table %s AUTO_INCREMENT=1", tables[i]);
    _db_query(mysql, qstr, 0);
  }
  _db_query(mysql, "update metainformation set value = 0 where name = 'lastRescanTime'", 0);
  _db_query(mysql, "set foreign_key_checks = 1", 0);


  if (0) {
    for (i=0; tables[i]; i++) {
      (void) snprintf(qstr, sizeof(qstr), "optimize table %s", tables[i]);
      _db_query(mysql, qstr, 0);
    }
  }

  return 0;
}

// Find deleted tracks
int
db_sync(MYSQL *mysql)
{
  int err;
  MYSQL_RES *result;
  MYSQL_ROW row;
  int id;
  char *url, *title, *name;
  struct stat stat;

  // disable auto commit
  if ((err = mysql_autocommit(mysql, 0))) {
    DPRINTF(E_INFO, L_DB_SQL, "autocommit=0: %s\n", mysql_error(mysql));
    return err;
  }

  // Clean  'tracks' table, 'genre_track', 'contributor_track', 'comment'
  // find all tracks
  (void) snprintf(qstr, sizeof(qstr), "SELECT id,url FROM tracks");
  if ((err = _db_query(mysql, qstr, 0)))
    return err;
  if (!(result = mysql_store_result(mysql))) {
    DPRINTF(E_DEBUG, L_DB_MYSQL, "No return result on select in db_sync()\n");
    return -1;
  }
  if (!(mysql_num_fields(result))) {
    DPRINTF(E_DEBUG, L_DB_MYSQL, "Unexpected error in db_sync()\n");
    mysql_free_result(result);
    return -1;
  }
  while ((row = mysql_fetch_row(result))) {	// loop for all tracks
    id = atoi(row[0]);
    url = row[1];
    urldecode(url);
    if (!strncmp(url, "file:///", 8)) {
      if (lstat(url+7, &stat) == -1) {
	_delete_track_by_id(mysql, id);
	_delete_genre_track_by_track(mysql, id);
	_delete_contributor_track_by_track(mysql, id);
	_delete_comments_by_track(mysql, id);
	DPRINTF(E_INFO, L_DB_INFO, "Deleted track %d:%s\n", id, url);
      }
    }
  }
  mysql_free_result(result);

  // Clean  'albums' table, 'contributor_album'
  // Find tracks which does not have any tracks, and then delete it
  (void) snprintf(qstr, sizeof(qstr),
		  "SELECT albums.id,albums.title FROM albums "
		  "left join tracks on tracks.album=albums.id "
		  "where tracks.album is NULL");
  if ((err = _db_query(mysql, qstr, 0)))
    return err;
  if (!(result = mysql_store_result(mysql))) {
    DPRINTF(E_DEBUG, L_DB_MYSQL, "No return result on select in db_sync()\n");
    return -1;
  }
  if (!(mysql_num_fields(result))) {
    DPRINTF(E_DEBUG, L_DB_MYSQL, "Unexpected error in db_sync()\n");
    mysql_free_result(result);
    return -1;
  }
  while ((row = mysql_fetch_row(result))) {	// loop for all album, which does not have track
    id = atoi(row[0]);
    title = row[1];
    _delete_album_by_id(mysql, id);
    _delete_contributor_album_by_album(mysql, id);
    DPRINTF(E_INFO, L_DB_INFO, "Deleted album %d:%s\n", id, title);
  }
  mysql_free_result(result);

  // Clean  'contributors' table
  (void) snprintf(qstr, sizeof(qstr),
		  "SELECT t1.id,t1.name from contributors t1 WHERE "
		  "NOT EXISTS (SELECT * FROM contributor_track t2 WHERE t2.contributor=t1.id) AND "
		  "NOT EXISTS (SELECT * FROM contributor_album t3 WHERE t3.contributor=t1.id) AND "
		  "NOT EXISTS (SELECT * FROM albums t4 WHERE t4.contributor=t1.id)");
  if ((err = _db_query(mysql, qstr, 0)))
    return err;
  if (!(result = mysql_store_result(mysql))) {
    DPRINTF(E_DEBUG, L_DB_MYSQL, "No return result on select in db_sync()\n");
    return -1;
  }
  if (!(mysql_num_fields(result))) {
    DPRINTF(E_DEBUG, L_DB_MYSQL, "Unexpected error in db_sync()\n");
    mysql_free_result(result);
    return -1;
  }
  while ((row = mysql_fetch_row(result))) {	// loop for contributors to be deleted
    id = atoi(row[0]);
    name = row[1];
    _delete_contributors_by_id(mysql, id);
    DPRINTF(E_INFO, L_DB_INFO, "Deleted contributor %d:%s\n", id, name);
  }
  mysql_free_result(result);

  // Clean  'years' table
  (void) snprintf(qstr, sizeof(qstr),
		  "SELECT t1.id from years t1 WHERE "
		  "NOT EXISTS (SELECT * FROM tracks t2 WHERE t2.year=t1.id) AND "
		  "NOT EXISTS (SELECT * FROM albums t3 WHERE t3.year=t1.id)");
  if ((err = _db_query(mysql, qstr, 0)))
    return err;
  if (!(result = mysql_store_result(mysql))) {
    DPRINTF(E_DEBUG, L_DB_MYSQL, "No return result on select in db_sync()\n");
    return -1;
  }
  if (!(mysql_num_fields(result))) {
    DPRINTF(E_DEBUG, L_DB_MYSQL, "Unexpected error in db_sync()\n");
    mysql_free_result(result);
    return -1;
  }
  while ((row = mysql_fetch_row(result))) {	// loop for contributors to be deleted
    id = atoi(row[0]);
    _delete_years_by_id(mysql, id);
    DPRINTF(E_INFO, L_DB_INFO, "Deleted year %d\n", id);
  }
  mysql_free_result(result);

  // Clean  'genres' table
  (void) snprintf(qstr, sizeof(qstr),
		  "SELECT t1.id,t1.name from genres t1 WHERE "
		  "NOT EXISTS (SELECT * FROM genre_track t2 WHERE t2.genre=t1.id)");
  if ((err = _db_query(mysql, qstr, 0)))
    return err;
  if (!(result = mysql_store_result(mysql))) {
    DPRINTF(E_DEBUG, L_DB_MYSQL, "No return result on select in db_sync()\n");
    return -1;
  }
  if (!(mysql_num_fields(result))) {
    DPRINTF(E_DEBUG, L_DB_MYSQL, "Unexpected error in db_sync()\n");
    mysql_free_result(result);
    return -1;
  }
  while ((row = mysql_fetch_row(result))) {	// loop for contributors to be deleted
    id = atoi(row[0]);
    name = row[1];
    _delete_genres_by_id(mysql, id);
    DPRINTF(E_INFO, L_DB_INFO, "Deleted genre %d:%s\n", id, name);
  }
  mysql_free_result(result);

  // commit
  if ((err = mysql_commit(mysql))) {
    DPRINTF(E_DEBUG, L_DB_MYSQL, "commit: %s\n", mysql_error(mysql));
    return err;
  }

  return 0;
}



int
db_merge_artists_albums(MYSQL *mysql)
{
  return 0;
}

int
db_find_artworks(MYSQL *mysql)
{
  int err;
  MYSQL_RES *result;
  MYSQL_ROW row;
  int album_id;
  int track_id;
  char *cover_file;
  char *track_url;

  // disable auto commit
  if ((err = mysql_autocommit(mysql, 0))) {
    DPRINTF(E_INFO, L_DB_SQL, "autocommit=0: %s\n", mysql_error(mysql));
    return err;
  }

  // find album without artwork
  if (0) {
    (void) snprintf(qstr, sizeof(qstr),
		    "SELECT me.id,cover,albums.id,url FROM tracks me"
		    " JOIN albums ON (albums.id = me.album)"
		    " WHERE (me.audio=1 and me.timestamp>=%llu and"
		    " albums.artwork IS NULL"
		    ") GROUP BY album",
		    (unsigned long long) G.lastrescantime);
  }
  else {
    (void) snprintf(qstr, sizeof(qstr),
		    "SELECT t_id,t_cover,t_album,t_url FROM ("
		    "SELECT me.id as t_id,cover as t_cover,album as t_album,url as t_url "
		    "FROM tracks me join albums on (albums.id = me.album)"
		    " WHERE (me.audio=1 and me.timestamp>=%llu and"
		    " albums.artwork IS NULL"
		    ") ORDER BY tracknum) as t group by t_album",
		    (unsigned long long) G.lastrescantime);
  }

  if ((err = _db_query(mysql, qstr, 0)))
    return err;
  if (!(result = mysql_store_result(mysql))) {
    DPRINTF(E_DEBUG, L_DB_MYSQL, "No return result on select in db_find_artworks()\n");
    return -1;
  }
  if (!(mysql_num_fields(result))) {
    DPRINTF(E_DEBUG, L_DB_MYSQL, "Unexpected error in db_find_artworks()\n");
    mysql_free_result(result);
    return -1;
  }
  while ((row = mysql_fetch_row(result))) {
    track_id = atoi(row[0]);
    cover_file = row[1];
    album_id = atoi(row[2]);
    track_url = row[3];
    if (cover_file) {
      (void) snprintf(qstr, sizeof(qstr),
		      "UPDATE albums set artwork=%d WHERE id=%d", track_id, album_id);
      if ((err = _db_query(mysql, qstr, 0))) {
	mysql_free_result(result);
	return -1;
      }
    }
    else {
      if ((cover_file = artwork_find_file(track_url))) {
	(void) sql_snprintf(qstr, sizeof(qstr),
			   "UPDATE tracks set cover='%S' WHERE id=%d", cover_file, track_id);
	if ((err = _db_query(mysql, qstr, 0))) {
	  free(cover_file);
	  mysql_free_result(result);
	  return -1;
	}
	(void) snprintf(qstr, sizeof(qstr),
			"UPDATE albums set artwork=%d WHERE id=%d", track_id, album_id);
	if ((err = _db_query(mysql, qstr, 0))) {
	  free(cover_file);
	  mysql_free_result(result);
	  return -1;
	}

	// cache
	if (create_coverart_cache(track_id, cover_file)) {
	  DPRINTF(E_ERROR, L_DB_INFO, "Cannot create cache for %s\n", cover_file);
	}
	else {
	  DPRINTF(E_INFO, L_DB_INFO, "Created cache for %s\n", cover_file);
	}

	free(cover_file);
      }
    }

    // update progress
    G.progress_done[PROGRESS_ARTWORK]++;
    if (G.show_progress && (G.progress_done[PROGRESS_ARTWORK]&PROGRESS_MASK)==PROGRESS_MASK)
      db_set_progress(mysql, PROGRESS_UPDATE, PROGRESS_ARTWORK, cover_file);

  }

  mysql_free_result(result);

  // commit
  if ((err = mysql_commit(mysql))) {
    DPRINTF(E_DEBUG, L_DB_MYSQL, "commit: %s\n", mysql_error(mysql));
    return err;
  }

  return 0;
}

int
insertdb(MYSQL *mysql, struct song_metadata *psong)
{
  if (psong->is_plist) {
    if (psong->plist_position) {
      return _insertdb_plist_item(mysql, psong);
    }
    else {
      return _insertdb_plist(mysql, psong);
    }
  }
  return _insertdb_song(mysql, psong);
}
