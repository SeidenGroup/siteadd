/*
 * Retrieve TCP attributes
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

typedef struct {
	int bytes_returned;
	int bytes_available;
	int v6_status;
	int offset;
	int length;
	int v4_status;
	unsigned char data[];
	/* After this, the actual values */
} TCPA1100;

#define FORMAT_TCPA1400 { 0xE3, 0xC3, 0xD7, 0xC1, 0xF1, 0xF4, 0xF0, 0xF0 }

typedef struct {
	int dns_address_offset;
	int dns_address_count;
	int dns_address_length;
	int dns_protocol;
	int dns_retries;
	int dns_time_interval;
	int dns_search_order;
	int dns_initial_server;
	int dns_listening_port;
	char host_name[64];
	char domain_name[255];
	char _reserved;
	char search_list[256];
	int dns_dnssec;
	/* the displacement relative from TCPA1100 is used it seems */
} TCPA1400;

typedef struct {
	int protocol;
	char address_string[45];
	char _reserved[3];
	char address_binary[16];
} TCPA1400_DNSAddress;

void QtocRtvTCPA(void*, int*, char*, ERRC0100*);
