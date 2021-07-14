//#include "shellcode.h"

#include <stdio.h>
#include <string.h>

// TODO: replace "code" once shellcode.h is generated
char code[] = { 0xeb, 0xfe };

int main(int argc, char ** argv)
{
	printf("[+] Testing bind shell of %u bytes\n", strlen(code));

	int (*ret)() = (int(*)())code;

        ret();
}

