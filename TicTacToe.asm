name "Tic-Tac-Toe"

;Tic-tac-toe assembly
; For emu8086
; Made by Oz Elentok
;
; Modificado por Rodrigo Sousa Alves
data segment
    
    str_TAM= 20 ; tamanho maximo da string   
    
    ; buffers salvam strings de player 1 e 2
    player1     db  str_TAM dup (?)
                db  1 dup (?) ; posiçao extra para guardar '$'
    player2     db  str_TAM dup (?)
                db  1 dup (?) ;posiçao extra para guardar '$'
    msgName1    db "Player 1 escolha um nome: $"
    msgName2    db "Player 2 escolha um nome: $"
    msgSymbol1  db "Player 1 escolha um simbolo: $"
    msgSymbol2  db "Player 2 escolha um simbolo: $"
    char1       db 2 dup (?); simbolo player 1
    char2       db 2 dup (?); simbolo player 2
    menuTitle	db "-_-_- MENU -_-_-$"
	menuItem1	db "1. Inserir/Alterar nome do Jogador 1.$"
	menuItem2	db "2. Inserir/Alterar nome do Jogador 2.$"
	menuItem3	db "3. Escolher o simbolo e cor do Jogador 1.$"
	menuItem4	db "4. Escolher o simbolo e cor do Jogador 2.$"
	menuItem5	db "5. Escolher a cor do tabuleiro.$"
	menuItem6	db "6. Iniciar jogo.$"
	menuItem7	db "7. Sair.$"
	msgOpcao	db "Escolha uma opcao: $"
    
	grid db 9 dup(0)
	player db 0
	win db 0
	temp db 0
	quitGameQuest db "Gostaria de sair sair da aplicacao? (s - sim; n - nao)$"
	welcome db "Tic Tac Toe Game - By Oz Elentok$"
	separator db "---|---|---$"
	enterLoc db "Escolha seu movimento pela localizacao(1-9)$"
	turnMessage db " turno$"
	tieMessage db "Um empate ocorreu entre os 2 jogadores!$"
	winMessage db "O jogador vencedor eh $"
	inDigitError db "ERROR!, digito invalido$"
	inError db "ERROR!, o valor digitado nao eh um numero$"
	newline db 0Dh,0Ah,'$'
ends
stack segment
	dw 128 dup(0)
ends

code segment
start:
	;Tamanho da tela setado para 40x25 

	; mov al, 00h; Seta a dimensao da tela, 00h corresponde a 40x25 no modo texto.
	; mov ah, 0  ; Seta o modo de video.
	; int 10h    ; Interrupcao de video.

	mov ax, data
	mov ds, ax
	mov es, ax  
	
	call menu

	; PLAYER 1
	getNameP1:
		lea dx, newline
		call printString
		lea dx, msgName1
		call printString
		; chama getstr pra ler o nome do player 1 do teclado
	    mov     cx, str_TAM
	    mov     dx, offset player1
	    call    getstr
	                     	
	    lea dx, newline
		call printString
		call menu
	             
	;escolhe os caracteres
	getSymbolP1:  
		lea dx, newline
		call printString
		lea dx, msgSymbol1
		call printString
		mov cx, 1
		mov dx, offset char1
		call getStr
		lea dx, newline
		call printString
		call menu

	; PLAYER 2
	getNameP2:
		lea dx, newline
		call printString   
		lea dx, msgName2
		call printString
		; chama getstr pra ler o nome do player 2 do teclado
	    mov     cx, str_TAM
	    mov     dx, offset player2
	    call    getstr
	    
	    lea dx, newline
		call printString
		call menu
	
	getSymbolP2:
		lea dx, newline
		call printString
		lea dx, msgSymbol2
		call printString
		mov cx, 1
		mov dl, offset char2
		call getStr
		lea dx, newline
		call printString
		call menu

	newGame:
	
	    call initiateGrid
		mov player, 10b; 2dec
		mov win, 0
		mov cx, 9
	
	gameAgain:
		call clearScreen
		lea dx, welcome
		call printString
		lea dx, newline
		call printString
		lea dx, enterLoc
		call printString
		lea dx, newline
		call printString 
		call printString
		call printGrid
		mov al, player
		cmp al, 1
		je p2turn

		; previous player was 2
		shr player, 1; 0010b --> 0001b;
		mov dx, offset player1
		call printString     
		mov dl, ':'
		call putChar
		mov dl, char1
		call putChar
		lea dx, turnMessage
		call printString    
		lea dx, newline
		call printString
		jmp endPlayerSwitch

	p2turn:; previous player was 1
		shl player, 1; 0001b --> 0010b 
		mov dx, offset player2
		call printString    
		mov dl, ':'
		call putChar    
		mov dl, char2
		call putChar
		lea dx, turnMessage
		call printString
		lea dx, newline
		call printString
			
	endPlayerSwitch:
		call getMove; bx will point to the right board postiton at the end of getMove
		mov dl, player
		cmp dl, 1
		jne p2move    
		mov dl, char1        
		jmp contMoves
	p2move:
		mov dl, char2
	contMoves:
		mov [bx], dl
		cmp cx, 5 ; no need to check before the 5th turn
		jg noWinCheck
		call checkWin
		cmp win, 1
		je won
	noWinCheck:
		loop gameAgain
		
		;tie, cx = 0 at this point and no player has won
		 call clearScreen
		 lea dx, welcome
		 call printString
		 lea dx, newline
		 call printString
		 call printString
		 call printString
		 call printGrid
		 lea dx, tieMessage
		 call printString
		 lea dx, newline
		 call printString
		 jmp menu
	
	; PLAYER WIN
	won:; current player has won
	call clearScreen
	lea dx, welcome
	call printString
	lea dx, newline
	call printString
	call printString
	call printString
	call printGrid
	lea dx, winMessage
	call printString
	mov dl, player
	cmp dl, 1
	je printPlayer1
	mov dx, offset player2
	call printString
	here: 
	add dl, '0'
	lea dx, newline
	call printString
	call getChar
	call menu
	 
	askForQuitGame:
	lea dx, newline
	call printString
	lea dx, quitGameQuest; ask for another game
	call printString
	lea dx, newline
	call printString
	call getChar
	cmp al, 's'; play again if 's' is pressed
	jne menu
	jmp sof
	 
	sof:
	mov ax, 4c00h
	int 21h

;-------------------------------------------;
; Menu
;
menu:
	call clearScreen
	lea dx, menuTitle
	call printString   
	lea dx, newline
	call printString
	lea dx, menuItem1
	call printString   
	lea dx, newline
	call printString
	lea dx, menuItem2
	call printString   
	lea dx, newline
	call printString
	lea dx, menuItem3
	call printString   
	lea dx, newline
	call printString
	lea dx, menuItem4
	call printString   
	lea dx, newline
	call printString
	lea dx, menuItem5
	call printString   
	lea dx, newline
	call printString
	lea dx, menuItem6
	call printString   
	lea dx, newline
	call printString
	lea dx, menuItem7
	call printString   
	lea dx, newline
	call printString
	lea dx, msgOpcao
	call printString   
	lea dx, newline
	call printString
	call getOpcao

getOpcao:
	call getChar; al = getchar()
	call isValidDigit2
	cmp ah, 1
	je acessaOpcoes
	mov dl, 0dh
	call putChar
	lea dx, inError
	call printString
	lea dx, newline
	call printString
	jmp getOpcao

acessaOpcoes:
	cmp al, '1'
	je getNameP1
	cmp al, '2'
	je getNameP2
	cmp al, '3'
	je getSymbolP1
	cmp al, '4'
	je getSymbolP2
	cmp al, '5'
	je newGame
	cmp al, '6'
	je newGame
	cmp al, '7'
	je askForQuitGame


;-------------------------------------------;
; Sets ah = 01
; Input char into al;
getChar:
	mov ah, 01
	int 21h
	ret
;-------------------------------------------;	
; Sets ah = 02
; Output char from dl
; Sets ah to last char output
putChar:
	mov ah, 02h 
	int 21h     
	ret    
;-------------------------------------------;
; Sets ah = 09
; Outputs string from dx
; Sets al = 24h
printString:
	mov ah, 09
	int 21h
	ret
;-------------------------------------------;
; Clears the screen
; ah = 0 at the end
clearScreen:
	mov ah, 0fh
	int 10h
	mov ah, 0
	int 10h
	ret
	
;-------------------------------------------;
; Gets location that can be used
; after successfuly geting the location:
; al - will hold the place number(0 - 8)
; bx - will hold the positon(bx[al])
getMove:
	call getChar; al = getchar()
	call isValidDigit
	cmp ah, 1
	je contCheckTaken
	mov dl, 0dh
	call putChar
	lea dx, inError
	call printString
	lea dx, newline
	call printString
	jmp getMove

	
contCheckTaken: ; Checks this: if(grid[al] > '9'), grid[al] == 'O' or 'X'
	lea bx, grid	
	sub al, '1'
	mov ah, 0
	add bx, ax
	mov al, [bx]
	cmp al, '9'
	jng finishGetMove
	mov dl, 0dh
	call putChar
	lea dx, inDigitError
	call printString
	lea dx, newline
	call printString
	jmp getMove
finishGetMove:
	lea dx, newline
	call printString
	ret
	
;-------------------------------------------;
; Initiates the grid from '1' to '9'
; Uses bx, al, cx
initiateGrid:
	lea bx, grid
	mov al, '1'
	mov cx, 9
	initNextTa:
	mov [bx], al
	inc al
	inc bx
	loop initNextTa
	ret
	
;-------------------------------------------;
; checks if a char in al is a digit
; DOESN'T include '0'
; if is Digit, ah = 1, else ah = 0
isValidDigit:
	mov ah, 0
	cmp al, '1'
	jl sofIsDigit
	cmp al, '9'
	jg sofIsDigit
	mov ah, 1

sofIsDigit:
	ret

isValidDigit2:
	mov ah, 0
	cmp al, '1'
	jl sofIsDigit
	cmp al, '7'
	jg sofIsDigit
	mov ah, 1
	ret
	
	
;-------------------------------------------;	
; Outputs the 3x3 grid
; uses bx, dl, dx
printGrid:     
	lea bx, grid
	call printRow
	lea dx, separator
	call printString
	lea dx, newline
	call printString
	call printRow
	lea dx, separator
	call printString
	lea dx, newline
	call printString
	call printRow
	ret

;-------------------------------------------;
; Outputs a single row of the grid
; Uses bx as the first number in the row
; At the end:
; dl = third cell on row
; bx += 3, for the next row
; dx points to newline
printRow:
	;First Cell
	mov dl, ' '
	call putChar 
	mov dl, [bx] 
	call putChar
	mov dl, ' '
	call putChar
	mov dl, '|'
	call putChar
	inc bx
	
	;Second Cell
	mov dl, ' '
	call putChar
	mov dl, [bx]
	call putChar
	mov dl, ' '
	call putChar
	mov dl, '|'
	call putChar
	inc bx
	
	;Third Cell
	mov dl, ' '
	call putChar
	mov dl, [bx]
	call putChar
	inc bx
	
	lea dx, newline
	call printString
	ret
	
;-------------------------------------------;	
; Returns 1 in al if a player won
; 1 for win, 0 for no win
; Changes bx
checkWin:
	lea si, grid
	call checkDiagonal
	cmp win, 1
	je endCheckWin
	call checkRows
	cmp win, 1
	je endCheckWin
	call CheckColumns
	endCheckWin:
	ret
	
drawDiag1:
	mov bx, si
	mov al, [bx]
	add bx, 4	;grid[0] ---> grid[4]
	cmp al, [bx]
	jne diagonalRtL
	add bx, 4	;grid[4] ---> grid[8]
	cmp al, [bx]
	jne diagonalRtL
	mov win, 1
	;call drawDiag1

; drawDiag2:

; drawRow:

; drawCol:

;-------------------------------------------;	
checkDiagonal:
	;DiagonalLtR
	mov bx, si
	mov al, [bx]
	add bx, 4	;grid[0] ---> grid[4]
	cmp al, [bx]
	jne diagonalRtL
	add bx, 4	;grid[4] ---> grid[8]
	cmp al, [bx]
	jne diagonalRtL
	mov win, 1
	;call drawDiag1
	ret
	
	diagonalRtL:
	mov bx, si
	add bx, 2	;grid[0] ---> grid[2]
	mov al, [bx]
	add bx, 2	;grid[2] ---> grid[4]
	cmp al, [bx]
	jne endCheckDiagonal
	add bx, 2	;grid[4] ---> grid[6]
	cmp al, [bx]
	jne endCheckDiagonal
	mov win, 1
	;call drawDiag2
	endCheckDiagonal:
	ret
	
;-------------------------------------------;
checkRows:	
	;firstRow
	mov bx, si; --->grid[0]
	mov al, [bx]
	inc bx		;grid[0] ---> grid[1]
	cmp al, [bx]
	jne secondRow
	inc bx		;grid[1] ---> grid[2]
	cmp al, [bx]
	jne secondRow
	mov win, 1
	;call drawRow
	ret
	
	secondRow:
	mov bx, si; --->grid[0]
	add bx, 3	;grid[0] ---> grid[3]
	mov al, [bx]
	inc bx	;grid[3] ---> grid[4]
	cmp al, [bx]
	jne thirdRow
	inc bx	;grid[4] ---> grid[5]
	cmp al, [bx]
	jne thirdRow
	mov win, 1
	;call drawRow
	ret
	
	thirdRow:
	mov bx, si; --->grid[0]
	add bx, 6;grid[0] ---> grid[6]
	mov al, [bx]
	inc bx	;grid[6] ---> grid[7]
	cmp al, [bx]
	jne endCheckRows
	inc bx	;grid[7] ---> grid[8]
	cmp al, [bx]
	jne endCheckRows
	mov win, 1
	;call drawRow
	endCheckRows:
	ret
	
;-------------------------------------------;	
CheckColumns:
	;firstColumn
	mov bx, si; --->grid[0]
	mov al, [bx]
	add bx, 3	;grid[0] ---> grid[3]
	cmp al, [bx]
	jne secondColumn
	add bx, 3	;grid[3] ---> grid[6]
	cmp al, [bx]
	jne secondColumn
	mov win, 1
	;call drawCol
	ret
	
	secondColumn:
	mov bx, si; --->grid[0]
	inc bx	;grid[0] ---> grid[1]
	mov al, [bx]
	add bx, 3	;grid[1] ---> grid[4]
	cmp al, [bx]
	jne thirdColumn
	add bx, 3	;grid[4] ---> grid[7]
	cmp al, [bx]
	jne thirdColumn
	mov win, 1
	;call drawCol
	ret
	
	thirdColumn:
	mov bx, si; --->grid[0]
	add bx, 2	;grid[0] ---> grid[2]
	mov al, [bx]
	add bx, 3	;grid[2] ---> grid[5]
	cmp al, [bx]
	jne endCheckColumns
	add bx, 3	;grid[5] ---> grid[8]
	cmp al, [bx]
	jne endCheckColumns
	mov win, 1
	;call drawCol
	endCheckColumns:
	ret
	       
    printPlayer1:
		mov dx, offset player1
		call printString
		jmp here
	 	       
	getstr proc

        ; preserva used register
        push ax
        push bx
        push si

        ; si used as base address
        mov     si, dx

        ; bx used as index to the base address
          mov     bx, 0   
            
        L11:        
            ; read next character
            mov     ah, 1
            int     21h

            ; Check if it is not return 
            ; (indicating the end of line)                                 
            cmp     al, 13 ; return character
            jz      L12

            ; save the read character in buffer.
            mov     [si][bx], al

            ; next index of buffer
            inc     bx

        L12:
            ; loop until count-down is zero and not 
            ; matched return character            
            loopnz  L11

            ; bx contains the length of string.
            ; save it in cx                          
            mov     cx, bx

            ; append a sequence of return, 
            ;inc     bx
            ;mov     [si][bx], 13                                                                  

            ; new-line and                               
            ;inc     bx
            ;mov     [si][bx], 10                                                                  

            ; '$' character to the string          
            inc     bx
            mov     [si][bx], '$'                                                                  

            ; recover used register          
            pop     si
            pop     bx
            pop     ax
            ret
    getstr   endp      
	
ends
end start


