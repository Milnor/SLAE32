cmake_minimum_required(VERSION 3.5)
project(bindshells VERSION "0.2.0") # WIP

# Shellcode Generator
add_executable(turtle src/turtle.c)

# Test the hand-written shellcode
add_executable(tester src/call_shellcode.c)

set_target_properties(turtle PROPERTIES 
        COMPILE_FLAGS "--coverage -fno-stack-protector -z execstack"
        LINK_FLAGS "--coverage")
 
