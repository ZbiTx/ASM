section .data
	msg db "Counting down: "
	len equ $-msg
	nl db 0xA
	count db 5

section .bss
	coutn resb 1

section .text
	global _start

_start:

loop_start:
	mov rax, 1
	mov rdi, 1
	mov rsi, msg
	mov rdx, len
	syscall

	movzx rax, byte [count]
	cmp rax, 0
	je loop_end
	
	add al, '0'
	mov [rsp-1], al
	mov rax, 1
	mov rdi, 1
	lea rsi, [rsp-1]
	mov rdx, 1
	syscall

	mov rax, 1
	mov rdi, 1
	mov rsi, nl
	mov rdx, 1
	syscall

	dec byte [count]
	jmp loop_start

loop_end:
	mov rax, 1
	mov rdi, 1
	mov rsi, nl
	mov rdx, 1
	syscall

	mov rax, 60
	xor rdi, rdi
	syscall
