#!/bin/bash

nasm -f elf64 -o is_palindrome.o is_palindrome.asm && \
  ld -m elf_x86_64 -o is_palindrome is_palindrome.o && \
  ./is_palindrome
