#include "qwcrtvtz.h" /* for error struct */
#include "qwcrsval.h"

#include <as400_protos.h>
#include <stdbool.h>

ILEpointer sysval_pgm __attribute__ ((aligned (16)));
bool sysval_initialized = false;

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
