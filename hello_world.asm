global _start


section .text


_start:
	mov rax, 0x1
	mov rdi, 0x1
	mov rsi, message
	mov rdx, message_len
	syscall

	mov rax, 0x3C
	mov rdi, 0x0
	syscall



section .rodata


message: db "Hello world", 0xA
message_len: equ $ - message
