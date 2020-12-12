#!/bin/bash

# First, build the hand-coded shellcode

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

# Second, compile the machine-generated version

mkdir -p build

if [ $? -eq 0 ]; then
    echo '[+] Created build directory'
else
    echo '[-] Failed to create build build directory'
    exit -1
fi

cd build

cmake .. && make

if [ $? -eq 0 ]; then
    echo '[+] Built shellcode generator.'
else
    echo '[-] Failed to build shellcode generator'
    exit -1
fi

./bindshell 2345    # Port is configurable
