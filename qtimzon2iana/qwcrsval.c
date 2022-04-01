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

#include "../libsiteadd-c/errc.h"
#include "qwcrsval.h"

#include <as400_protos.h>
#include <stdbool.h>

static ILEpointer sysval_pgm __attribute__ ((aligned (16)));
static bool sysval_initialized = false;

static bool
init_pgm (void)
{
	if (0 != _RSLOBJ2(&sysval_pgm, RSLOBJ_TS_PGM, "QWCRSVAL", "QSYS")) {
		return false;
	}
	sysval_initialized = true;
	return true;
}

void
qwcrsval (void *out, int *outlen, int *count, char **names, ERRC0100 *error)
{
	if (!sysval_initialized) {
		if (!init_pgm()) {
			/* XXX: fail */
		}
	}
	if (out == NULL || outlen == NULL || count == NULL || names == NULL || error == NULL) {
		/* XXX: fail */
	}
	/* Assume caller passes in EBCDIC */
	void *pgm_argv[] = {
		out,
		outlen,
		count,
		names,
		error,
		NULL
	};
	if (0 != _PGMCALL(&sysval_pgm, pgm_argv, 0)) {
		/* XXX: fail */
	}
	/* check error */
}
