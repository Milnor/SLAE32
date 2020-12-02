#include <stdio.h>
#include <string.h>
#include "shellcode.h"

int main(int argc, char ** argv)
{
	printf("[+] Testing bind shell of %lu bytes\n", strlen(code));

	int (*ret)() = (int(*)())code;

        ret();
}

