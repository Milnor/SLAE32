# Cheat Sheet for 32-bit x86 Shellcode

## man 2 syscall
### SYS\_xxx Definitions
- ```#include <sys/syscall.h>```
### Calling Conventions and ABI for i386
- **int $0x80** instruction 
- **eax** syscall number
- **eax** retval
- **arguments 1-6** - ebx, ecx, edx, esi, edi, ebp
### Libc Instead of Syscalls
- declare ```extern printf``` (or whatever functions you want) 
- ```main``` instead of ```_start```
- push arguments onto stack in *reverse* order
- ```CALL printf```
- align the stack after function call, e.g. ```add esp, 0x4```
- link with **gcc** instead of **ld**

## Syscall Numbers

### Finding Them 
- ```cat /usr/include/i386-linux-gnu/asm/unistd_32.h | grep bind```

### Common Ones in x86
| #  | syscall      |
|--: | ----------   |
|   1| exit         |
|   3| read         |
|   4| write        |
|  11| execve       |
|  63| dup2         |
| 102| socketcall   |
| 359| socket       |
| 360| socketpair   |
| 361| bind         |
| 362| connect      |
| 363| listen       |
| 364| accept4      |

## Useful Constants 

### Constants */usr/include/i386-linux-gnu/bits/socket.h*
| # | MACRO       | MACRO      | MACRO    |
|--:| ---------   | ---------- | -------  |
| 0 |  PF\_UNSPEC | AF\_UNSPEC |          |
| 1 |  PF\_LOCAL  | PF\_UNIX   | AF\_UNIX |
| 2 |  PF\_INET   | AF\_INET   |          |
| 10|  PF\_INET6  | AF\_INET6  |          |

## Constants in */usr/include/i386-linux-gnu/bits/socket_type.h*
| # | MACRO       |
|--:| ---------   |
| 1 | SOCK\_STREAM|
| 2 | SOCK\_DGRAM |

## Constants in */usr/include/netinet/in.h*
| MACRO       | Definition                |
| --------    | -------------             |
| INADDR\_ANY | ((in\_addr\_t) 0x00000000)|

## Compiling and Linking Shellcode

### GCC flags
- ```-fno-stack-protector```
- ```-z execstack``` pass *execstack* keyword to linker

## Carving hex strings from binary

### Azeria's Method
- ```objcopy -O binary bind_shell bind_shell.bin```
- ```hexdump -v -e '"\\""x" 1/1 "%02x" ""' bind_shell.bin```

### Vivek's Method
- TODO: rewatch that video and add

## Working with Strings

### Paths
Extraneous slashes don't matter!
- ```/bin/sh``` and ```//bin/sh```
- This is convenient for padding to a particular byte boundary

### Converting to Little Endian Hex Values
- Python 3
```
>>> code = 'Hello, World!'
>>> reversed = code[::-1]
>>> print(reversed)
!dlroW ,olleH
>>> reversed.encode("utf-8").hex()
'21646c726f57202c6f6c6c6548'
```
- Python 2
```
>>> code = 'Hi there :)'
>>> reversed = code[::-1]
>>> reversed.encode("hex")
'293a206572656874206948'
```

## XOR Encoding/Decoding
- XOR once with a value to encode; XOR again with the same value to decode
- Note: Do not use a byte occurring in your code already as the XOR value or you will introduce NULL(s)
