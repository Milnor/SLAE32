global _start

section .text
_start:

	; 359 socket(AF_INET, SOCK_STREAM, 0); 
	; 	or do I need 102 (socketcall) on 32-bit? 


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
	
	
