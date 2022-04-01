/*
 * Wrapper around IBM i *PGM for retrieving time zone information
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

/* EBCDIC */
#define ALL { 0x5C, 0xC1, 0xD3, 0xD3, 0, 0, 0, 0, 0 }
#define FORMAT_RTMZ0100 { 0xD9, 0xE3, 0xD4, 0xE9, 0xF0, 0xF1, 0xF0, 0xF0 }

/*
 * Please read the manual for the program for structure contents:
 * https://www.ibm.com/support/knowledgecenter/ssw_ibm_i_72/apis/qwcrtvtz.htm
 */

typedef struct {
	int bytes_returned;
	int bytes_available;
	int num_available;
	int offset;
	int num_returned;
	int entry_length;
	/* Reserved area */
} RTMZ0100_header;

/*
 * char values for numerics are zoned decimals, even the one-byte booleans
 */
typedef struct {
	char name[10];
	char local_system_time;
	char dst;
	int utc_offset;
	char standard_abbr[10];
	char standard_name[50];
	char daylight_abbr[10];
	char daylight_name[50];
	char standard_msg[7];
	char daylight_msg[7];
	char msg_name[10];
	char msg_library[10];
	char daylight_start_month[2];
	char daylight_start_day;
	char daylight_start_day_of_month;
	char daylight_start_time[6];
	char daylight_end_month[2];
	char daylight_end_day;
	char daylight_end_day_of_month;
	char daylight_end_time[6];
	char description[50];
	int daylight_shift;
	int year_offset;
	char alternative_name[128];
	/* Reserved area */
} RTMZ0100_entry;

void qwcrtvtz(void*, int*, char*, char*, ERRC0100*);
