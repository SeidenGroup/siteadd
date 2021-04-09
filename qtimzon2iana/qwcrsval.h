/*
 * Wrapper around IBM i *PGM for retrieving system values
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

typedef struct {
	int num_returned;
	int offsets[];
	/* After this, the actual values */
} Sysvals;

typedef struct {
	char name[10];
	char type[1];
	char status[1];
	int length;
	char data[];
} SysvalEntry;

void qwcrsval(void*, int*, int*, char**, ERRC0100*);
