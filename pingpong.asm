[org 0x100]
jmp start
; ---- Data Variables ----
pad1: dw 1764, 1924, 2084          ; value where pad1 should print
pad1_x: db 11, 12, 13
pad2: dw 1916, 2076, 2236          ; value where pad2 should print
pad2_x: db 11, 12, 13
ballx: db 12
bally: db 40
ball: db 'O', 0
toxpositive: db 0                  ; for x in positive flag 
toypositive: db 1                  ; for x in negative flag 
scoreL: db 0                       ; Score for left player
scoreR: db 0                       ; Score for Right Player
scorediL: dw 3690                   ; di for score L 
scorediR: dw 3828                   ; di for score R 
pausegame: db 0                    ; pausegame flag 
CollisionPad: db 0
pattern_flag: db 0
pattern_di: dw 0
previous_segment: dw 0
previous_ip: dw 0

membername1: db 'RehanArshad 23F-3098', 0
m1_len: dw 20
membername2: db 'FaizanRizwan 23F-3057', 0
m2_len: dw 21
reset: db 'Press R to restart and E to exit!', 0
size_reset: dw 33
Player1: db 'Player 1 Won !!!!', 0
length1: dw 17
Player2: db 'Player 2 Won !!!!', 0
length2: dw 17
restart_flag: db 0
exit_flag: db 0

;----- Pattern Printing 
pattern:
    pusha
    push 0xb800
    pop es
    mov bx, 1            ;Check for Ball
    mov dx, 1942
    mov di, [pattern_di]

        mov cx, dx
        print:
            mov ax, [es:di]

            cmp ah, 0xFF            ;Wall
            jz skip_print
            cmp ah, 0x6F            ;Pad 1
            jz skip_print
            cmp ah, 0x3F            ;Pad 2
            jz skip_print
            cmp ah, 0x04         ;Ball ASCII
            jz skip_print
            cmp ah, 0x72
            jz skip_print
            mov word[es:di], 0x012A
            skip_print:
            add di, 166
            loop print

        cmp byte[pattern_flag], 0
        jz skip_add

        add word[pattern_di], 2
        skip_add:
        cmp word[pattern_di], 158
        jl continue
        mov word[pattern_di], 0
        continue:
    popa
    ret

; ---- For printing the string ----
printstr:
push bp
mov bp, sp
pusha
push es

push 0xb800
pop es

mov cx, [bp+4]
mov si, [bp+6]
mov ax, [bp+8]
next:

lodsb
stosw
loop next
pop es
popa
mov sp, bp
pop bp
ret 6

UpArrowKey:
cmp word[pad2], 636
jl nomatch1
sub word[pad2], 160
sub word[pad2+2], 160
sub word[pad2+4], 160
sub byte[pad2_x], 1
sub byte[pad2_x + 1], 1
sub byte[pad2_x + 2], 1
jmp nomatch1

DownArrowKey:
cmp word[pad2+4], 3518
jg nomatch1
add word[pad2], 160
add word[pad2+2], 160
add word[pad2+4], 160
add byte[pad2_x], 1
add byte[pad2_x + 1], 1
add byte[pad2_x + 2], 1
jmp nomatch1

; ---- For Movement in the pads ----

pattern_pause:
    xor byte[pattern_flag], 1
    jmp nomatch1

nomatch1:
    jmp nomatch

kbisr:        
push ax 
push es

mov  ax, 0xb800 
mov  es, ax             ; point es to video memory 
in   al, 0x60           ; read a char from keyboard port 
cmp al, 0x19
je pattern_pause
cmp  al, 0x11           ; is the key 'W'
je Wkey
cmp al, 0x1F            ; is the key 'S'
je Skey
cmp al, 0x48            ; is down arrow
je UpArrowKey  
cmp al, 0x50            ; is UP arrow
je DownArrowKey
cmp al, 0x1C            ; is ENTER key
je Gamepause1
cmp al, 0x13            ; is the key 'R'
je Reset_1
cmp al, 0x12            ; is the key 'E'
je end_game

nomatch:      
mov  al, 0x20           ; Send EOI to PIC
out  0x20, al
pop  es
pop  ax
iret

end_game:
mov byte[exit_flag], 1
jmp nomatch    

Wkey:
cmp word[pad1], 482
jl nomatch
sub word[pad1], 160
sub word[pad1+2], 160
sub word[pad1+4], 160
sub byte[pad1_x], 1
sub byte[pad1_x + 1], 1
sub byte[pad1_x + 2], 1
jmp nomatch

Reset_1:
    jmp Reset2
Gamepause1:
    jmp Gamepause

Skey:
cmp word[pad1+4], 3520
jg nomatch
add word[pad1], 160
add word[pad1+2], 160
add word[pad1+4], 160
add byte[pad1_x], 1
add byte[pad1_x + 1], 1
add byte[pad1_x + 2], 1
jmp nomatch

Gamepause:
xor byte[pausegame], 1
jmp nomatch    



; ---- For clearing the Screen ----
clrscr:
push bp             
mov bp, sp
pusha                      ; pushing all register into the stack
push es                    ; for storing the previous value of es
; for setting the value of es
push 0xb800             
pop es
mov di, 318
mov dx, 21
clrscr_loop:
add di, 6                 ; setting the value of destination index
mov cx, 77                ; setting the counter for the rep
mov ax, 0x0720
repne stosw
dec dx
jnz clrscr_loop

; Restoring value of the register
pop es
popa
mov sp, bp
pop bp
ret


; ---- For Printing the Wall ----
printWall:
push bp
mov bp, sp
pusha
push es

push 0xb800
pop es
mov ax, 0xFF20
mov di, 0
mov cx, 2000
rep stosw

pop es
popa
mov sp, bp
pop bp
ret

; -------- Collision checking routine
padCollision1:
    mov dl, [ballx]
    cmp dl, [pad1_x]
    jz collide1
    cmp dl, [pad1_x + 1]
    jz collide1
    cmp dl, [pad1_x + 2]
    jz collide1
    mov byte[CollisionPad], 1
    ret
    collide1:
        mov byte[CollisionPad], 0
        ret
padCollision2:
    mov dl, [ballx]
    cmp dl, [pad2_x]
    jz collide2
    cmp dl, [pad2_x + 1]
    jz collide2
    cmp dl, [pad2_x + 2]
    jz collide2
    mov byte[CollisionPad], 1
    ret
    collide2:
        mov byte[CollisionPad], 0
        ret

Reset2:
    jmp Reset3

;---- New Game 
newGame:

mov di, 2280
push 0x0700
push reset
push word[size_reset]
call printstr
restart_prompt:
cmp byte[restart_flag], 1
jz exit_loop
cmp byte[exit_flag], 1
jz exit_loop2
jmp restart_prompt
exit_loop:
mov byte[restart_flag], 0
jmp start
exit_loop2:
    mov ax, 0
    mov es, ax
    mov ax, word[previous_ip]
    mov word[es:9*4], ax
    mov ax, word[previous_segment]
    mov word[es:9*4+2], ax
    jmp endProgram
; ---- Player 1 Wins ----
player1Wins:
pusha
mov di, 1980
push 0x0700
push Player1
push word[length1]
call printstr
popa
call newGame
; ---- Player 2 Wins ----
player2Wins:
pusha
mov di, 1980
push 0x0700
push Player2
push word[length2]
call printstr
popa
call newGame

; ----- player 1 score
p1_score:
    add byte[scoreL], 1
    cmp byte[scoreL], 9
    je player1Wins
    skipadd_L:
    jmp resetBallLocation
; ----- player 2 score
p2_score:
    add byte[scoreR], 1
    cmp byte[scoreR], 9
    je player2Wins
    skipadd_R:
    jmp resetBallLocation

; ----- Different Case of Collision
UpCollision:
mov byte[toxpositive], 1
jmp exit_checkCollision

DownCollision:
mov byte[toxpositive], 0
jmp exit_checkCollision

LeftCollision:
mov byte[toypositive], 1
call padCollision1
cmp byte[CollisionPad], 0
jz exit_checkCollision
jmp p2_score

RightCollision:
mov byte[toypositive], 0
call padCollision2
cmp byte[CollisionPad], 0
jz exit_checkCollision
jmp p1_score

resetBallLocation:
call delay
call delay
call delay
mov byte[ballx], 12
mov byte[bally], 40
jmp exit_checkCollision

; ----- For checking Collision with the balls -----
checkCollision:
push bp

cmp byte[ballx], 2
jle UpCollision
cmp byte[ballx], 22
jge DownCollision
cmp byte[bally], 4
jle LeftCollision
cmp byte[bally], 76
jge RightCollision
exit_checkCollision:
pop bp
ret


; ----- For Adding x and y ------
xpositive:
add byte[ballx], 1
ret
xnegative:
sub byte[ballx], 1
ret
ypositive:
add byte[bally], 2
ret
ynegative:
sub byte[bally], 2
ret

Xispositive:
call xpositive
jmp Addxy_checky
Yispositive:
call ypositive
jmp Addxy_exit

Reset3
    jmp Reset_Tag

Addxy:
pusha
cmp byte[toxpositive], 1
je Xispositive
call xnegative
Addxy_checky:
cmp byte[toypositive], 1
je Yispositive
call ynegative
Addxy_exit: 
popa
ret

; ----- For updating the value of x and y -----
updatexyForball:
call checkCollision
call Addxy
ret

; ----- For displaying the ball -----
displayBall:
pusha
push es

mov  ah, 0x13           ; service 13 - print string 
mov  al, 0              ; subservice 01 – update cursor 
mov  bh, 0              ; output on page 0 
mov  bl, 2              ; normal attrib 
mov  dh, byte[ballx]
mov dl, byte[bally] 
mov  cx, 1              ; length of string 
push cs 
pop  es                 ; segment of string  
mov  bp, ball           ; offset of string  
int  0x10               ; call BIOS video service 

call updatexyForball

pop es
popa
ret

; ---- For displaying the pad ----
displayPads:
pusha
push es

push 0xb800                ; setting the value of es register
pop es
mov ax, 0x6F20             ; moving the value to print into ax
mov bx, pad1               ; moving the address of array that contain the location of pad1 into bx 
mov di, [bx]               ; printing pad1 
stosw
mov di, [bx+2]
stosw
mov di, [bx+4]
stosw
mov ax, 0x3F20             ; moving the address of array that contain the location of pad2 into bx 
mov bx, pad2
mov di, [bx]
stosw
mov di, [bx+2]
stosw
mov di, [bx+4]
stosw

pop es
popa
ret

; ---- For displaying the Score -----
displayScore:
pusha
push es

push 0xb800
pop es
mov di, word[scorediL]  ; for pointing di to appropiate location
mov ah, 0x72 
mov al, byte[scoreL]
add al, 0x30
stosw
mov di, word[scorediR]  ; for pointing di to appropiate location
mov ah, 0x72
mov al, byte[scoreR]
add al, 0x30
stosw
pop es
popa
ret

printBoard:
call displayBall
call displayPads
call displayScore
ret

; ---- For adding some delay ----
delay:
pusha
mov ax, 0
mov cx, 0xFFFF
delay_label:
loop delay_label
popa
ret

;----- Resets the whole game values to restart the game
Reset_Tag:
    pusha

    mov word[pad1], 1764
    mov word[pad1 + 2], 1924
    mov word[pad1 + 4], 2084          ; value where pad2 should print
    mov byte[pad1_x], 11
    mov byte[pad1_x+1], 12
    mov byte[pad1_x+2], 13
    mov word[pad2], 1916
    mov word[pad2 + 2], 2076
    mov word[pad2 + 4], 2236          ; value where pad2 should print
    mov byte[pad2_x], 11
    mov byte[pad2_x+1], 12
    mov byte[pad2_x+2], 13
    mov byte[ballx], 12
    mov byte[bally], 40
    mov byte[toxpositive], 0                  ; for x in positive flag 
    mov byte[toypositive], 1                  ; for x in negative flag 
    mov byte[scoreL],0                       ; Score for left player
    mov byte[scoreR], 0                       ; Score for Right Player
    mov word[scorediL],3690                   ; di for score L 
    mov word[scorediR], 3828                   ; di for score R 
    mov byte[pausegame],0                    ; pausegame flag 
    mov byte[CollisionPad], 0
    mov byte[pattern_flag], 0
    mov word[pattern_di], 0
    mov byte[restart_flag], 1               ;To restart the game
    popa
    mov  al, 0x20           ; Send EOI to PIC
    out  0x20, al
    pop  es
    pop  ax
    iret


; ---- This is Start Label ----
start:
mov di, 1960
call printWall
push 0x7400
push membername1
push word[m1_len]
call printstr
push 0x7400
mov di, 2120
push membername2
push word[m2_len]
call printstr
mov ah, 0
int 0x16

xor ax, ax 
mov es, ax             ; point es to IVT base 
cli                     ; disable interrupts 
mov bx, previous_ip
mov ax, word[es:9*4]
mov word[bx], ax
mov bx, previous_segment
mov ax, word[es:9 * 4 + 2]
mov word[bx], ax

mov  word [es:9*4], kbisr ; store offset at n*4 
mov  [es:9*4+2], cs     ; store segment at n*4+2 
sti                     ; enable interrupts
start_loop:
cmp byte[pausegame], 1
jz start_loop
call clrscr
call pattern
call printBoard
call delay
call delay
call delay
jmp start_loop

endProgram:
mov ax, 0x4c00
int 0x21