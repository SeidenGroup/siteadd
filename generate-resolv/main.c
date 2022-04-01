/*
 * Generate AIX resolv.conf from IBM i TCP attributes
 *
 * Copyright (C) 2022 Seiden Group
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

#include <ctype.h>
#include <stdio.h>
#include <stdbool.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "../libsiteadd-c/errc.h"
#include "QtocRtvTCPA.h"
#include "../libsiteadd-c/ebcdic.h"

void
print_domain(TCPA1400 *tcp1400)
{
	char domain_name[255 * 6];
	ebcdic2utf (tcp1400->domain_name, 255, domain_name);
	/* truncate spaces */
	char *first_space = strchr(domain_name, ' ');
	if (first_space) {
		*first_space = '\0';
	}
	printf("domain %s\n", domain_name);
}

void
print_search(TCPA1400 *tcp1400)
{
	char search_list[256 * 6];
	ebcdic2utf (tcp1400->search_list, 256, search_list);
	/* truncate spaces *at end* */
	for (size_t i = strlen(search_list); i != 0; i--) {
		if (isspace(search_list[i])) {
			search_list[i] = '\0';
		}
	}
	printf("search %s\n", search_list);
}

void
print_options(TCPA1400 *tcp1400)
{
	printf("options timeout:%d attempts:%d", tcp1400->dns_time_interval, tcp1400->dns_retries);
	if (tcp1400->dns_initial_server == 2) {
		printf(" rotate");
	}
	printf("\n");
}

void
print_nameservers(TCPA1100 *tcp1100, TCPA1400 *tcp1400)
{
	TCPA1400_DNSAddress *addresses = (TCPA1400_DNSAddress*)((char*)tcp1100 + tcp1400->dns_address_offset);
	for (int i = 0; i < tcp1400->dns_address_count; i++) {
		char address_string[45 * 6];
		ebcdic2utf (addresses[i].address_string, 45, address_string);
		/* truncate spaces */
		char *first_space = strchr(address_string, ' ');
		if (first_space) {
			*first_space = '\0';
		}
		printf("nameserver %s\n", address_string);
	}
}

void
get_tcp_attribs (void)
{
	int outlen = 1000000;
	TCPA1100 *out = malloc(outlen);
	memset(out, 0, outlen);
	out->bytes_available = outlen;
	char format[] = FORMAT_TCPA1400;
	ERRC0100 err = { 0 };
	err.bytes_in = sizeof (err);
	
	QtocRtvTCPA((void*)out, &outlen, format, &err);
	if (err.exception_id [0] != '\0') {
		char code [8];
		ebcdic2utf (err.exception_id, 7, code);
		code [7] = '\0'; /* truncate */
		fprintf (stderr, "QtocRtvTCPA returned exception code %s\n", code);
		abort();
	}
	printf("# This was generated by a script from IBM i TCP attributes.\n");
	print_domain((TCPA1400*)out->data);
	print_search((TCPA1400*)out->data);
	print_options((TCPA1400*)out->data);
	print_nameservers(out, (TCPA1400*)out->data);
}

static void
usage (char *argv0)
{
	fprintf(stderr, "usage: %s\n", argv0);
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
	get_tcp_attribs ();
	return 0;
}
