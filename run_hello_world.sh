#!/bin/bash

nasm -f elf64 -o hello_world.o hello_world.asm && \
  ld -m elf_x86_64 -o hello_world hello_world.o && \
  ./hello_world
