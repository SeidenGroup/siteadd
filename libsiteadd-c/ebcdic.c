/*
 * EBCDIC to UTF-8 conversion routines
 *
 * Copyright (C) 2021 Seiden Group
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>
 */

#include </QOpenSys/usr/include/iconv.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

iconv_t e2a, a2e;

static void
init_iconv (void)
{
	/* XXX: This should use the system locales for PASE and XPF */
	e2a = iconv_open(ccsidtocs(1208), ccsidtocs(37));
	a2e = iconv_open(ccsidtocs(37), ccsidtocs(1208));
	if (e2a == (iconv_t)(-1) || a2e == (iconv_t)(-1)) {
		/* XXX: fail */
	}
}

/*
 * Because EBCDIC strings are usually fixed-length and padded by ASCII, try to
 * cope by copying it to a fixed null-terminated buffer.
 */
size_t
ebcdic2utf (char *ebcdic, int ebcdic_len, char *utf)
{
	size_t inleft, outleft, ret;
	if (e2a == NULL) {
		init_iconv ();
	}
	inleft = outleft = ebcdic_len + 1;
	char *temp;
	temp = malloc (ebcdic_len + 1);
	strncpy (temp, ebcdic, ebcdic_len);
	temp [ebcdic_len] = '\0';
	ret = iconv (e2a, &temp, &inleft, &utf, &outleft);
	free (temp);
	return ret;
}

/* Convert a UTF-8 string to a fixed-length EBCDIC string. */
size_t utf2ebcdic (char *utf, int ebcdic_len, char *ebcdic)
{
	size_t inleft, outleft, ret;
	if (a2e == NULL) {
		init_iconv ();
	}
	inleft = outleft = ebcdic_len + 1;
	char *temp;
	temp = malloc (ebcdic_len + 1);
	sprintf (temp, "%-10s", utf);
	ret = iconv (a2e, &temp, &inleft, &ebcdic, &outleft);
	free (temp);
	return ret;
}

/*
 * Zoned decimal to integer conversion
 */
int
ztoi (char *zoned, int len)
{
	char *utf = malloc(len + 1);
	ebcdic2utf (zoned, len, utf);
	return atoi (utf);
}
