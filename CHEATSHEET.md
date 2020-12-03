# Cheat Sheet for 32-bit x86 Shellcode

## man 2 syscall
### SYS\_xxx Definitions
- ```#include <sys/syscall.h>```
### Calling Conventions and ABI for i386
- **int $0x80** instruction 
- **eax** syscall number
- **eax** retval
- **arguments 1-6** - ebx, ecx, edx, esi, edi, ebp

## Syscall Numbers

### Finding Them 
- ```cat /usr/include/i386-linux-gnu/asm/unistd_32.h | grep bind```

### Common Ones in x86
-   1 exit
-   3 read
-   4 write
-  11 execve
-  63 dup2
- 102 socketcall
- 359 socket
- 360 socketpair
- 361 bind
- 362 connect
- 363 listen
- 364 accept4
## Useful Constants 

### Constants */usr/include/i386-linux-gnu/bits/socket.h*
0 |  PF\_UNSPEC | AF\_UNSPEC
1 | PF\_LOCAL   | PF\_UNIX   | AF\_UNIX
2 | PF\_INET    | AF\_INET   
10| PF\_INET6   | AF\_INET6

## Constants in */usr/include/i386-linux-gnu/bits/socket_type.h*
- 1 SOCK\_STREAM
- 2 SOCK\_DGRAM

## Constants in */usr/include/netinet/in.h*
- INADDR\_ANY ((in\_addr\_t) 0x00000000)
