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
