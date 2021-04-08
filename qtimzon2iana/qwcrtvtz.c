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
