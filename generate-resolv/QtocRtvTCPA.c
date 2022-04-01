/*
 * Retrieve TCP attributes
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
#include "QtocRtvTCPA.h"

#include <as400_protos.h>
#include <stdbool.h>

static ILEpointer QtocRtvTCPA_sym __attribute__ ((aligned (16)));
static int qtocnetsts_mark = -1;
static bool qtocnetsts_initialized = false;

static bool
init_pgm (void)
{
	qtocnetsts_mark = _ILELOAD("QSYS/QTOCNETSTS", ILELOAD_LIBOBJ);
	if (qtocnetsts_mark == -1) {
		return false;
	}
	if (_ILESYM(&QtocRtvTCPA_sym, qtocnetsts_mark, "QtocRtvTCPA") == -1) {
		return false;
	}
	qtocnetsts_initialized = true;
	return true;
}

void
QtocRtvTCPA (void *out, int *outlen, char *format_name, ERRC0100 *error)
{
	if (!qtocnetsts_initialized) {
		if (!init_pgm()) {
			/* XXX: fail */
		}
	}
	if (out == NULL || format_name == NULL || error == NULL) {
		/* XXX: fail */
	}
	/* Assume caller passes in EBCDIC */
	struct {
		ILEarglist_base base __attribute__ ((aligned (16)));
		ILEpointer _out __attribute__ ((aligned (16)));
		ILEpointer _outlen __attribute__ ((aligned (16)));
		ILEpointer _format_name __attribute__ ((aligned (16)));
		ILEpointer _error __attribute__ ((aligned (16)));
	} arglist __attribute__ ((aligned (16)));
	arglist._out.s.addr = (address64_t)out;
	arglist._outlen.s.addr = (address64_t)outlen;
	arglist._format_name.s.addr = (address64_t)format_name;
	arglist._error.s.addr = (address64_t)error;
	const arg_type_t argtypes[] = {
		ARG_MEMPTR,
		ARG_MEMPTR, /* i'm surprised too */
		ARG_MEMPTR,
		ARG_MEMPTR,
		ARG_END
	};
	if (-1 != _ILECALLX(&QtocRtvTCPA_sym, &arglist.base, argtypes, RESULT_VOID, ILECALL_NOINTERRUPT)) {
		/* XXX: fail */
	}
	/* check error */
}
