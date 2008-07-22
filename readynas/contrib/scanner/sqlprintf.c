//=========================================================================
// FILENAME	: sqlprintf.c
// DESCRIPTION	: Extended printf for SQL statement
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


// %U  URL encode except [a-zA-Z0-9.-_/()~,&[]!@$].
// %K  same as %U, but '%' and '_' will be esacped by '\' for LIKE statement
// %S  same as %s except single quote will be duplicated for SQL statement.
// %D  same as %d, but if negative, it prints NULL for SQL (unsigned).
// %I  same as %u, but if 0, it prints NULL for SQL (unsigned).
// %T  similar to %S. Sorounded with signle-quote if not-null. Otherwise NULL.

#include <stdio.h>
#include <ctype.h>
#include <string.h>

#include "sqlprintf.h"

extern size_t strnlen(const char *s, size_t maxlen);

#define do_div(n,base) ({ \
      int __res;                                       \
      __res = ((unsigned long) n) % (unsigned) base;   \
      n = ((unsigned long) n) / (unsigned) base;       \
      __res; })

#define INT_MAX         ((int)(~0U>>1))
#define INT_MIN         (-INT_MAX - 1)

#define ZEROPAD	1		/* pad with zero */
#define SIGN	2		/* unsigned/signed long */
#define PLUS	4		/* show plus */
#define SPACE	8		/* space if plus */
#define LEFT	16		/* left justified */
#define SPECIAL	32		/* 0x */
#define LARGE	64		/* use 'ABCDEF' instead of 'abcdef' */
#define SQLNULL	128		/* print NULL if negative */

static char lc_digits[] = "0123456789abcdefghijklmnopqrstuvwxyz";
static char uc_digits[] = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
static char *
number(char * buf, char * end, long long num, int base, int size, int precision, int type)
{
  char c,sign,tmp[66];
  const char *digits;
  int i;
  char nullstr[4] = "NULL";

  if (type & SQLNULL) {
    if (type & SIGN) {
      if (num < 0) {
	for (i=0; i<4 && buf<=end; i++)
	  *buf++ = nullstr[i];
	return buf;
      }
    }
    else {
      if (num==0) {
	for (i=0; i<4 && buf<=end; i++)
	  *buf++ = nullstr[i];
	return buf;
      }
    }
  }

  digits = (type & LARGE) ? uc_digits : lc_digits;
  if (type & LEFT)
    type &= ~ZEROPAD;
  if (base < 2 || base > 36)
    return 0;
  c = (type & ZEROPAD) ? '0' : ' ';
  sign = 0;
  if (type & SIGN) {
    if (num < 0) {
      sign = '-';
      num = -num;
      size--;
    }
    else if (type & PLUS) {
      sign = '+';
      size--;
    }
    else if (type & SPACE) {
      sign = ' ';
      size--;
    }
  }
  if (type & SPECIAL) {
    if (base == 16)
      size -= 2;
    else if (base == 8)
      size--;
  }
  i = 0;
  if (num == 0)
    tmp[i++]='0';
  else while (num != 0)
    tmp[i++] = digits[do_div(num,base)];
  if (i > precision)
    precision = i;
  size -= precision;
  if (!(type&(ZEROPAD+LEFT))) {
    while(size-->0) {
      if (buf <= end)
	*buf = ' ';
      ++buf;
    }
  }
  if (sign) {
    if (buf <= end)
      *buf = sign;
    ++buf;
  }
  if (type & SPECIAL) {
    if (base==8) {
      if (buf <= end)
	*buf = '0';
      ++buf;
    }
    else if (base==16) {
      if (buf <= end)
	*buf = '0';
      ++buf;
      if (buf <= end)
	*buf = digits[33];
      ++buf;
    }
  }
  if (!(type & LEFT)) {
    while (size-- > 0) {
      if (buf <= end)
	*buf = c;
      ++buf;
    }
  }
  while (i < precision--) {
    if (buf <= end)
      *buf = '0';
    ++buf;
  }
  while (i-- > 0) {
    if (buf <= end)
      *buf = tmp[i];
    ++buf;
  }
  while (size-- > 0) {
    if (buf <= end)
      *buf = ' ';
    ++buf;
  }
  return buf;
}

static int
skip_atoi(const char **s)
{
  int i=0;

  while (isdigit(**s))
    i = i*10 + *((*s)++) - '0';
  return i;
}

int
sql_vsnprintf(char *buf, int size, const char *fmt, va_list args)
{
  int len;
  unsigned long long num;
  int i, base, t;
  char *str, *end, c;
  const char *s;

  int flags;					// flags to number()

  int field_width;
  int precision;
  int qualifier;

  str = buf;
  end = buf + size - 1;

  if (end < buf - 1) {
    end = ((void *) -1);
    size = end - buf + 1;
  }

  for (; *fmt ; ++fmt) {
    if (*fmt != '%') {
      if (str <= end)
	*str = *fmt;
      ++str;
      continue;
    }

    /* process flags */
    flags = 0;
  repeat:
    ++fmt;		/* this also skips first '%' */
    switch (*fmt) {
    case '-': flags |= LEFT; goto repeat;
    case '+': flags |= PLUS; goto repeat;
    case ' ': flags |= SPACE; goto repeat;
    case '#': flags |= SPECIAL; goto repeat;
    case '0': flags |= ZEROPAD; goto repeat;
    }

    /* get field width */
    field_width = -1;
    if (isdigit(*fmt))
      field_width = skip_atoi(&fmt);
    else if (*fmt == '*') {
      ++fmt;
      /* it's the next argument */
      field_width = va_arg(args, int);
      if (field_width < 0) {
	field_width = -field_width;
	flags |= LEFT;
      }
    }

    /* get the precision */
    precision = -1;
    if (*fmt == '.') {
      ++fmt;
      if (isdigit(*fmt))
	precision = skip_atoi(&fmt);
      else if (*fmt == '*') {
	++fmt;
	/* it's the next argument */
	precision = va_arg(args, int);
      }
      if (precision < 0)
	precision = 0;
    }

    /* get the conversion qualifier */
    qualifier = -1;
    if (*fmt == 'h' || *fmt == 'l' || *fmt == 'L' || *fmt =='Z') {
      qualifier = *fmt;
      ++fmt;
      if (qualifier == 'l' && *fmt == 'l') {
	qualifier = 'L';
	++fmt;
      }
    }

    /* default base */
    base = 10;

    switch (*fmt) {
    case 'c':
      if (!(flags & LEFT)) {
	while (--field_width > 0) {
	  if (str <= end)
	    *str = ' ';
	  ++str;
	}
      }
      c = (unsigned char) va_arg(args, int);
      if (str <= end)
	*str = c;
      ++str;
      while (--field_width > 0) {
	if (str <= end)
	  *str = ' ';
	++str;
      }
      continue;

    case 's':
      s = va_arg(args, char *);
      if (!s)
	s = "<NULL>";

      len = strnlen(s, precision);

      if (!(flags & LEFT)) {
	while (len < field_width--) {
	  if (str <= end)
	    *str = ' ';
	  ++str;
	}
      }
      for (i = 0; i < len; ++i) {
	if (str <= end)
	  *str = *s;
	++str; ++s;
      }
      while (len < field_width--) {
	if (str <= end)
	  *str = ' ';
	++str;
      }
      continue;

    case 'S':					// single-quote will be doubled
      s = va_arg(args, char *);
      if (!s)
	s = "<NULL>";

      while (*s) {
	if (*s == '\'') {
	  if ((str+1) <= end) {
	    *str++ = '\'';
	    *str = *s;
	  }
	}
	else {
	  if (str <= end)
	    *str = *s;
	}
	++str; ++s;
      }
      continue;

    case 'T':					// single-quote will be doubled, and sourounded with "'"
      s = va_arg(args, char *);
      t = 0;
      if (s) {
	*str++ = '\'';
	t = 1;
      }
      else {
	s = "NULL";
      }

      while (*s) {
	if (*s == '\'') {
	  if ((str+1) <= end) {
	    *str++ = '\'';
	    *str = *s;
	  }
	}
	else {
	  if (str <= end)
	    *str = *s;
	}
	++str; ++s;
      }
      if (t && str <= end)
	*str++ = '\'';
      continue;

    case 'K':					// URL Encoded. Ignore flags and precision. for LIKE
    case 'U':					// URL Encoded. Ignore flags and precision.
      s = va_arg(args, char *);
      if (!s)
	s = "<NULL>";

      while (*s) {
	int c = (int) *s & 0xff;
	if (*fmt=='K' && (c=='_')) {
	  if ((str+1) <= end) {
	    *str++ = '\\';
	    *str = c;
	  }
	}
	else if (isalnum(c) || c=='.' || c=='-' || c=='_' ||
	    c=='/' || c=='(' || c==')' || c=='~' || c==',' ||
	    c=='&' || c=='[' || c==']' || c=='!' || c=='@' ||
	    c=='$') {
	  if (str <= end)
	    *str = *s;
	}
	else {
	  if (*fmt=='K') {
	    if ((str+3) <= end) {
	      *str++ = '\\';
	      *str++ = '%';
	      *str++ = uc_digits[(c>>4) & 15];
	      *str = uc_digits[c & 15];
	    }
	  }
	  else {
	    if ((str+2) <= end) {
	      *str++ = '%';
	      *str++ = uc_digits[(c>>4) & 15];
	      *str = uc_digits[c & 15];
	    }
	  }
	}
	++str; ++s;
      }
      continue;

    case 'p':
      if (field_width == -1) {
	field_width = 2*sizeof(void *);
	flags |= ZEROPAD;
      }
      str = number(str, end,
		   (unsigned long) va_arg(args, void *),
		   16, field_width, precision, flags);
      continue;


    case 'n':
      /* FIXME:
       * What does C99 say about the overflow case here? */
      if (qualifier == 'l') {
	long * ip = va_arg(args, long *);
	*ip = (str - buf);
      }
      else if (qualifier == 'Z') {
	int * ip = va_arg(args, int *);
	*ip = (str - buf);
      }
      else {
	int * ip = va_arg(args, int *);
	*ip = (str - buf);
      }
      continue;

    case '%':
      if (str <= end)
	*str = '%';
      ++str;
      continue;

      /* integer number formats - set up the flags and "break" */
    case 'o':
      base = 8;
      break;

    case 'X':
      flags |= LARGE;
    case 'x':
      base = 16;
      break;

    case 'D':
      flags |= SIGN;
    case 'I':
      flags |= SQLNULL;
      break;

    case 'd':
    case 'i':
      flags |= SIGN;
    case 'u':
      break;

    default:
      if (str <= end)
	*str = '%';
      ++str;
      if (*fmt) {
	if (str <= end)
	  *str = *fmt;
	++str;
      }
      else {
	--fmt;
      }
      continue;
    }
    if (qualifier == 'L')
      num = va_arg(args, long long);
    else if (qualifier == 'l') {
      num = va_arg(args, unsigned long);
      if (flags & SIGN)
	num = (signed long) num;
    }
    else if (qualifier == 'Z') {
      num = va_arg(args, int);
    }
    else if (qualifier == 'h') {
      num = (unsigned short) va_arg(args, int);
      if (flags & SIGN)
	num = (signed short) num;
    }
    else {
      num = va_arg(args, unsigned int);
      if (flags & SIGN)
	num = (signed int) num;
    }
    str = number(str, end, num, base,
		 field_width, precision, flags);
  }
  if (str <= end)
    *str = '\0';
  else if (size > 0)
    /* don't write out a null byte if the buf size is zero */
    *end = '\0';
  /* the trailing null byte doesn't count towards the total
   * ++str;
   */
  return str-buf;
}

int
sql_snprintf(char * buf, int size, const char *fmt, ...)
{
  va_list args;
  int i;

  va_start(args,fmt);
  i = sql_vsnprintf(buf,size,fmt,args);
  va_end(args);
  return i;
}
