#!/bin/bash

nasm -f elf32 -o $1.o $1.nasm

if [ $? -eq 0 ]; then
    echo '[+] Assembled with Nasm ... '
else
    echo '[-] Assembly failed.'
    exit -1
fi

ld -o $1 $1.o

if [ $? -eq 0 ]; then
    echo '[+] Linking successful.'
else
    echo '[-] Linking failed.'
    exit -1
fi

