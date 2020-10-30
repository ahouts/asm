global _start


section .text


_start:
	; reserve stack space
	sub rsp, start_stack_size

	; display prompt
	mov rdi, sys_stdout
	mov rsi, enter_string
	mov rdx, enter_string_len
	call write

	; allocate a buffer to store the response
	mov rsi, response_buffer_size
	call malloc
	mov [rsp+start_alloc_offset], rax

	; read user input
	mov rsi, [rsp+start_alloc_offset]
	mov rdx, response_buffer_size
	call read

	; get the length of the user input string
	mov rax, [rsp+start_alloc_offset]
	mov rdi, response_buffer_size
	call strlen
	mov [rsp+start_strlen_offset], rax

	; check if the user input is a palindrome
	mov rax, [rsp+start_alloc_offset]
	mov rdi, [rsp+start_strlen_offset]
	call is_palindrome
	mov [rsp+start_is_palindrome_offset], rax

	; print the user input
	mov rdi, sys_stdout
	mov rsi, [rsp+start_alloc_offset]
	mov rdx, [rsp+start_strlen_offset]
	call write

	; print is
	mov rdi, sys_stdout
	mov rsi, response_is
	mov rdx, response_is_len
	call write

	; check if it is a palindrome
	mov rax, [rsp+start_alloc_offset]
	mov rdi, [rsp+start_strlen_offset]
	call is_palindrome
	mov [rsp+start_is_palindrome_offset], rax

	; skip printing not if it is a palindrome
	cmp rax, 1
	je _start_a_palindrome

	; print not
	mov rdi, sys_stdout
	mov rsi, response_not
	mov rdx, response_not_len
	call write

_start_a_palindrome:

	; print a palindrome
	mov rdi, sys_stdout
	mov rsi, response_a_palindrome
	mov rdx, response_a_palindrome_len
	call write

	; free the response buffer
	mov rdi, [rsp+start_alloc_offset]
	mov rsi, response_buffer_size
	call free

	; release stack space
	add rsp, start_stack_size

	; exit
	mov rdi, 0
	call exit

; IN
;   rsi: buffer
;   rdx: length
read:
	mov rax, sys_read
	mov rdi, sys_stdin
	syscall
	ret

; IN
;   rdi: file descriptor
;   rsi: message
;   rdx: length
write:
	mov rax, sys_write
	syscall
	ret

; IN
;   rdi: exit code
exit:
	mov rax, sys_exit
	syscall

; IN
;   rsi: length
; OUT
;   rax: address
malloc:
	mov rax, sys_mmap
	mov rdi, 0x0
	mov rdx, mem_prot_read_write
	mov r10, mem_map_private_anon
	mov r8, 0xFFFFFFFFFFFFFFFF
	mov r9, 0x0
	syscall
	ret

; IN
;   rdi: address
;   rsi: length
free:
	mov rax, sys_munmap
	syscall

	; check for errors
	cmp rax, 0x0
	je free_exit

	; display error message
	mov rdi, sys_stderr
	mov rsi, error_freeing
	mov rdx, error_freeing_len
	call write
free_exit:
	ret

; IN
;   rax: buffer
;   rdi: length
; OUT
;   rax: length
strlen:
	mov r9, 0
strlen_loop:
	cmp r9, rdi
	jge strlen_exit

	mov r8, rax
	add r8, r9

	cmp byte [r8], 0x00
	je strlen_exit

	cmp byte [r8], 0x0A
	je strlen_exit

	inc r9
	jmp strlen_loop
strlen_exit:
	mov rax, r9
	ret

; IN
;   rax: buffer
;   rdi: length
; OUT
;   rax: 1 if a palindrome, 0 otherwise
is_palindrome:
	mov r9, rax
	add r9, rdi
	dec r9
is_palindrome_loop:
	cmp rax, r9
	jge is_palindrome_exit_yes

	mov dl, byte [rax]
	cmp dl, byte [r9]
	jne is_palindrome_exit_no

	inc rax
	dec r9

	jmp is_palindrome_loop
is_palindrome_exit_yes:
	mov rax, 1
	ret
is_palindrome_exit_no:
	mov rax, 0
	ret

section .rodata


start_alloc_offset: equ 0
start_strlen_offset: equ start_alloc_offset + 8
start_is_palindrome_offset: equ start_strlen_offset + 8
start_stack_size: equ start_is_palindrome_offset + 8

enter_string: db "Please enter a string: "
enter_string_len: equ $ - enter_string

error_freeing: db "There was an error freeing memory", 0xA
error_freeing_len: equ $ - error_freeing

response_is: db " is "
response_is_len: equ $ - response_is

response_not: db "not "
response_not_len: equ $ - response_not

response_a_palindrome: db "a palindrome", 0xA
response_a_palindrome_len: equ $ - response_a_palindrome

response_buffer_size: equ 0x100

sys_read: equ 0x0
sys_write: equ 0x1
sys_exit: equ 0x3C
sys_mmap: equ 0x9
sys_munmap: equ 0xB

sys_stdin: equ 0x0
sys_stdout: equ 0x1
sys_stderr: equ 0x2

mem_prot_read_write: equ 0x3
mem_map_private_anon: equ 0x22
