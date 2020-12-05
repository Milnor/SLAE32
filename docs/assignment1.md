# WIP

## Assignment 1 - Bind Shell

Writing unobfuscated shellcode in x86 assembly is straightforward. It consists of moving the appropriate values into registers for a series of system calls. A quick ```man 2 syscall``` reveals the calling convention and Application Binary Interface (ABI). However, a few issues require some forethought: 
1. Avoiding null bytes (0x00) or other bad characters if needed
    - XOR a register with itself to zero it out, e.g. ```xor eax, eax```
    - Write to 8- or 16-bit registers to avoid leading zeros, e.g. ```mov al, 10```
2. Building a *sockaddr* struct on the stack
3. Strings, because our code is position independent
