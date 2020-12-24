#!/bin/bash

PROJ_NAME="bind_shell"    # Default, to save me some typing!
if [ $# -gt 0 ]; then
    PROJ_NAME=$1
fi 

nasm -f elf32 -o $PROJ_NAME.o $PROJ_NAME.nasm

if [ $? -eq 0 ]; then
    echo '[+] Assembled with Nasm ... '
else
    echo '[-] Assembly failed.'
    exit -1
fi

ld -o $PROJ_NAME $PROJ_NAME.o

if [ $? -eq 0 ]; then
    echo '[+] Linking successful.'
else
    echo '[-] Linking failed.'
    exit -1
fi

