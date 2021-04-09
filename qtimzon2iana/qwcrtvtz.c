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

#include "qwcrtvtz.h"

#include <as400_protos.h>
#include <stdbool.h>

ILEpointer pgm __attribute__ ((aligned (16)));
bool initialized = false;

static bool
init_pgm (void)
{
	if (0 != _RSLOBJ2(&pgm, RSLOBJ_TS_PGM, "QWCRTVTZ", "QSYS")) {
		return false;
	}
	initialized = true;
	return true;
}

void
qwcrtvtz (void *out, int *outlen, char *format, char *name, ERRC0100 *error)
{
	if (!initialized) {
		if (!init_pgm()) {
			/* XXX: fail */
		}
	}
	if (out == NULL || outlen == NULL || format == NULL || name == NULL || error == NULL) {
		/* XXX: fail */
	}
	/* Assume caller passes in EBCDIC */
	void *pgm_argv[] = {
		out,
		outlen,
		format,
		name,
		error,
		NULL
	};
	if (0 != _PGMCALL(&pgm, pgm_argv, 0)) {
		/* XXX: fail */
	}
	/* check error */
}
