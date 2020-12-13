cmake_minimum_required(VERSION 3.5)
project(bindshell)
add_executable(bindshell bindshell.c)

set_target_properties(bindshell PROPERTIES 
        COMPILE_FLAGS "--coverage"
        LINK_FLAGS "--coverage")
 
