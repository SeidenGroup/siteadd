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
#include "../libsiteadd-c/ebcdic.hxx"
#include "../libsiteadd-c/ebcdic.h"
#include "../libsiteadd-c/pgmcall.hxx""

EF<8> _ALL("*ALL");
EF<8> RTMZ0100_name("RTMZ0100");
EF<10> QTIMZON("QTIMZON")

static auto QWCRTVTZ = PGMFunction<void*, int, const char*, const char *>("QSYS", "QWCRTVTV");
static auto QWCRSVAL = PGMFunction<void*, int, int, char*, Qus_EC_t*>("QSYS", "QWCRSVAL");

void
print_RTMZ0100_entry (Qwc_RTMZ_Time_Zone_Info_t *item)
{
	char utf[129], *first_space;
	ebcdic2utf (item->Alternate_Name, 50, utf);
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
	ERRC0100 err = { 0 };
	err.bytes_in = sizeof (err);
	
	QWCRTVTZ((void*)out, &outlen, RTMZ0100_name.value, name, &err);
	Qwc_RTMZ0100_t *hdr = (Qwc_RTMZ0100_t*)out;
	/* assume victory */
	for (int i = 0; i < hdr->num_returned; i++) {
		Qwc_RTMZ_Time_Zone_Info_t *item = (Qwc_RTMZ_Time_Zone_Info_t*)(out + hdr->offset + (hdr->entry_length * i));
		print_RTMZ0100_entry (item);
	}
}

/* Returns a heap allocated EBCDIC string */
static char*
get_current_timzon (void)
{
	int outlen = 1000000, num_elem = 1;
	Qwc_Rsval_Data_Rtnd_t *out = malloc (outlen);
	Qwc_Rsval_Sys_Value_Table_t *entry;
	char *out_str;
	ERRC0100 err = { 0 };
	err.bytes_in = sizeof (err);

	QWCRSVAL((void*)out, &outlen, &num_elem, QTIMZON.value, &err);
	if (out->num_returned != 1) {
		return NULL;
	}
	entry = (Qwc_Rsval_Sys_Value_Table_t*)((char*)out + out->Offset_Sys_Val_Table[0]);
	out_str = malloc (11);
	if (!out_str) {
		return NULL;
	}
	memcpy(out_str, entry->Data, 10);
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
