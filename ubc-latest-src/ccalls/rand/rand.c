#include "rand.h"

int xrandom(void)
{
	return random();
}

void xsrandom(int i)
{
	(void) srandom((unsigned) i);
}
