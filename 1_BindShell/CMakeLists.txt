cmake_minimum_required(VERSION 3.5)
project(bindshells)

# Shellcode Generator
add_executable(bindshell bindshell.c)

# Test the hand-written shellcode
add_executable(test1 call_shellcode.c)

# Test the configurable, generated shellcode
add_executable(test2 call_shellcode.c)

# I like code coverage info
set_target_properties(bindshell PROPERTIES 
        COMPILE_FLAGS "--coverage"
        LINK_FLAGS "--coverage")
 
target_compile_definitions(test1 PRIVATE HARDCODED)
target_compile_definitions(test2 PRIVATE CONFIGURABLE)
