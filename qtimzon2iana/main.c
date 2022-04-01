/*
 * Program to convert IBM i *TIMZON to their IANA zoneinfo names
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

#include <stdio.h>
#include <stdbool.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "../libsiteadd-c/errc.h"
#include "qwcrtvtz.h"
#include "qwcrsval.h"
#include "../libsiteadd-c/ebcdic.h"

void
print_RTMZ0100_entry (RTMZ0100_entry *item)
{
	char utf[129], *first_space;
	ebcdic2utf (item->alternative_name, 50, utf);
	/* Truncate on first space */
	first_space = strchr(utf, ' ');
	if (first_space) {
		*first_space = '\0';
	}
	/*
	 * IANA zoneinfo puts GMT+/- (outside of regular GMT) in Etc/,
	 * but since it puts normal GMT there too...
	 */
	if (strstr(utf, "GMT") == utf) {
		printf ("Etc/%s\n", utf);
	} else {
		printf ("%s\n", utf);
	}
}

void
get_RTMZ0100_entries (char *name)
{
	int outlen = 1000000;
	char *out = malloc(outlen);
	char format[] = FORMAT_RTMZ0100;
	ERRC0100 err = { 0 };
	err.bytes_in = sizeof (err);
	
	qwcrtvtz((void*)out, &outlen, format, name, &err);
	RTMZ0100_header *hdr = (RTMZ0100_header*)out;
	/* assume victory */
	for (int i = 0; i < hdr->num_returned; i++) {
		RTMZ0100_entry *item = (RTMZ0100_entry*)(out + hdr->offset + (hdr->entry_length * i));
		print_RTMZ0100_entry (item);
	}
}

/* Returns a heap allocated EBCDIC string */
static char*
get_current_timzon (void)
{
	int outlen = 1000000, num_elem = 1;
	Sysvals *out = malloc (outlen);
	SysvalEntry *entry;
	char *out_str;
	ERRC0100 err = { 0 };
	/* EBCDIC "QTIMZON   " */
	char name[1][10] = { { 0xD8, 0xE3, 0xC9, 0xD4, 0xE9, 0xD6, 0xD5, 0x40, 0x40, 0x40 } };
	err.bytes_in = sizeof (err);

	qwcrsval ((void*)out, &outlen, &num_elem, (char**)name, &err);
	if (out->num_returned != 1) {
		return NULL;
	}
	entry = (SysvalEntry*)((char*)out + out->offsets[0]);
	out_str = malloc (11);
	if (!out_str) {
		return NULL;
	}
	memcpy(out_str, entry->data, 10);
	return out_str;
}

static void
usage (char *argv0)
{
	fprintf(stderr, "usage: %s [timzon]\n", argv0);
}

int
main (int argc, char **argv)
{
	int ch;
	while ((ch = getopt (argc, argv, "")) != -1) {
		switch (ch) {
		default:
			usage (argv [0]);
			return 1;
		}
	}
	if (argc == optind) {
		char *name = get_current_timzon ();
		if (!name) {
			return 1;
		}
		get_RTMZ0100_entries (name);
		free (name);
	} else {
		for (int i = optind; i < argc; i++) {
			char name[11];
			utf2ebcdic (argv[i], 10, name);
			get_RTMZ0100_entries (name);
		}
	}
	return 0;
}
