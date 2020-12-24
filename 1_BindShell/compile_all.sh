#!/bin/bash

# First, build the non-configurable hand-coded shellcode
./compile.sh bind_shell

# Second, build the shellcode generator

mkdir -p build

if [ $? -eq 0 ]; then
    echo '[+] Created build directory'
else
    echo '[-] Failed to create build build directory'
    exit -1
fi

cd build

cmake -DBUILD_WITH_COVERAGE=on .. && make

if [ $? -eq 0 ]; then
    echo '[+] Built shellcode generator.'
else
    echo '[-] Failed to build shellcode generator'
    exit -1
fi

# Third, zero out code coverage stats
lcov --zerocounters --directory .

if [ $? -eq 0 ]; then
    echo '[+] Zeroed out lcov'
else
    echo '[-] Error. Is lcov installed?'
    exit -1
fi

# Fourth, set port if user specified one
PORT="8888"             # default value
if [ $# -gt 0 ]; then
    PORT=$1
fi

# Fifth, let the generator write a bind shell for Nasm
./bindshell $PORT       # port is configurable

# Sixth, generate HTML dashboard with code coverage statistics
lcov --directory . --capture --output-file coverage.info

# I should probably wrap this error handling into a 
#   function... later
if [ $? -eq 0 ]; then
    echo '[+] Generated code coverage statistics'
else
    echo '[-] Failed to run lcov'
    exit -1
fi

genhtml coverage.info --output-directory out

if [ $? -eq 0 ]; then
    echo '[+] Generated HTML dashboard'
else
    echo '[-] Failed to generate HTML'
    exit -1
fi

# Seventh, compile the machine-generated bind shell
../compile.sh temp


