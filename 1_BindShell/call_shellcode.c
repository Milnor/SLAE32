#include <stdio.h>
#include <string.h>

#ifdef HARDCODED
    #include "hardcoded.h"
#endif /* HARDCODED */

#ifdef CONFIGURABLE
    #include "configurable.h"
#endif /* CONFIGURABLE */

// Shellcode 'code' is provided via a header file

int main(int argc, char ** argv)
{
	printf("[+] Testing bind shell of %u bytes\n", strlen(code));

	int (*ret)() = (int(*)())code;

        ret();
}

