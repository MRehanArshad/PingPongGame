[org 0x100]
jmp start
    pad1: dw 1760, 1920, 2080          ; value where pad1 should print
    pad2: dw 1918, 2078, 2238          ; value where pad2 should print
    ball: dw 2000                      ; value where ball will print
    direction: dw 1                    ; for setting the direction of ball
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

; ------------- Subroutine for printing the pad --------------
print_pads:
    pusha
    push es
    ; setting the value of es register
    push 0xb800
    pop es
    ; moving the value to print into ax
    mov ax, 0x0708
    ; moving the address of array that contain the location of pad1 into bx
    mov bx, pad1
    ; printing pad1
    mov di, [bx]
    stosw
    mov di, [bx+2]
    stosw
    mov di, [bx+4]
    stosw
    ; moving the address of array that contain the location of pad2 into bx
    mov bx, pad2
    ; printing pad2
    mov di, [bx]
    stosw
    mov di, [bx+2]
    stosw
    mov di, [bx+4]
    stosw
    ; for restoring the value of registers
    pop es
    popa
    ret

; ------------ Subroutine for printing the ball --------------------
direction1:
    sub word[ball], 159
    jmp print_ball_exit
direction2:
    add word[ball], 164
    jmp print_ball_exit
direction3:
    add word[ball], 156
    jmp print_ball_exit
direction4:
    sub word[ball], 164
    jmp print_ball_exit
print_ball:
    pusha
    push es
    ; setting the value of es
    push 0xb800
    pop es

    mov bx, ball    ; moving the address of variable that contain the location of ball
    mov di, [bx]    ; setting the value of di
    mov ax, 0x074F  ; moving the value to print into ax
    stosw           ; printing the ball on the screen
    cmp word[direction], 1  
    jz direction1
    cmp word[direction], 2
    jz direction2
    cmp word[direction], 3
    jz direction3
    cmp word[direction], 4
    jz direction4
    ; defining a label for the exit point of print_ball subroutine
    print_ball_exit:
    pop es
    popa
    ret
; ------------ Subroutine for printing the board --------------------
print_board:
    call clrscr             ; clearing the screen
    call print_pads         ; for printing the pads
    call print_ball         ; for printing the ball
    ret
start:
    call clrscr
    call print_board
mov ax, 0x4c00
int 0x21