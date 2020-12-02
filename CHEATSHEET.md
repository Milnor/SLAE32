# Cheat Sheet for 32-bit x86 Shellcode

## man 2 syscall
### SYS\_xxx Definitions
- ```#include <sys/syscall.h>```
### Calling Conventions and ABI for i386
- **int $0x80** instruction 
- **eax** syscall number
- **eax** retval
- **arguments 1-6** - ebx, ecx, edx, esi, edi, ebp

## Find a syscall number
- ```cat /usr/include/i386-linux-gnu/asm/unistd_32.h | grep bind```
