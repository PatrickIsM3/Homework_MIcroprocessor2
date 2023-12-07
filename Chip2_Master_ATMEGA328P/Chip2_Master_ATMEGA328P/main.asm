/*.org 0x0000 ; interrupt vector table
;PORTC is connect with LCD
;PORTD is data from keypad
;PORTB is setting USART and SPI
ldi r16,(1 << PC2)|(1 << PC3)|(1 << PC4)
out ddrc,r16
CBI		PORTC,2			
CBI		PORTC,3		;set up lcd	
CBI		PORTC,4	
call	POWER_RESET_LCD8	
call	INIT_LCD8
call SPI_Master_Init
call USART_Init
call SPI_Master_Init
ldi r16,0xFF
out ddrd,r16
;When receive data , it will toggle
cbi ddrc,0
sbi portc,0
sbi portb,2
start:
call SPI_Transfer
rjmp start
SPI_Master_Init:
push r16
ldi r16, (1 << PB2 )|( 1 << PB3)|(0 << PB4)|(1 << PB5)
out DDRB, r16
ldi r16, ( 1 << SPE ) | ( 1 << MSTR ) | ( 1 << SPR0)
sts SPCR, r16
ldi	r16	,( 1 << SPI2X)
sts SPSR, r16
pop r16
ret

;SPI-USART-Transfer
;Do anything , just set SPCR
;Check flag
SPI_Transfer:
push r17
;check the data receive or not
;if yes , give data to SPI Transmit
check_flag: sbic pinc,0
			rjmp check_flag
cbi portb,2
nop
out SPDR,r16
SPI_T_Wait:
in r18,SPCR
sbrs r18,SPIF
rjmp SPI_T_Wait
;Do anything , just set SPCR
in r16,spdr
sbi portb,2
call USART_Transmit_Data
mov r20,r16 ; give data to r20 , ready to do
;if RS clear , give out LCD
cbi portc,2
ldi r17,0x01
call OUT_LCD 
ldi r16,20
call DELAY_10MS
mov r17,r20
sbi portc,2 
call OUT_LCD1
ldi r16,1
call DELAY_10MS
ret
;if Rs set , give data out LCD 
 ;DELAY_10MS:
 DELAY_1MS:
	LDI R20,8
L1: LDI R21,25
L2:	DEC R21
	NOP
	BRNE L2
	DEC R20
	BRNE L1
	RET
//DELAY 10MS//
DELAY_10MS:
	LDI R22,10
L3: call DELAY_1MS
	DEC R22
	BRNE L3
	RET


;USART Subroutine
;UART Initialize
USART_Init:
; double speed for the USART
ldi r16,(1 << U2X0)
sts UCSR0A,r16
; Open transmit-receive
ldi r16,(1 << TXEN0)|( 1<< RXEN0)
sts UCSR0B, r16
;set frame format :8 data bits , no parity , 1 stop bit
ldi r16,(1 << UCSZ01)|(1<<UCSZ00)
sts UCSR0C, r16
;Set BAUD RATE ( this case is 9600)
;fosc = 8MHz
;For any other BAUD RATE, set in r16
;And check the frequency before calculate
;BAUD RATE = fosc / (( UBRR+1)*16)
ldi r16,103 
sts UBRR0L,r16
ret
;UART transmit
; r17 is the register will receive or send data
USART_Transmit_Data:	
	push r17
USART_T_Wait:
	 lds r17,UCSR0A
	 sbrs r17,UDRE0
	 rjmp USART_T_Wait
	 sts UDR0,r16
	 pop r17
	 ret
;UART receive
USART_Receive_Data:	
	push r17
USART_R_Wait:
	 lds r17,UCSR0A
	 sbrs r17,RXC0
	 rjmp USART_R_Wait
	 lds r16,UDR0
	 pop r17 
	 ret

INIT_LCD8:                       
				CBI PORTC,2
				LDI	R17,0X02
				CALL OUT_LCD   ; set the cursor to
				LDI R16,1
				call DELAY_10MS

				CBI PORTC,2
				LDI R17,0X01
				CALL OUT_LCD   ; clear all the content original of lcd
				LDI R16,20
				CALL DELAY_10MS

				CBI PORTC,2
				LDI R17,0X0C
				RCALL OUT_LCD    ;turn on lcd and turn off cursor
				LDI R16,1
				CALL DELAY_10MS
				RET
POWER_RESET_LCD8: 
				LDI		R16,200				
				CALL	DELAY_10MS		
			    CBI		PORTC,2
				LDI		R17,0x30		; we set up lcd 3 times
				RCALL	OUT_LCD
				LDI		R16,42
				call DELAY_10MS

				CBI		PORTC,2
				LDI		R17,0x30			
				RCALL	OUT_LCD
				LDI		R16,2
				CALL	DELAY_10MS

				CBI		PORTC,2
				LDI		R17,0x30
				RCALL	OUT_LCD
				LDI		R16,2
				CALL	DELAY_10MS		
				RET
OUT_LCD1: 	
				MOV		R21,R17
				ANDI    R21,0xF0  ; this one the same code above
				OUT		PORTD,R21 ; just diffent we don't have ori  
				SBI		PORTC,4   ; because we want rs=0 for commands
				CBI		PORTC,4

				LDI		R16,1
				CALL	DELAY_10MS

				SWAP	R17
				ANDI	R17,0xF0
				OUT		PORTD,R17
				SBI		PORTC,4				
				CBI		PORTC,4

				LDI		R16,1
				CALL	DELAY_10MS
				RET

OUT_LCD: 
				MOV		R21,R17
				ANDI    R21,0xF0   ; code here we have value of keypad(0,1,2,3,...,E,F)in assci in r17
				OUT		PORTD,R21 ;the reason why we have to do ori is make sure rs always =1
				SBI		PORTC,4   ; this code for high nibble
				CBI		PORTC,4

				LDI		R16,1
				CALL	DELAY_10MS

				SWAP	R17
				ANDI	R17,0xF0
				OUT		PORTD,R17
				SBI		PORTC,4				
				CBI		PORTC,4
				LDI		R16,1
				CALL	DELAY_10MS
				RET
				*/

.equ sck=5
.equ miso=4
.equ mosi=3
.equ ss=2
        .EQU	RS=2		;bit RS
		.EQU	RW=3		;bit RW
		.EQU	E=4		    ;bit E

.org 0

ldi r16, high(RAMEND)
out SPH, r16
ldi r16, low(RAMEND)
out SPL, r16

ldi r16,$1c
out ddrc,r16

CBI		PORTC,RS			
CBI		PORTC,RW		;set up lcd	
CBI		PORTC,E	

RCALL	POWER_RESET_LCD8	
RCALL	INIT_LCD8

rcall spi_init
rcall USART_Init       ; Initialize USART
rcall spi_init
ldi r16,$ff
out ddrd,r16

;cbi ddrc,0           ; tin hieu gui cho master la da co data tu slave
sbi portc,0

sbi portb,2
loop:
	rcall spi_transmit

	rjmp loop
spi_transmit:
	check: sbic pinc,0
	       rjmp check

	cbi portb,2
	nop
	out spdr,r16
	wait_transmit: 
	in r18,spsr
	sbrs r18,spif
	rjmp wait_transmit
	in r16,spdr    ; r16 chua data tu slave
	sbi portb,2
	call USART_SendChar
	mov r20,r16

	CBI PORTC,RS
	LDI R17,0X01
	RCALL OUT_LCD  ; clear display
	LDI R16,20
	RCALL DELAY_US

	mov r17,r20

	sbi PORTC,rs
	rcall XUAT
	ldi r16,1
	RCALL	DELAY_US
	ret


spi_init:
	ldi r16,(1<<sck)|(1<<ss)|(1<<mosi)|(0<<miso)
	out ddrb,r16
	ldi r16,(1<<SPE)|(1<<mstr)|(1<<spr0)
	out spcr,r16
	ret
USART_Init:
    ldi r16, 103           ; Set baud rate for 9600 bps with 1 MHz clock
    sts UBRR0L, r16       ; Set baud rate low byte
    ldi r16, (1<< U2X0)  ; Set double speed
    sts UCSR0A, r16
    ldi r16, (1 << UCSZ01) | (1 << UCSZ00) ; 8 data bits, no parity, 1 stop bit
    sts UCSR0C, r16
    ldi r16, (1 << RXEN0) | (1 << TXEN0)   ; Enable transmitter and receiver
    sts UCSR0B, r16
    ret

USART_SendChar:
    push r17
    USART_SendChar_Wait:
    lds r17, UCSR0A
    sbrs r17, UDRE0       ; Wait for data register to be empty 
    rjmp USART_SendChar_Wait
    sts UDR0, r16         ; Send character in r16
    pop r17
    ret

USART_ReceiveChar:
    push r17
    USART_ReceiveChar_Wait:
    lds r17, UCSR0A
    sbrs r17, RXC0        ; Wait for receive complete
    rjmp USART_ReceiveChar_Wait
    lds r16, UDR0         ; Store received character in r16
    pop r17
    ret
INIT_LCD8:                       
				
				CBI PORTC,RS
				LDI	R17,0X02
				RCALL OUT_LCD   ; set the cursor to
				LDI R16,1
				RCALL DELAY_US

				CBI PORTC,RS
				LDI R17,0X01
				RCALL OUT_LCD   ; clear all the content original of lcd
				LDI R16,20
				RCALL DELAY_US

				CBI PORTC,RS
				LDI R17,0X0C
				RCALL OUT_LCD    ;turn on lcd and turn off cursor
				LDI R16,1
				RCALL DELAY_US
				RET
POWER_RESET_LCD8: 
				LDI		R16,200				
				RCALL	DELAY_US		
			    CBI		PORTC,RS
				LDI		R17,$30		; we set up lcd 3 times
				RCALL	OUT_LCD
				LDI		R16,42
				RCALL	DELAY_US

				CBI		PORTC,RS
				LDI		R17,$30			
				RCALL	OUT_LCD
				LDI		R16,2
				RCALL	DELAY_US

				CBI		PORTC,RS
				LDI		R17,$30
				RCALL	OUT_LCD
				LDI		R16,2
				RCALL	DELAY_US		
				RET


XUAT: 
				MOV		R21,R17
				ANDI    R21,$F0   ; code here we have value of keypad(0,1,2,3,...,E,F)in assci in r17
				OUT		PORTD,R21 ;the reason why we have to do ori is make sure rs always =1
				SBI		PORTC,E   ; this code for high nibble
				CBI		PORTC,E

				LDI		R16,1
				RCALL	DELAY_US

				SWAP	R17
				ANDI	R17,$F0
				OUT		PORTD,R17
				SBI		PORTC,E				
				CBI		PORTC,E
				LDI		R16,1
				RCALL	DELAY_US

				RET
				
OUT_LCD: 	
				MOV		R21,R17
				ANDI    R21,$F0  ; this one the same code above
				OUT		PORTD,R21 ; just diffent we don't have ori  
				SBI		PORTC,E   ; because we want rs=0 for commands
				CBI		PORTC,E

				LDI		R16,1
				RCALL	DELAY_US

				SWAP	R17
				ANDI	R17,$F0
				OUT		PORTD,R17
				SBI		PORTC,E				
				CBI		PORTC,E

				LDI		R16,1
				RCALL	DELAY_US
				RET

DELAY_US:	MOV	R15,R16		
			LDI	R16,200			
L1:			MOV	R14,R16		
L2:			DEC	R14				
			NOP					
			BRNE	L2		
			DEC		R15				
			BRNE	L1				
			RET