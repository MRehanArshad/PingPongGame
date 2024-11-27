[org 0x100]
jmp start
    pad1: dw 1760, 1920, 2080          ; value where pad1 should print
    pad2: dw 1918, 2078, 2238          ; value where pad2 should print
    ball: dw 2000                      ; value where ball will print
    direction: dw 1                    ; for setting the direction of ball
    leftCollision: db 0
    RightCollision: db 0
    UpCollision: db 0
    DownCollision: db 0
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
    mov ax, 0x7720
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

; ---- Subroutine for checking the collision of the ball with any pad or wall ----
Left:
    mov byte[leftCollision], 1
    mov byte[RightCollision], 0
    mov byte[UpCollision], 0
    mov byte[DownCollision], 0
    jmp return_true
Right:
    mov byte[leftCollision], 0
    mov byte[RightCollision], 1
    mov byte[UpCollision], 0
    mov byte[DownCollision], 0
    jmp return_true
Up:
    mov byte[leftCollision], 0
    mov byte[RightCollision], 0
    mov byte[UpCollision], 1
    mov byte[DownCollision], 0
    jmp return_true
Down:
    mov byte[leftCollision], 0
    mov byte[RightCollision], 0
    mov byte[UpCollision], 0
    mov byte[DownCollision], 1
    jmp return_true
return_true:
    mov word[bp+4], 1
    jmp exit_check_collision
check_collision:
    push bp
    mov bp, sp
    pusha               ; pushing value of all registers
    push es
    ; setting value of es 
    push ds
    pop es
    mov di, pad1
    mov ax, word[ball]  ; moving the value of ball into ax
    mov cx, 3
    repne scasw         ; for comparing the array of pad1 with ax
    jz Right             ; jump to return true 
    mov di, pad2
    mov cx, 3
    repne scasw         ; for comparing the array of pad2 with ax
    jz Left
    cmp ax, 160           ; for checking the collision with top wall
    jle Up
    cmp ax, 3840        ; for checking the collision with bottom wall
    jge Down
    mov dx, 0
    sub ax, 156
    mov bx, 160
    div bx
    cmp dx, 0
    jz Right
    mov dx, 0
    mov ax, word[ball]
    mov bx, 160
    div bx
    cmp dx, 0
    jz Left
    mov word[bp+4], 0       ; return false
    exit_check_collision:
    pop es
    popa                ; restoring value of all registers
    mov sp, bp
    pop bp
    ret

; ------------ Subroutine for changing the direction of the ball ------------
Novelty1:
    cmp byte[RightCollision], 1
    jnz setDirectionInc
    mov word[direction], 4
    jmp setDirection_exit
Novelty2:
    cmp byte[DownCollision], 1
    jnz setDirectionInc
    mov word[direction], 1
    jmp setDirection_exit 
Novelty3:
    cmp byte[leftCollision], 1
    jnz setDirectionInc
    mov word[direction], 2
    jmp setDirection_exit
Novelty4:
    cmp byte[UpCollision], 1
    jnz for4
    mov word[direction], 3
    jmp setDirection_exit
setDirection:
    cmp word[direction], 1
    jz Novelty1
    cmp word[direction], 2
    jz Novelty2
    cmp word[direction], 3
    jz Novelty3
    cmp word[direction], 4
    jz Novelty4
    for4:
        mov word[direction], 0
    setDirectionInc:
        add word[direction], 1
    setDirection_exit:
    jmp changDirection_exit
changDirection:
    push bp
    mov bp, sp
    pusha

    cmp word[bp+4], 1
    jz setDirection

    changDirection_exit:
    popa
    mov sp, bp
    pop bp
    ret

; ------------ Subroutine for printing the ball --------------------
direction1:
    push bp
    mov bp, sp
    sub word[ball], 156
    sub sp, 2
    call check_collision
    call changDirection 
    mov sp, bp
    pop bp
    jmp print_ball_exit
direction2:
    push bp
    mov bp, sp
    add word[ball], 164
    sub sp, 2
    call check_collision
    call changDirection
    mov sp, bp
    pop bp
    jmp print_ball_exit
direction3:
    push bp
    mov bp, sp
    add word[ball], 156
    sub sp, 2
    call check_collision
    call changDirection
    mov sp, bp
    pop bp
    jmp print_ball_exit
direction4:
    push bp
    mov bp, sp
    sub word[ball], 164
    sub sp, 2
    call check_collision
    call changDirection
    mov sp, bp
    pop bp
    jmp print_ball_exit
print_ball:
    push bp
    mov bp, sp
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
    mov sp, bp
    pop bp
    ret

; --------- for Introducing some delay in the function ----------
delay:
    pusha
    mov ax, 0
    mov cx, 0xFFFF
    delay_label:
    inc ax
    cmp ax, 0xFFFF
    jnz delay_label
    popa
    ret

; ------------ Subroutine for printing the board --------------------
print_board:
    call clrscr             ; clearing the screen
    call print_pads         ; for printing the pads
    call print_ball         ; for printing the ball
    call delay              ; for introducing some delay
    ret
start:
    call clrscr
    call print_board
    jmp start
mov ax, 0x4c00
int 0x21