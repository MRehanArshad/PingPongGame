[org 0x100]
jmp start

; ------------- Subroutine for clearing the screen ---------------
clrscr:
    push bp             
    mov bp, sp
    pusha                   ; pushing all register into the stack
    push es                 ; for storing the previous value of es
    ; for setting the value of es
    push 0xb800             
    pop es
    mov di, 0               ; setting the value of destination index
    mov cx, 2000            ; setting the counter for the rep
    mov ax, 0x0720          ; storing the I want to display on the console
    rep stosw               ; for moving value of ax into es:di 
    ; Restoring value of the register
    pop es
    popa
    mov sp, bp
    pop bp
    ret

start:
    call clrscr
mov ax, 0x4c00
int 0x21