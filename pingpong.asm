[org 0x100]
jmp start
; ---- Data Variables ----
pad1: dw 1764, 1924, 2084          ; value where pad1 should print
pad2: dw 1916, 2076, 2236          ; value where pad2 should print
ballx: db 12
bally: db 40
ball: db 'O', 0
toxpositive: db 0                  ; for x in positive flag 
toypositive: db 1                  ; for x in negative flag 
scoreL: db 0                       ; Score for left player
scoreR: db 0                       ; Score for Right Player
scorediL: dw 330                   ; di for score L 
scorediR: dw 468                   ; di for score R 
pausegame: db 0                    ; pausegame flag 

; ---- For Movement in the pads ----

kbisr:        
push ax 
push es

mov  ax, 0xb800 
mov  es, ax             ; point es to video memory 
in   al, 0x60           ; read a char from keyboard port 
cmp  al, 0x11           ; is the key 'W'
je Wkey
cmp al, 0x1F            ; is the key 'S'
je Skey
cmp al, 0x48            ; is down arrow
je UpArrowKey  
cmp al, 0x50            ; is UP arrow
je DownArrowKey
cmp al, 0x1C            ; is ENTER key
je Gamepause
nomatch:      
mov  al, 0x20           ; Send EOI to PIC
out  0x20, al
pop  es
pop  ax
iret

Wkey:
cmp word[pad1], 482
jl nomatch
sub word[pad1], 160
sub word[pad1+2], 160
sub word[pad1+4], 160
jmp nomatch

Skey:
cmp word[pad1+4], 3520
jg nomatch
add word[pad1], 160
add word[pad1+2], 160
add word[pad1+4], 160
jmp nomatch

UpArrowKey:
cmp word[pad2], 636
jl nomatch
sub word[pad2], 160
sub word[pad2+2], 160
sub word[pad2+4], 160
jmp nomatch

DownArrowKey:
cmp word[pad2+4], 3518
jg nomatch
add word[pad2], 160
add word[pad2+2], 160
add word[pad2+4], 160
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

; ----- Different Case of Collision
UpCollision:
mov byte[toxpositive], 1
jmp exit_checkCollision
DownCollision:
mov byte[toxpositive], 0
jmp exit_checkCollision
LeftCollision:
mov byte[toypositive], 1
jmp exit_checkCollision
RightCollision:
mov byte[toypositive], 0
jmp exit_checkCollision
; ----- For checking Collision with the balls -----
checkCollision:
push bp

cmp byte[ballx], 2
jle UpCollision
cmp byte[ballx], 22
jge DownCollision
cmp byte[bally], 2
jle LeftCollision
cmp byte[bally], 78
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
mov  al, 1              ; subservice 01 – update cursor 
mov  bh, 0              ; output on page 0 
mov  bl, 7              ; normal attrib 
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
mov ax, 0x4F20             ; moving the value to print into ax
mov bx, pad1               ; moving the address of array that contain the location of pad1 into bx 
mov di, [bx]               ; printing pad1 
stosw
mov di, [bx+2]
stosw
mov di, [bx+4]
stosw
mov ax, 0x1F20             ; moving the address of array that contain the location of pad2 into bx 
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
mov ah, 0x07 
mov al, byte[scoreL]
add al, 0x30
stosw
mov di, word[scorediR]  ; for pointing di to appropiate location
mov ah, 0x07
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

; ---- This is Start Label ----
start:
xor  ax, ax 
mov  es, ax             ; point es to IVT base 
cli                     ; disable interrupts 
mov  word [es:9*4], kbisr ; store offset at n*4 
mov  [es:9*4+2], cs     ; store segment at n*4+2 
sti                     ; enable interrupts
call printWall
start_loop:
cmp byte[pausegame], 1
jz start_loop
call clrscr
call printBoard
call delay
call delay
call delay
jmp start_loop

mov ax, 0x4c00
int 0x21