//=========================================================================
// FILENAME	: filecache.c
// DESCRIPTION	: File Cache Utils
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
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/stat.h>
#include <time.h>

#include "filecache.h"
#include "prefs.h"
#include "misc.h"

#define _STR(x) _VAL(x)
#define _VAL(x) #x

#define PERL_STR	0x01
#define PERL_ARRAY	0x02
#define PERL_HASH	0x03
#define PERL_REF	0x04
#define PERL_UNDEF	0x05
#define PERL_INT8	0x08
#define PERL_INT	0x09
#define PERL_STR8	0x0a

static int
_mkdir_if_not(char *dirpath)
{
  int err;
  struct stat stat;

  if (lstat(dirpath, &stat) != -1) {
    if (!(stat.st_mode & S_IFDIR)) {
      return -1;
    }
    return 0;					// already exist
  }
  err = mkdir(dirpath, 0755);
  return err;
}

static int
_wr_AV_len(__u32 len, FILE *fp)			// len = number of elements
{
  __u32 len_be32 = cpu_to_be32(len);
  if (fputc(PERL_ARRAY, fp)==EOF)
    return -1;
  if (fwrite(&len_be32, 1, 4, fp)!=4)
    return -1;
  return 0;
}

static int
_wr_HV_len(__u32 len, FILE *fp)			// len = number of kv pair
{
  int len_be32 = cpu_to_be32(len);
  if (fputc(PERL_HASH, fp)==EOF)
    return -1;
  if (fwrite(&len_be32, 1, 4, fp)!=4)
    return -1;
  return 0;
}

static int
_wr_SV_str(char *str, __u32 str_len, FILE *fp)
{
  if (str_len>=256) {
    __u32 str_len_be32 = cpu_to_be32(str_len);
    if (fputc(PERL_STR, fp)==EOF)
      return -1;
    if (fwrite(&str_len_be32, 1, 4, fp)!=4)
      return -1;
  }
  else {
    unsigned char str_len_u8 = str_len;
    if (fputc(PERL_STR8, fp)==EOF)
      return -1;
    if (fwrite(&str_len_u8, 1, 1, fp)!=1)
      return -1;
  }
  if (fwrite(str, 1, str_len, fp)!=str_len)
    return -1;
  return 0;
}

static int
_wr_HV_int(char *hk, __u32 hklen, int val, FILE *fp)
{
  __u32 hklen_be32;
  __s8 val_s8 = val & 127;
  if (val_s8 == val) {
    val_s8 |= 0x80;				// offset +128
    if (fputc(PERL_INT8, fp)==EOF)
      return -1;
    if (fwrite(&val_s8, 1, 1, fp)!=1)
      return -1;
  }
  else {
    __s32 val_s32 = cpu_to_be32(val);
    if (fputc(PERL_INT, fp)==EOF)
      return -1;
    if (fwrite(&val_s32, 1, 4, fp)!=4)
      return -1;
  }
  hklen_be32 = cpu_to_be32(hklen);
  if (fwrite(&hklen_be32, 1, 4, fp)!=4)
    return -1;
  if (fwrite(hk, 1, hklen, fp)!=hklen)
    return -1;
  return 0;
}

static int
_wr_HV_str(char *hk, __u32 hklen, char *str, __u32 str_len, FILE *fp)
{
  __u32 hklen_be32;
  if (str_len>=256) {
    __u32 str_len_be32 = cpu_to_be32(str_len);
    if (fputc(PERL_STR, fp)==EOF)
      return -1;
    if (fwrite(&str_len_be32, 1, 4, fp)!=4)
      return -1;
  }
  else {
    __u8 str_len_u8 = str_len;
    if (fputc(PERL_STR8, fp)==EOF)
      return -1;
    if (fwrite(&str_len_u8, 1, 1, fp)!=1)
      return -1;
  }
  if (fwrite(str, 1, str_len, fp)!=str_len)
    return -1;
  hklen_be32 = cpu_to_be32(hklen);
  if (fwrite(&hklen_be32, 1, 4, fp)!=4)
    return -1;
  if (fwrite(hk, 1, hklen, fp)!=hklen)
    return -1;
  return 0;
}

static int
_wr_HV_undef(char *hk, __u32 hklen, FILE *fp)
{
  __u32 hklen_be32;
  if (fputc(PERL_UNDEF, fp)==EOF)
    return -1;
  hklen_be32 = cpu_to_be32(hklen);
  if (fwrite(&hklen_be32, 1, 4, fp)!=4)
    return -1;
  if (fwrite(hk, 1, hklen, fp)!=hklen)
    return -1;
  return 0;
}

static int
_wr_HV_keyonly(char *hk, __u32 hklen, FILE *fp)
{
  __u32 hklen_be32;
  hklen_be32 = cpu_to_be32(hklen);
  if (fwrite(&hklen_be32, 1, 4, fp)!=4)
    return -1;
  if (fwrite(hk, 1, hklen, fp)!=hklen)
    return -1;
  return 0;
}

static FILE*
_open_hash_file(char *path, char *path_hash, char *hkey)
{
  char *p1, *p2;

  path_hash[0] = '/';
  path_hash[1] = hkey[0];
  path_hash[2] = '\0';
  if (_mkdir_if_not(path))
    return NULL;
  path_hash[2] = '/';
  path_hash[3] = hkey[1];
  path_hash[4] = '\0';
  if (_mkdir_if_not(path))
    return NULL;
  path_hash[4] = '/';
  path_hash[5] = hkey[2];
  path_hash[6] = '\0';
  if (_mkdir_if_not(path))
    return NULL;
  path_hash[6] = '/';
  for (p1=hkey, p2=path_hash+7; *p1; p1++,p2++) {
    *p2 = *p1;
  }
  *p2 = '\0';
  return fopen(path, "wb");
}

static int
_create_cache_version(char *path, char *path_hash, char *str_tstamp, int strlen_tstamp)
{
  char *key = "Slim::Utils::Cache-version";
  char *hashed_key;
  FILE *fp;

  hashed_key = sha1_hex(key);
  if (!(fp = _open_hash_file(path, path_hash, hashed_key)))
    return -1;

  // start
  if (fwrite("\x05\x07", 1, 2, fp) != 2)
    goto _err;
  // array of 2
  if (_wr_AV_len(2, fp))
    goto _err;
  // [0] = SV(str)
  if (_wr_SV_str(key, strlen(key), fp))
    goto _err;
  // [1] = ref blessed (Cache::Object)
  if (fwrite("\x04\x11\x0d" "Cache::Object", 1, 16, fp) != 16)
    goto _err;
  // [1]-> Hash length = 6
  if (_wr_HV_len(6, fp))
    goto _err;
  // [1]->{_Size} = SV(undef)
  if (_wr_HV_undef("_Size", 5, fp))
    goto _err;
  // [1]->{_Expires_At} = SV(str)
  if (_wr_HV_str("_Expires_At", 11, "never", 5, fp))
    goto _err;
  // [1]->{_Key} = SV(undef)
  if (_wr_HV_undef("_Key", 4, fp))
    goto _err;
  // [1]->{_Created_At} = SV(str)
  if (_wr_HV_str("_Created_At", 11, str_tstamp, strlen_tstamp, fp))
    goto _err;
  // [1]->{_Data} = SV(int)
  if (_wr_HV_int("_Data", 5, 1, fp))
    goto _err;
  // [1]->{_Accessed_At}
  if (_wr_HV_str("_Accessed_At", 12, str_tstamp, strlen_tstamp, fp))
    goto _err;
  // end
  return 0;

 _err:
  fclose(fp);
  unlink(path);
  return -1;
}

int
save_to_cache(char *key, struct _Cache_Object *data)
{
  char *hashed_key;
  static char cachepath[PATH_MAX];
  static char *cachepath_hash = 0;
  FILE *fp;
  int n;
  char str_tstamp[32];
  int strlen_tstamp;
  char str_mtime[32];
  int strlen_mtime;

  strlen_tstamp = snprintf(str_tstamp, sizeof(str_tstamp), "%lu", (unsigned long) time(0));

  if (!cachepath_hash) {
    n = sprintf(cachepath, "%s/Artwork", prefs.cachedir);
    if (_mkdir_if_not(cachepath))
      return -1;
    cachepath_hash = cachepath + n;
    if (_create_cache_version(cachepath, cachepath_hash, str_tstamp, strlen_tstamp))
      return -1;
  }

  hashed_key = sha1_hex(key);
  if (!(fp = _open_hash_file(cachepath, cachepath_hash, hashed_key)))
    return -1;

  strlen_mtime = snprintf(str_mtime, sizeof(str_mtime), "%lu", (unsigned long) data->mtime);

  // start
  if (fwrite("\x05\x07", 1, 2, fp) != 2)
    goto _err;
  // array of 2
  if (_wr_AV_len(2, fp))
    goto _err;
  // [0] = SV(str)
  if (_wr_SV_str(key, strlen(key), fp))
    goto _err;
  // [1] = ref blessed (Cache::Object)
  if (fwrite("\x04\x11\x0d" "Cache::Object", 1, 16, fp) != 16)
    goto _err;
  // [1]-> Hash length = 6
  if (_wr_HV_len(6, fp))
    goto _err;
  // [1]->{_Size} = SV(undef)
  if (_wr_HV_undef("_Size", 5, fp))
    goto _err;
  // [1]->{_Expires_At} = SV(str)
  if (_wr_HV_str("_Expires_At", 11, "never", 5, fp))
    goto _err;
  // [1]->{_Key} = SV(undef)
  if (_wr_HV_undef("_Key", 4, fp))
    goto _err;
  // [1]->{_Created_At} = SV(str)
  if (_wr_HV_str("_Created_At", 11, str_tstamp, strlen_tstamp, fp))
    goto _err;
  // ref
  if (fputc(PERL_REF, fp)==EOF)
    goto _err;
  // [1]->{...}-> Hash length = 5
  if (_wr_HV_len(5, fp))
    goto _err;
  // [1]->{...}->{...} = ref to
  if (fputc(PERL_REF, fp)==EOF)
    goto _err;
  // [1]->{...}->{body} = ref to raw
  if (_wr_HV_str("body", 4, data->body, data->body_len, fp))
    goto _err;
  // [1]->{...}->{mtime}
  if (_wr_HV_str("mtime", 5, str_mtime, strlen_mtime, fp))
    goto _err;
  // [1]->{...}->{orig}
  if (_wr_HV_str("orig", 4, data->orig, strlen(data->orig), fp))
    goto _err;
  // [1]->{...}->{contentType}
  if (_wr_HV_str("contentType", 11, data->contentType, strlen(data->contentType), fp))
    goto _err;
  // [1]->{...}->{size}
  if (_wr_HV_undef("size", 4, fp))
    goto _err;
  // [1]->{key=_Data}
  if (_wr_HV_keyonly("_Data", 5, fp))
    goto _err;
  // [1]->{_Accessed_At}
  if (_wr_HV_str("_Accessed_At", 12, str_tstamp, strlen_tstamp, fp))
    goto _err;
  // end
  return 0;

 _err:
  fclose(fp);
  unlink(cachepath);
  return -1;
}
