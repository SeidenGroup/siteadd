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

extern "C" {
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
}

#include "../libsiteadd-c/ebcdic.hxx"
#include "../libsiteadd-c/pgmfunc.hxx"

EF<8> RTMZ0100_name("RTMZ0100");
EF<10> QTIMZON("QTIMZON");

static auto QWCRTVTZ = PGMFunction<void*, int, const char*, const char*, ERRC0100*>("QSYS", "QWCRTVTZ");
static auto QWCRSVAL = PGMFunction<void*, int, int, const char*, ERRC0100*>("QSYS", "QWCRSVAL");

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
	Qwc_RTMZ0100_t *hdr = (Qwc_RTMZ0100_t*)calloc(outlen, 1);
	hdr->Bytes_Available = outlen;
	char *out = (char*)hdr;
	ERRC0100 err = {};
	err.bytes_in = sizeof(err);
	
	QWCRTVTZ((void*)out, outlen, RTMZ0100_name.value, name, &err);
	if (err.exception_id [0] != '\0') {
		char code[8];
		ebcdic2utf(err.exception_id, 7, code);
		code[7] = '\0'; /* truncate */
		fprintf(stderr, "QCRTVTZ returned exception code %s\n", code);
		abort();
	}
	for (int i = 0; i < hdr->Time_Zone_Returned; i++) {
		Qwc_RTMZ_Time_Zone_Info_t *item = (Qwc_RTMZ_Time_Zone_Info_t*)(out + hdr->Time_Zone_Offset + (hdr->Time_Zone_Length * i));
		print_RTMZ0100_entry (item);
	}
	free(hdr);
}

/* Returns a heap allocated EBCDIC string */
static char*
get_current_timzon (void)
{
	int outlen = 1000000;
	Qwc_Rsval_Data_Rtnd_t *out = (Qwc_Rsval_Data_Rtnd_t*)calloc(outlen, 1);
	Qwc_Rsval_Sys_Value_Table_t *entry;
	char *out_str;
	ERRC0100 err = {};
	err.bytes_in = sizeof(err);

	QWCRSVAL((void*)out, outlen, 1, QTIMZON.value, &err);
	if (err.exception_id [0] != '\0') {
		char code[8];
		ebcdic2utf(err.exception_id, 7, code);
		code[7] = '\0'; /* truncate */
		fprintf(stderr, "QWCRSVAL returned exception code %s\n", code);
		abort();
	}
	if (out->Number_Sys_Vals_Rtnd != 1) {
		fprintf(stderr, "wrong amount of values returned (was %d)\n", out->Number_Sys_Vals_Rtnd);
		abort();
	}
	entry = (Qwc_Rsval_Sys_Value_Table_t*)((char*)out + out->Offset_Sys_Val_Table[0]);
	out_str = (char*)malloc(11);
	if (!out_str) {
		abort();
	}
	memcpy(out_str, entry->Data, 10);
	free(out);
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
