//=========================================================================
// FILENAME	: scanner.c
// DESCRIPTION	: Main program for scanner
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

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <sys/stat.h>
#include <mysql/mysql.h>
#include <dirent.h>
#include <limits.h>
#include <unistd.h>
#include <time.h>

#include "misc.h"
#include "scanner.h"
#include "tagutils.h"
#include "artwork.h"
#include "textutils.h"
#include "db.h"
#include "log.h"
#include "prefs.h"

char *compiled_on = __DATE__ ", " __TIME__ ;

char *progname;
struct _defval {
  char *dbname;
  char *prefsdir;
  char *prefsfile;
  char *logdir;
  char *logfile;
  char *cachedir;
  char *strings;
  char *no_genre_str;
  char *no_album_str;
  char *no_title_str;
  char *no_artist_str;
  char *variousartists_str;
} defval  = {
  "slimserver",
  "/var/lib/squeezecenter/prefs",
  "server.prefs",
  "/var/log/squeezecenter",
  "scanner.log",
  "/var/lib/squeezecenter/cache",
  "/usr/share/squeezecenter/strings.txt",
  "No Genre",
  "No Album",
  "No Title",
  "No Artist",
  "Various Artists"
};

struct _types {
  char *type;
  char *sstype;
  char *suffix[7];
};
struct _importers {
  char name[8];
  char *dir;
  struct _types *types;
  void (*importer)(char*, char*, struct stat*, char*, struct _types*, MYSQL*);
  int progress_id;
};


// Prototype
static void audio_import(char*, char*, struct stat*, char*, struct _types*, MYSQL*);
static void plist_import(char*, char*, struct stat*, char*, struct _types*, MYSQL*);
static int scan_directory(char *dirpath, char *lang, MYSQL *mysql, struct _importers*);
static void usage(void);

// Global
struct _g G = {
  .wipe = 0,
  .show_progress = 1,				// TBD
  .lastrescantime = 0,

  .progress_total = {0,},
  .progress_done = {0,},

  .skipped_songs = 0,
  .added_songs = 0,
  .deleted_songs = 0,

  .no_genre_str = 0,
  .no_album_str = 0,
  .no_title_str = 0,
  .no_artist_str = 0,
  .variousartists_str = 0
};

static void
usage(void) {
  printf("Usage: %s [options] directory_path\n", progname);
  printf("  --help            ... help message\n");
  printf("  --dbname=name     ... database name [default=%s]\n", defval.dbname);
  printf("  --prefsfile=name  ... preference file [default = %s]\n", defval.prefsfile);
  printf("  --prefsdir=name   ... preference file directry [default = %s]\n", defval.prefsdir);
  printf("  --wipe            ... wipe before scan\n");
  printf("  --debug dbgarg    ... set debug flag (dbgarg = facility[,facility]...=level)\n");
  printf("\n");
  printf("  Example:\n");
  printf("    %s\\\n", progname);
  printf("      --prefsdir=/var/lib/squeezecenter/prefs\\\n");
  printf("      --logdir=/var/log/squeezecenter/\\\n");
  printf("      --wipe\\\n");
  printf("      --debug artwork,scan,scan.scanner,scan.import=debug\\\n");
  printf("      /c/media/Music\n");
  exit(-1);
}

enum _opttype {
  OPT_NOT_IMPLEMENTED = 0,
  OPT_HELP,
  OPT_WIPE,
  OPT_PREFSDIR,
  OPT_PREFSFILE,
  OPT_PROGRESS,
  OPT_LOGDIR,
  OPT_LOGFILE,
  OPT_DBNAME,
  OPT_DEBUG,

  OPT_UNKNOWN,
  OPT_MALFORMED,
  OPT_NOT_OPTION
};

struct _opt {
  int len;
  char name[16];
  enum _opttype opt;
  int f_arg;
} options[] = {
  {5, "force", OPT_NOT_IMPLEMENTED, 0},
  {7, "cleanup", OPT_NOT_IMPLEMENTED, 0},
  {6, "rescan", OPT_NOT_IMPLEMENTED, 0},
  {4, "wipe", OPT_WIPE, 0},
  {8, "playlist", OPT_NOT_IMPLEMENTED, 0},
  {6, "itunes", OPT_NOT_IMPLEMENTED, 0},
  {10, "musicmagic", OPT_NOT_IMPLEMENTED, 0},
  {9, "prefsfile", OPT_PREFSFILE, 1},
  {8, "prefsdir", OPT_PREFSDIR, 1},
  {7, "logfile", OPT_LOGFILE, 1},
  {6, "logdir", OPT_LOGDIR, 1},
  {8, "progress", OPT_PROGRESS, 0},
  {8, "priority", OPT_NOT_IMPLEMENTED, 1},
  {9, "logconfig", OPT_NOT_IMPLEMENTED, 1},
  {5, "debug", OPT_DEBUG, 1},
  {5, "quiet", OPT_NOT_IMPLEMENTED, 0},

  {4, "help", OPT_HELP, 0},
  {6, "dbname", OPT_DBNAME, 1},
  {0, "", 0, 0}
};

static int
find_opt(int argc, char **argv, struct _opt *options, int *pos, enum _opttype *opt, char **optargp)
{
  int i;
  char c;

  *optargp = 0;

  (*pos)++;
  if (*pos >= argc)
    return 0;

  if (argv[*pos][0]=='-' && argv[*pos][1]=='-') {
    for (i=0; options[i].len; i++) {
      if (!strncmp(options[i].name, argv[*pos]+2, options[i].len)) {
	c = argv[*pos][2+options[i].len];
	if (options[i].f_arg && (c != '=' && c != '\0')) {
	  *opt = OPT_MALFORMED;
	  return 1;
	}
	*opt = options[i].opt;
	if (!options[i].f_arg)
	  return 1;
	if (c == '=')
	  *optargp = argv[*pos] + 3 + options[i].len;
	else
	  *optargp = argv[++(*pos)];
	return 1;
      }
    }
    *opt = OPT_UNKNOWN;
  }
  else {
    *opt = OPT_NOT_OPTION;
  }

  return 1;
}


struct _types audio_types[] = {
  // audio
  {"aac", "mov", {"mp4", "mp4", "m4a", "m4p", 0}},
  {"mp3", "mp3", {"mp3", "mp2", 0}},
  {"ogg", "ogg", {"ogg", "oga", 0}},
  {"flc", "flc", {"flc", "flac", "fla", 0}},
  {"asf", "wma", {"wma", 0}},
   // sentinel
  {0, 0, {0}}
};
struct _types plist_types[] = {
  // playlist
  {"m3u", "ssp", {"m3u", 0}},
  {"pls", "ssp", {"pls", 0}},
   // sentinel
  {0, 0, {0}}
};

struct _importers importers[] = {
  {"audio", 0, audio_types, audio_import, PROGRESS_DIRECTORY},
  {"plist", 0, plist_types, plist_import, PROGRESS_PLAYLIST},
  {"", 0, 0, 0}
};

static int
check_if_can_skip(MYSQL *mysql, char *path, struct stat *stat)
{
  time_t timestamp;
  unsigned int filesize;
  int id;

  id = db_get_track_by_path(mysql, path, &timestamp, &filesize);
  if ((id > 0) && (timestamp == stat->st_mtime) && (filesize == stat->st_size))
    return id;

  return 0;
}

static void
audio_import(char *dirpath, char *path, struct stat *stat, char *lang, struct _types *types, MYSQL *mysql)
{
  struct song_metadata song;
  int id;

  if (!G.wipe &&
      ((id = check_if_can_skip(mysql, path, stat)))) {
    DPRINTF(E_INFO, L_SCAN, "Skip %d:<%s> for scan\n", id, path);
    G.skipped_songs++;
    return;
  }

  if (readtags(path, &song, stat, lang, types->type)) {
    DPRINTF(E_WARN, L_SCAN, "Cannot extract tags from %s\n", path);
  }
  else {
    song.sstype = types->sstype;
    song.dirpath = dirpath;
    insertdb(mysql, &song);
    if (song.image) {
      DPRINTF(E_INFO, L_SCAN, "Cache embedded image in track %s\n", path);
      artwork_cache_embedded_image(&song);
    }
  }
  freetags(&song);
}

static void
plist_import(char *dirpath, char *path, struct stat *stat, char *lang, struct _types *types, MYSQL *mysql)
{
  struct song_metadata song;
  int playlist_id = 0;
  int position;
  int id;

  if (!G.wipe &&
      ((id = check_if_can_skip(mysql, path, stat)))) {
    DPRINTF(E_INFO, L_SCAN, "Skip %d:<%s> for scan\n", id, path);
    return;
  }

  // playlist
  if (start_plist(path, &song, stat, lang, types->type)) {
    DPRINTF(E_ERROR, L_SCAN, "Cannot scan playlist <%s>\n", path);
    return;
  }

  song.dirpath = dirpath;
  if (insertdb(mysql, &song)) {
    freetags(&song);
    return;
  }
  playlist_id = song.plist_id;

  // playlist items
  if (0) {
    position = 0;
    while (!next_plist_track(&song, stat, lang, types->type)) {
      position++;
      song.sstype = types->sstype;
      song.is_plist = 1;
      song.plist_id = playlist_id;
      song.plist_position = position;
      song.dirpath = dirpath;
      insertdb(mysql, &song);
      freetags(&song);
    }
  }
  return;
}

static int
scan_directory(char *dirpath, char *lang, MYSQL *mysql, struct _importers *importer)
{
  DIR *dir;
  int typeindex;
  char *path;
  struct dirent *dp;
  struct stat stat;

  if (!(dir = opendir(dirpath))) {
    return -1;
  }
  while ((dp = readdir(dir))) {
    if (!strcmp(dp->d_name, ".") || !strcmp(dp->d_name, "..") ||
	!strncmp(dp->d_name, "._", 2) || !strcmp(dp->d_name, ".AppleDouble"))
      continue;

    path = calloc(strlen(dirpath) + strlen(dp->d_name) + 2, sizeof(char));
    sprintf(path, "%s/%s", dirpath, dp->d_name);
    if (lstat(path, &stat) == -1) {
      DPRINTF(E_ERROR, L_SCAN, "%s on lstat(%s)\n", strerror(errno), path)
      free(path);
      closedir(dir);
      return -1;
    }
    if (stat.st_mode & S_IFDIR) {
      // descending
      scan_directory(path, lang, mysql, &(importers[0]));
    }
    else {
      int i, j;
      char *suffix = strrchr(path, '.');
      if (!suffix) {
	free(path);
	continue;
      }
      suffix++;
      typeindex = -1;
      for (i=0; typeindex==-1 && importer->types[i].type; i++) {
	for (j=0; typeindex==-1 && importer->types[i].suffix[j]; j++) {
	  if (!strcasecmp(importer->types[i].suffix[j], suffix)) {
	    typeindex = i;
	    break;
	  }
	}
      }
      if (typeindex>=0) {
	if (mysql) {
	  importer->importer(dirpath, path, &stat, lang, &(importer->types[typeindex]), mysql);
	  // update progress
	  G.progress_done[importer->progress_id]++;
	  if (G.show_progress &&
	      (G.progress_done[importer->progress_id]&PROGRESS_MASK)==PROGRESS_MASK)
	    db_set_progress(mysql, PROGRESS_UPDATE, importer->progress_id, path);
	}
	else {
	  // dry run
	  G.progress_total[importer->progress_id]++;
	}
      }
    }
    free(path);
  }
  closedir(dir);
  return 0;
}

static int
rmtree(char *dirpath)
{
  DIR *dir;
  char *path;
  struct dirent *dp;
  struct stat stat;

  if (!(dir = opendir(dirpath))) {
    return -1;
  }
  while ((dp = readdir(dir))) {
    if (!strcmp(dp->d_name, ".") || !strcmp(dp->d_name, ".."))
      continue;

    path = calloc(strlen(dirpath) + strlen(dp->d_name) + 2, sizeof(char));
    sprintf(path, "%s/%s", dirpath, dp->d_name);
    if (lstat(path, &stat) == -1) {
      DPRINTF(E_ERROR, L_SCAN, "%s on lstat(%s)\n", strerror(errno), path)
      free(path);
      closedir(dir);
      return -1;
    }
    if (stat.st_mode & S_IFDIR) {
      // descending
      rmtree(path);
    }
    else {
      unlink(path);
    }
    free(path);
  }
  closedir(dir);
  rmdir(dirpath);
  return 0;
}

int
main(int argc, char **argv) {
  //
  int err = 0;
  int i;
  int pos;
  enum _opttype opt;
  char *optarg = NULL;
  char *dbname = NULL;
  char *prefsfile = NULL, *prefsdir = NULL;
  char *logfile = NULL, *logdir = NULL, *debug = NULL;
  char *audiodir = NULL;
  char *playlistdir = NULL;
  int scanning;
  // mysql related
  MYSQL mysql;

  // log init for command line argument pursing
  log_init(NULL, NULL);

  progname = argv[0];
  pos = 0;
  while ((find_opt(argc, argv, options, &pos, &opt, &optarg))) {
    switch (opt) {
    case OPT_HELP:
      usage();
      break;
    case OPT_NOT_OPTION:
      audiodir = argv[pos];
      break;
    case OPT_DBNAME:
      dbname = optarg;
      break;
    case OPT_PREFSFILE:
      prefsfile = optarg;
      break;
    case OPT_PREFSDIR:
      prefsdir = optarg;
      break;
    case OPT_PROGRESS:
      G.show_progress = 1;
      break;
    case OPT_LOGFILE:
      logfile = optarg;
      break;
    case OPT_LOGDIR:
      logdir = optarg;
      break;
    case OPT_WIPE:
      G.wipe = 1;
      break;
    case OPT_DEBUG:
      debug = optarg;
      break;

    case OPT_UNKNOWN:
      DPRINTF(E_FATAL, L_SCAN, "Unknown otion %s.\n", argv[pos]);
      err = 1;
      goto exit0;
    case OPT_MALFORMED:
      DPRINTF(E_FATAL, L_SCAN, "Malformed option %s\n", argv[pos]);
      err = 1;
      goto exit0;
    case OPT_NOT_IMPLEMENTED:
      break;

    default:
      DPRINTF(E_FATAL, L_SCAN, "Internal error\n");
      usage();
    }
  }

  // logfile
  if (logfile || logdir) {
    int err;
    char *logfile_path = malloc(PATH_MAX);
    if (!(logfile_path)) {
      DPRINTF(E_FATAL, L_SCAN, "Out of memory\n");
      usage();
    }
    snprintf(logfile_path, PATH_MAX, "%s/%s",
	     logdir ? logdir : defval.logdir,
	     logfile ? logfile : defval.logfile);
    err = log_init(logfile_path, debug);
    free(logfile_path);
  }
  else {
    (void) log_init(NULL, debug);
  }

  // Greeting
  DPRINTF(E_OFF, L_SCAN, "Start scanner (compiled on %s)...\n", compiled_on);

  // prefsfile
  if (prefsfile && prefsfile[0]=='/') {
    read_prefs(prefsfile);
  }
  else {
    char *prefsfile_path = malloc(PATH_MAX);
    if (!(prefsfile_path))
      DPRINTF(E_FATAL, L_SCAN, "Out of memory\n");
    snprintf(prefsfile_path, PATH_MAX, "%s/%s",
	     prefsdir ? prefsdir : defval.prefsdir,
	     prefsfile ? prefsfile : defval.prefsfile);
    read_prefs(prefsfile_path);
    free(prefsfile_path);
  }

  if (!audiodir) {
    if (prefs.audiodir) {
      audiodir = prefs.audiodir;
    }
    else {
      DPRINTF(E_FATAL, L_SCAN, "audiodir need to be specified\n");
      usage();
    }
  }

  if (!playlistdir) {
    if (prefs.playlistdir) {
      playlistdir = prefs.playlistdir;
    }
    else {
      DPRINTF(E_INFO, L_SCAN, "playlistdir need to be specified\n");
    }
  }

  if (!prefs.cachedir)
    prefs.cachedir = defval.cachedir;

  if (!dbname)
    dbname = defval.dbname;

  // Read string
  fetch_string_txt(defval.strings, prefs.language, 5,
		   "NO_GENRE", &G.no_genre_str, defval.no_genre_str,
		   "NO_ALBUM", &G.no_album_str, defval.no_album_str,
		   "NO_TITLE", &G.no_title_str, defval.no_title_str,
		   "NO_ARTIST", &G.no_artist_str, defval.no_artist_str,
		   "VARIOUSARTISTS", &G.variousartists_str, defval.variousartists_str);

  // setup importer
  if (!(importers[0].dir = realpath(audiodir, NULL))) {
    DPRINTF(E_FATAL, L_SCAN, "Not valid audiodir: %s\n", audiodir);
    err = 1;
    goto exit0;
  }
  if (!(importers[1].dir = realpath(playlistdir, NULL))) {
    DPRINTF(E_FATAL, L_SCAN, "Not valid playlistdir: %s\n", playlistdir);
    err = 1;
    goto exit1;
  }

  // open db
  mysql_init(&mysql);
  if (!(mysql_real_connect(&mysql, "localhost", "", "",
			   dbname, 0, NULL, 0))) {
    DPRINTF(E_FATAL, L_SCAN, "Cannot connect DB <%s>\n", dbname);
    mysql_close(&mysql);
    err = -1;
    goto exit2;
  }
  DPRINTF(E_INFO, L_SCAN, "Database <%s> is opened.\n", dbname);

  // check if scanner already running
  (void) db_get_scanning(&mysql, &scanning);
  while (scanning) {
    sleep(10);
    (void) db_get_scanning(&mysql, &scanning);
  };
  (void) db_set_scanning(&mysql, 1);

  // Wipe
  if (G.wipe) {
    char *artwork_cachedir;
    struct stat stat;
    DPRINTF(E_OFF, L_SCAN, "Wipe database and artwork cache.\n", dbname);
    db_wipe(&mysql);
    if (!(artwork_cachedir = malloc(PATH_MAX)))
      DPRINTF(E_FATAL, L_SCAN, "Out of memory\n");
    snprintf(artwork_cachedir, PATH_MAX, "%s/Artwork", prefs.cachedir);
    if (!lstat(artwork_cachedir, &stat) &&
	stat.st_mode & S_IFDIR) {
      (void) rmtree(artwork_cachedir);
    }
    free(artwork_cachedir);
  }
  else {
    (void) db_get_lastrescantime(&mysql, &G.lastrescantime);
  }

  db_set_lastrescantime(&mysql);

  // count total first
  if (G.show_progress) {
    for (i=0; importers[i].types; i++) {
      scan_directory(importers[i].dir, prefs.language, NULL, &(importers[i]));
    }
  }
  else {
    DPRINTF(E_OFF, L_SCAN, "Preparing progress update (counting tracks).\n", dbname);
    for (i=0; importers[i].types; i++) {
      db_set_progress(&mysql, PROGRESS_DELETE, importers[i].progress_id, NULL);
    }
  }

  // Main Loop
  for (i=0; importers[i].types; i++) {
    DPRINTF(E_OFF, L_SCAN, "Directory <%s> is scanning type=%s total=%lu ...\n",
	    importers[i].dir, importers[i].name,
	    G.progress_total[importers[i].progress_id]);
    if (G.show_progress)
      db_set_progress(&mysql, PROGRESS_START, importers[i].progress_id, NULL);
    G.progress_start[importers[i].progress_id] = (unsigned long long) time(0);
    if (scan_directory(importers[i].dir, prefs.language, &mysql, &(importers[i]))) {
      mysql_close(&mysql);
      err = -1;
      if (G.show_progress)
	db_set_progress(&mysql, PROGRESS_FINISH, importers[i].progress_id, NULL);
      G.progress_finish[importers[i].progress_id] = (unsigned long long) time(0);
      goto exit2;
    }
    if (G.show_progress)
      db_set_progress(&mysql, PROGRESS_FINISH, importers[i].progress_id, NULL);
    G.progress_finish[importers[i].progress_id] = (unsigned long long) time(0);
  }

  // post process -- check deleted file
  if (!G.wipe) {
    db_sync(&mysql);
  }

  // post process
  DPRINTF(E_OFF, L_SCAN, "Looking for album art...\n");
  if (G.show_progress)
    db_set_progress(&mysql, PROGRESS_START, PROGRESS_ARTWORK, NULL);
  G.progress_start[PROGRESS_ARTWORK] = (unsigned long long) time(0);
  db_merge_artists_albums(&mysql);
  db_find_artworks(&mysql);
  if (G.show_progress)
    db_set_progress(&mysql, PROGRESS_FINISH, PROGRESS_ARTWORK, NULL);
  G.progress_finish[PROGRESS_ARTWORK] = (unsigned long long) time(0);

  // updates stats
  if (!G.show_progress) {
    for (i=0; importers[i].types; i++) {
      db_set_progress(&mysql, PROGRESS_ALL, importers[i].progress_id, NULL);
    }
  }

  // finishing
  db_set_scanning(&mysql, 0);
  mysql_close(&mysql);

  // epilogue
  DPRINTF(E_OFF, L_SCAN, "%lu songs skipped and %lu songs scanned "
	  "(%lu songs added and %lu songs updated).\n",
	  G.skipped_songs, G.progress_done[PROGRESS_DIRECTORY], G.added_songs, G.updated_songs);
  DPRINTF(E_OFF, L_SCAN, "Scan finish. Exiting...\n");

 exit2:
  if (importers[1].dir) free(importers[1].dir);
 exit1:
  if (importers[0].dir) free(importers[0].dir);
 exit0:
  return err;
}
