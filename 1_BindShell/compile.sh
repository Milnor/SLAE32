#!/bin/bash

PROJ_NAME="bind_shell"    # Default, to save me some typing!
if [ $# -gt 0 ]; then
    PROJ_NAME=$1
fi 

# First, build the hand-coded shellcode

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

# Second, compile the machine-generated version

mkdir -p build

if [ $? -eq 0 ]; then
    echo '[+] Created build directory'
else
    echo '[-] Failed to create build build directory'
    exit -1
fi

cd build

cmake -DBUILD_WITH_COVERAGE=on .. && make

#make lcov

if [ $? -eq 0 ]; then
    echo '[+] Built shellcode generator.'
else
    echo '[-] Failed to build shellcode generator'
    exit -1
fi

lcov --zerocounters --directory .

./bindshell 2345    # Port is configurable

lcov --directory . --capture --output-file coverage.info

genhtml coverage.info --output-directory out
