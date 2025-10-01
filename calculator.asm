section .data
	msg db "Enter any whole integer value: "
	len equ $-msg		; len = msg length

	opmsg db "Operation (e.g. add, sub, mult, div)? "
	opmsglen equ $-opmsglen

	aaddb db "a+b = " 	; a add b
	asubb db "a-b = " 	; a subtract b
	amulb db "a*b = " 	; a multiply b
	adivb db "a/b = " 	; a divide b

section .bss
	buffer_a resb 32	; 32 bytes per user input (e.g. 1...9 = 1byte, 10...99 = 2bytes, etc)
	buffer_b resb 32	; buffer for value b
	buffer_c resb 64	; output of the operations, c = a OP b

section .text
	global _start

_start:
	; integer a
	mov rax, 1		; syscall code 1 = write
	mov rdi, 1		; std out (write)
	mov rsi, msg		; msg to write to console ("Enter any whole integer value: ")
	mov rdx, len		; rdx is loaded with the length of msg
	syscall			; end syscall

	mov rax, 0		; syscall code 0 = read
	mov rdi, 0		; std input (read)
	mov rsi, buffer_a	; rsi pointer is loaded with buffer_a value
	mov rdx, 32		; rdx = 32
	syscall			; end syscall
	mov r10, rax		; r10 = number of bytes read from integer a

	; parse buffer_a -> r8
	xor r8, r8		; r8 = acculator
	xor rcx, rcx		; index = 0

parse_a: 			; parses ascii "n" into n, n = valueOf(a)
	cmp rcx, r10		; compares values in rcx and r10 (a)
	je done_parse_a		; je = jump if equal. jump if equal to done_parse_a
	movzx rax, byte [buffer_a + rcx] ; movzx = move zero-extending. adds 0s to fit register
	cmp rax, 10		; compares rax to new line (enter key)

	je done_parse_a
	sub rax, '0'		; rax = rax - '0'
	imul r8, r8, 10		; multiply r8, where r8 * 10
	add r8, rax		; r8 = r8 + rax
	inc rcx			; increment rcx by 1, rcx += 1
	jmp parse_a		; jump to parse_a function for all unresolved bytes

done_parse_a:
	; integer b
	mov rax, 1		; same thing again, msg is printed to console
	mov rdi, 1
	mov rsi, msg
	mov rdx, len
	syscall

	mov rax, 0
	mov rdi, 0
	mov rsi, buffer_b	; rsi pointer is loaded with buffer_b value
	mov rdx, 32
	syscall
	mov r11, rax		; r11 = n bytes for b

	; parse buffer_b -> r9
	xor r9, r9
	xor rcx, rcx

parse_b:			; parse ascii to integer
	cmp rcx, r11
	je done_parse_b
	movzx rax, byte [buffer_b + rcx]
	cmp rax, 10
	je done_parse_b
	sub rax, '0'
	imul r9, r9, 10
	add r9, rax
	inc rcx
	jmp parse_b
	
done_parse_b:
	; r8 = a, r9 = b

	mov rax, r8
	add rax, r9		; rax = a+b
	
	mov rcx, buffer_c 	; value of rcx is stored into buffer_c
	add rcx, 63		; pointers the end of buffer_c, because the digits are written backwards
	mov rbx, 10		; rbx / 10
	mov rsi, rcx		; save end for length calculation

.convert_loop:
	xor rdx, rdx		; clear the remainder
	div rbx			; divide rax by 10
	add dl, '0'		; convert buffer_c to ascii
	dec rcx
	mov [rcx], dl		; store digit
	test rax, rax		; if rax = 0, process if finished
	jnz .convert_loop
	
	mov rax, 1 
	mov rdi, 1 
	mov rsi, aaddb
	mov rdx, 6
	syscall

	mov rax, 1
	mov rdi, 1
	mov rdx, rsi
	mov rbx, buffer_c
	add rbx, 64
	sub rdx, rcx
	syscall

	mov rax, 60		; exit syscall code
	xor rdi, rdi		; ensures that the status = 0 (e.g. return 0)
	syscall


