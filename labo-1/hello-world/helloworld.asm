%define SYS_WRITE 1
%define SYS_EXIT 60
section .text
global _start
_start:
mov rdx, len
mov rsi, msg
mov rdi, 1
mov rax, SYS_WRITE
syscall
mov rax, SYS_EXIT
mov rdi, 0
syscall
section .data
msg db 'Maximiliano Fisz 586/19',0xa, 'Gaspar Onesto De Luca 711/22', 0xa, 'Victoria Rauch 1181/21', 0xa, 'hola mundo!!!!!!!!!!'
len equ $ - msg
