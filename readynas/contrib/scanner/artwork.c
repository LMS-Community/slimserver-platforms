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
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <gd.h>

#include "misc.h"
#include "artwork.h"
#include "log.h"
#include "textutils.h"
#include "filecache.h"
#include "prefs.h"

#define CACHE_TYPE_GD	0
#define CACHE_TYPE_PNG	1
#define CACHE_TYPE_GIF	2
#define CACHE_TYPE_JPG	3

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

static struct _content {
  char *jpg;
  char *png;
  char *gif;
  char *gd;
} content_type = {
  .jpg = "image/jpeg",
  .png = "image/png",
  .gif = "image/gif",
  .gd = "image/gd"
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
  if (lstat(buf, &stat) || !(stat.st_mode & S_IFDIR)) {
    return 0;
  }

  // look for prefs.coverArt, then {[cC]over,[tT]humb,[aA]lbum,[fF]older}.{png,jpg,jpeg,gif}
  for (i=0; basenames[i]; i++) {
    for (j=0; extentions[j]; j++) {
      sprintf(dirend, "/%s.%s", basenames[i], extentions[j]);
      if (!lstat(buf, &stat) && (stat.st_mode & S_IFREG)) {
	DPRINTF(E_INFO, L_ARTWORK, "Found artwork file <%s> for <%s>\n", buf, url);
	return strdup(buf);
      }
    }
  }

  return 0;
}

#define N_FRAC 8
#define MASK_FRAC ((1<<N_FRAC)-1)
#define ROUND2(v) (((v)+(1<<(N_FRAC-1)))>>N_FRAC)
#define DIV(x,y) ( ((x)<<(N_FRAC-3)) / ((y)>>3) )
static void
_boxfilter_resizer (gdImagePtr dst,
		    gdImagePtr src,
		    int dstX, int dstY,
		    int srcX, int srcY,
		    int dstW, int dstH, int srcW, int srcH)
{
  int x, y;
  int sy1, sy2, sx1, sx2;

  if (!dst->trueColor) {
    gdImageCopyResized (dst, src, dstX, dstY, srcX, srcY, dstW, dstH,
			srcW, srcH);
    return;
  }
  for (y = dstY; y < (dstY + dstH); y++) {
    sy1 = (((y - dstY) * srcH) << N_FRAC) / dstH;
    sy2 = (((y - dstY + 1) * srcH) << N_FRAC) / dstH;
    for (x = dstX; x < (dstX + dstW); x++) {
      int sx, sy;
      int spixels = 0;
      int red = 0, green = 0, blue = 0, alpha = 0;
      sx1 = (((x - dstX) * srcW) << N_FRAC) / dstW;
      sx2 = (((x - dstX + 1) * srcW) << N_FRAC) / dstW;
      sy = sy1;
      do {
	int yportion;
	if ((sy>>N_FRAC) == (sy1>>N_FRAC)) {
	  yportion = (1<<N_FRAC) - (sy & MASK_FRAC);
	  if (yportion > sy2 - sy1) {
	    yportion = sy2 - sy1;
	  }
	  sy = sy & ~MASK_FRAC;
	}
	else if (sy == (sy2 & ~MASK_FRAC)) {
	  yportion = sy2 & MASK_FRAC;
	}
	else {
	  yportion = (1<<N_FRAC);
	}
	sx = sx1;
	do {
	  int xportion;
	  int pcontribution;
	  int p;
	  if ((sx>>N_FRAC) == (sx1>>N_FRAC)) {
	    xportion = (1<<N_FRAC) - (sx & MASK_FRAC);
	    if (xportion > sx2 - sx1) {
	      xportion = sx2 - sx1;
	    }
	    sx = sx & ~MASK_FRAC;
	  }
	  else if (sx == (sx2 & ~MASK_FRAC)) {
	    xportion = sx2 & MASK_FRAC;
	  }
	  else {
	    xportion = (1<<N_FRAC);
	  }

	  if (xportion && yportion) {
	    pcontribution = (xportion * yportion) >> N_FRAC;
	    p = gdImageGetTrueColorPixel (src, ROUND2(sx) + srcX, ROUND2(sy) + srcY);
	    if (pcontribution == (1<<N_FRAC)) {
	      // optimization for down-scaler, which many pixel has pcontribution=1
	      red += gdTrueColorGetRed(p) << N_FRAC;
	      green += gdTrueColorGetGreen(p) << N_FRAC;
	      blue += gdTrueColorGetBlue(p) << N_FRAC;
	      alpha += gdTrueColorGetAlpha(p) << N_FRAC;
	      spixels += (1<<N_FRAC);
	    }
	    else {
	      red += gdTrueColorGetRed(p) * pcontribution;
	      green += gdTrueColorGetGreen(p) * pcontribution;
	      blue += gdTrueColorGetBlue(p) * pcontribution;
	      alpha += gdTrueColorGetAlpha(p) * pcontribution;
	      spixels += pcontribution;
	    }
	  }
	  sx += (1<<N_FRAC);
	}
	while (sx < sx2);
	sy += (1<<N_FRAC);
      }
      while (sy < sy2);
      if (spixels != 0) {
	red = DIV(red,spixels);
	green = DIV(green,spixels);
	blue = DIV(blue,spixels);
	alpha = DIV(alpha,spixels);
      }
      /* Clamping to allow for rounding errors above */
      if (red > (255<<N_FRAC))
	red = (255<<N_FRAC);
      if (green > (255<<N_FRAC))
	green = (255<<N_FRAC);
      if (blue > (255<<N_FRAC))
	blue = (255<<N_FRAC);
      if (alpha > (gdAlphaMax<<N_FRAC))
	alpha = (gdAlphaMax<<N_FRAC);
      gdImageSetPixel (dst,
		       x, y,
		       gdTrueColorAlpha (ROUND2(red), ROUND2(green), ROUND2(blue), ROUND2(alpha)));
    }
  }
}



static void
_resizer(gdImagePtr d, gdImagePtr s, int dx, int dy, int sx, int sy,
	 int dw, int dh, int sw, int sh)
{
  switch(2) {
  case 0:
    // better quality
    gdImageCopyResampled(d, s, dx, dy, sx, sy, dw, dh, sw, sh);
    break;
  case 1:
    // faster processing
    gdImageCopyResized(d, s, dx, dy, sx, sy, dw, dh, sw, sh);
    break;
  case 2:
    // compromized
    _boxfilter_resizer(d, s, dx, dy, sx, sy, dw, dh, sw, sh);
    break;
  }
}

static int
_resize_and_cache(int track_id, struct _Cache_Object *data,
		  gdImagePtr im, int dim, char resize_mode, int cache_type)
{
  gdImagePtr im_resized;
  char key[64];
  int srcX, srcY, srcDim;
  void *p;
  int sz;
  char *suffix;
  int bgcolor = 0;

  // resize
  if (im->sx > im->sy) {
    srcDim =  im->sy;
    srcX = (im->sx - srcDim) >> 1;
    srcY = 0;
  }
  else {
    srcDim =  im->sx;
    srcX = 0;
    srcY = (im->sy - srcDim) >> 1;
  }
  im_resized = gdImageCreateTrueColor(dim, dim);
  _resizer(im_resized, im, 0, 0, srcX, srcY, dim, dim, srcDim, srcDim);
  switch (cache_type) {
  case CACHE_TYPE_GD:
    p = gdImageGdPtr(im_resized, &sz);
    data->contentType = content_type.gd;
    suffix = "";
    break;
  case CACHE_TYPE_PNG:
    p = gdImagePngPtr(im_resized, &sz);
    data->contentType = content_type.png;
    suffix = "";
    break;
  case CACHE_TYPE_GIF:
    p = gdImageGifPtr(im_resized, &sz);
    data->contentType = content_type.gif;
    suffix = "";
    break;
  case CACHE_TYPE_JPG:
    p = gdImageJpegPtr(im_resized, &sz, 90);
    data->contentType = content_type.jpg;
    suffix = ".jpg";
    bgcolor = 0xffffff;
    break;
  default:
    free(im_resized);
    return -1;
  }
  free(im_resized);

  // found cache key
  sprintf(key, "music/%d/cover_%dx%d_%c%s", track_id, dim, dim, resize_mode, suffix);

  // save to data
  data->body = p;
  data->body_len = sz;
  if (save_to_cache(key, data)) {
    gdFree(p);
    return -1;
  }

  gdFree(p);
  return 0;
}

int
create_coverart_cache(int track_id, char *imgfilename)
{
  FILE *fsrc;
  char *ext;
  gdImagePtr imsrc;
  int err = 0;
  int thumbSize = 100;
  struct _Cache_Object data;
  struct stat stat;

  if (lstat(imgfilename, &stat) == -1)
    return -1;

  data.orig = imgfilename;
  data.mtime = (__u32) stat.st_mtime;

  if (!(fsrc = fopen(imgfilename, "rb")) ||
      !(ext = rindex(imgfilename, '.')))
    return -1;

  if (!strcasecmp(ext, ".jpg")) {
    imsrc = gdImageCreateFromJpeg(fsrc);
  }
  else if (!strcasecmp(ext, ".png")) {
    imsrc = gdImageCreateFromPng(fsrc);
  }
  else if (!strcasecmp(ext, ".gif")) {
    imsrc = gdImageCreateFromGif(fsrc);
  }
  else {
    return -1;
  }
  fclose(fsrc);

  thumbSize = prefs.thumbSize ? prefs.thumbSize : 100;

  if ((err = _resize_and_cache(track_id, &data, imsrc, 50, 'p', CACHE_TYPE_PNG)))
    goto _exit;
  if ((err = _resize_and_cache(track_id, &data, imsrc, thumbSize, 'p', CACHE_TYPE_PNG)))
    goto _exit;
  if ((err = _resize_and_cache(track_id, &data, imsrc, 56, 'o', CACHE_TYPE_JPG)))
    goto _exit;

  DPRINTF(E_INFO, L_ARTWORK, "Created artwork cache from file <%s>\n", imgfilename);

 _exit:
  free(imsrc);
  return err;
}

void
artwork_cache_embedded_image(struct song_metadata *psong)
{
  gdImagePtr imsrc;
  int err = 0;
  int thumbSize = 100;
  struct _Cache_Object data;

  if (!memcmp(psong->image, "\x89" "PNG" "\x0d\x0a\x1a\x0a", 8)) {
    // PNG file
    imsrc = gdImageCreateFromPngPtr(psong->image_size, psong->image);
  }
  else if (!memcmp(psong->image, "\xff\xd8", 2)) {
    // JPG file
    imsrc = gdImageCreateFromJpegPtr(psong->image_size, psong->image);
  }
  else {
    // unknown
    DPRINTF(E_WARN, L_ARTWORK, "Unknown embedded image in <%s> %02x %02x %02x %02x\n",
	    psong->path,
	    psong->image[0] & 0xff, psong->image[1] & 0xff, psong->image[2] & 0xff, psong->image[3] & 0xff);
    return;
  }

  data.orig = psong->path;
  data.mtime = psong->time_modified;

  thumbSize = prefs.thumbSize ? prefs.thumbSize : 100;

  if ((err = _resize_and_cache(psong->track_id, &data, imsrc, 50, 'p', CACHE_TYPE_PNG)))
    goto _exit;
  if ((err = _resize_and_cache(psong->track_id, &data, imsrc, thumbSize, 'p', CACHE_TYPE_PNG)))
    goto _exit;
  if ((err = _resize_and_cache(psong->track_id, &data, imsrc, 56, 'o', CACHE_TYPE_JPG)))
    goto _exit;

  DPRINTF(E_INFO, L_ARTWORK, "Created artwork cache from track <%d:%s>\n", psong->track_id, psong->path);

 _exit:
  free(imsrc);
  return;
}
