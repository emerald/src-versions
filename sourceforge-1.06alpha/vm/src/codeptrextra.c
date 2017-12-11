#include <stdlib.h>
#include <stdio.h>

typedef unsigned int word;

int main( int argc, char **argv )
{
	int old_size = 2 * 1024 * 1024;
	static word *old_start;
	old_start = (word *) malloc (old_size);
	printf("%#x",(int) old_start &  0xfc000000);
	free(old_start);
}
