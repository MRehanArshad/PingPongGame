[org 0x100]
jmp start

start:

mov ax, 0x4c00
int 0x21

; Adding Changes