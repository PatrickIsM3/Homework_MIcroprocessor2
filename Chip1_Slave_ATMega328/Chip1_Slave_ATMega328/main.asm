/*;R16 use for setting register
;R17 is check button and data
;R20,R21,R22 : delay 
.org 0x00
ldi r16,high(RAMEND)
out SPH,r16
ldi r16,low(RAMEND)
out SPL,r16
call SPI_Slave_Init
ldi r16,0x0f
out ddrd,r16
ldi r16,0xf0
out portd,r16
sbi ddrc,0
sbi portc,0
;KEYPAD;
keypad_scan:
	rcall enter
	rjmp keypad_scan
enter:

		REPEAT:	ldi r17,0xFE     ;input port a from pin 4->7 is pull-up resistor
				out PORTD,r17   ; from 0->3 is output it can be high or low
								; we need to check all column , then go to row
				sbic PIND,4     ; if pind 4 is press 
				rjmp JUMP       ; if not we jump to another rows
				call DELAY_1MS
		debounce: sbis pind,4
				  rjmp debounce

				LDI R17,0x33    ; than we load number 3
			    rcall SPI_Transmitter
	
		JUMP:
				sbic pind,5    ; pind 5 is press or not
				rjmp JUMP_1
				call DELAY_1MS
		debounce1:	sbis pind,5
					rjmp debounce1
		
				LDI R17,0x34     ; here we load number 4
				rcall SPI_Transmitter

		JUMP_1: sbic pind,6    
				RJMP JUMP_2
				call DELAY_1MS
		debounce2:	sbis pind,6
					rjmp debounce2
				LDI R17,0x42
				rcall SPI_Transmitter
				
		JUMP_2:
				sbic pind,7
				RJMP JUMP_3
				call DELAY_1MS
		debounce3:	sbis pind,7
					rjmp debounce3

				LDI R17,0x43
				rcall SPI_Transmitter
				
		JUMP_3:	
				ldi R17,0xFD      ; here we change other columns
				out portd,R17    ; all code will have this algorithm afterall 
				sbic pind,4
				rjmp JUMP_4
				call DELAY_1MS

		debounce4:	sbis pind,4
					rjmp debounce4
						
				LDI R17,0x32
				rcall SPI_Transmitter
			
		JUMP_4: 
				sbic pind,5
				RJMP JUMP_5
				call DELAY_1MS
		debounce5:	sbis pind,5
					rjmp debounce5

			
				LDI R17,0x35
				rcall SPI_Transmitter
			
		JUMP_5:	
				sbic pind,6
				rjmp JUMP_6
				call DELAY_1MS

		debounce6:	sbis pind,6
					rjmp debounce6
					
				LDI R17,0x41
				rcall SPI_Transmitter
		
		JUMP_6:
				sbic pind,7
				rjmp JUMP_7
				call DELAY_1MS

		debounce7:	sbis pind,7
					rjmp debounce7
					 
				LDI R17,0x44
				rcall SPI_Transmitter
					
		JUMP_7:
				LDI R17,0xFB
				out portd,r17
				sbic pind,4
				rjmp JUMP_8
				call DELAY_1MS

		debounce8:	sbis pind,4
					rjmp debounce8
			
				LDI R17,0x31
				rcall SPI_Transmitter
			
		JUMP_8:
				sbic pind,5
				rjmp JUMP_9
				call DELAY_1MS

		debounce9:	sbis pind,5
					rjmp debounce9

					
				LDI R17,0x36
				rcall SPI_Transmitter
			
		JUMP_9:	
				sbic pind,6
				rjmp JUMP_10
				call DELAY_1MS

		debounce10:	sbis pind,6
					rjmp debounce10
							
				LDI R17,0x39
				rcall SPI_Transmitter
				
		JUMP_10:
				sbic pind,7
				RJMP JUMP_11
				call DELAY_1MS
		debounce11:	sbis pind,7
					rjmp debounce11
	
				LDI R17,0x45
				rcall SPI_Transmitter
			
		JUMP_11:	
				LDI R17,0xF7
				OUT portd,R17
				SBIC pind,4
				RJMP JUMP_12
				call DELAY_1MS

		debounce12:	sbis pind,4
					rjmp debounce12
			
				LDI R17,0x30
				rcall SPI_Transmitter
			
		JUMP_12:
				sbic pind,5
				rjmp JUMP_13
				call DELAY_1MS

		debounce13:	sbis pind,5
					rjmp debounce13
					
				LDI R17,0x37
				rcall SPI_Transmitter
			
		JUMP_13:
				sbic pind,6
				RJMP JUMP_14
				call DELAY_1MS

		debounce14:	sbis pind,6
					rjmp debounce14
			
				LDI R17,0x38
				rcall SPI_Transmitter

		JUMP_14:
				sbic pind,7
				RJMP JUMP_15
				call DELAY_1MS

		debounce15:	sbis pind,7
					rjmp debounce15

				LDI R17,0x46
			    rcall SPI_Transmitter
		JUMP_15:
				RJMP REPEAT
				ret
;SPI_Initial
SPI_Slave_Init:
push r16
ldi r16, (0 << PB2 )|( 0 << PB3)|(1 << PB4)|(0 << PB5)
out ddrb, r16
ldi r16, ( 1 << SPE ) | ( 1 << SPR0)
out SPCR, r16
ldi	r16	,( 1 << SPI2X)
out SPSR, r16
pop r16
ret
;SPI-USART-Receciver	
;Check flag
SPI_Transmitter:
cbi PORTC,0
nop
nop
out SPDR,r17
SPI_T_Wait:
in r18,SPSR
sbrs r18,SPIF
rjmp SPI_t_Wait
in r17,SPDR
sbi PORTC,0 
ret

;DELAY_1MS;
DELAY_1MS:
	LDI R20,80
L1: LDI R21,25
L2:	DEC R21
	NOP
	BRNE L2
	DEC R20
	BRNE L1
	RET
	*/
	.equ sck=5
.equ miso=4
.equ mosi=3
.equ ss=2
.org 0
ldi r16, high(RAMEND)
out SPH, r16
ldi r16, low(RAMEND)
out SPL, r16
rcall spi_init

ldi r16,$0f
out ddrd,r16 ; 0-3 la output 4-7 la input pull-up 
ldi r16,$f0
out portd,r16


sbi ddrc,0
sbi portc,0
loop:
	rcall xu_ly
	rjmp loop
xu_ly:

		LAP:	ldi r17,$fe     ;in port a from pin 4->7 is pull-up resistor
				out portd,r17   ;so from 0->3 is output it can be high or low
				sbic PIND,4     ; if pina 4 is press 
				rjmp NHAY       ; if not we jump to another rows
				
				rcall DELAY
		deb:	sbis pind,4
				rjmp deb

				LDI R17,$33    ; than we load number 3
			    rcall spi_transmit
	
		NHAY:
				SBIC PIND,5    ; pina 5 is press or not
				RJMP NHAY_1

				rcall DELAY
		deb1:	sbis pind,5
				rjmp deb1
		
				LDI R17,$34     ; here we load number 4
				rcall spi_transmit

		NHAY_1: SBIC PIND,6    
				RJMP NHAY_2

				rcall DELAY
		deb2:	sbis pind,6
				rjmp deb2
			
				LDI R17,$42
				rcall spi_transmit
				
		NHAY_2:
				SBIC PIND,7
				RJMP NHAY_3
				
				rcall DELAY
		deb3:	sbis pind,7
				rjmp deb3

				LDI R17,$43
				rcall spi_transmit
				
		NHAY_3:	
				LDI R17,$fD      ; here we change other columns
				OUT PORTD,R17    ; and we check like the code above
				SBIC PIND,4
				RJMP NHAY_4
				
				rcall DELAY
		deb4:	sbis pind,4
				rjmp deb4
						
				LDI R17,$32
				rcall spi_transmit
			
		NHAY_4: 
				SBIC PIND,5
				RJMP NHAY_5
				
				rcall DELAY
		deb5:	sbis pind,5
				rjmp deb5

			
				LDI R17,$35
				rcall spi_transmit
			
		NHAY_5:	
				SBIC PIND,6
				RJMP NHAY_6
				
				rcall DELAY
		deb6:	sbis pind,6
				rjmp deb6
					
				LDI R17,$41
				rcall spi_transmit
		
		NHAY_6:
				SBIC PIND,7
				RJMP NHAY_7
				
				rcall DELAY
		deb7:	sbis pind,7
				rjmp deb7
					 
				LDI R17,$44
				rcall spi_transmit
					
		NHAY_7:
				LDI R17,$fB
				OUT PORTD,R17
				SBIC PIND,4
				RJMP NHAY_8
				
				rcall DELAY
		deb8:	sbis pind,4
				rjmp deb8
			
				LDI R17,$31
				rcall spi_transmit
			
		NHAY_8:
				SBIC PIND,5
				RJMP NHAY_9
				
				rcall DELAY
		deb9:	sbis pind,5
				rjmp deb9

					
				LDI R17,$36
				rcall spi_transmit
			
		NHAY_9:	
				SBIC PIND,6
				RJMP NHAY_10
				
				rcall DELAY
		deb10:	sbis pind,6
				rjmp deb10
							
				LDI R17,$39
				rcall spi_transmit
				
		NHAY_10:
				SBIC PIND,7
				RJMP NHAY_11
				
				rcall DELAY
		deb11:	sbis pind,7
				rjmp deb11
	
				LDI R17,$45
				rcall spi_transmit
			
		NHAY_11:	
				LDI R17,$f7
				OUT PORTD,R17
				SBIC PIND,4
				RJMP NHAY_12
				
				rcall DELAY
		deb12:	sbis pind,4
				rjmp deb12
			
				LDI R17,$30
				rcall spi_transmit
			
		NHAY_12:
				SBIC PIND,5
				RJMP NHAY_13
				
				rcall DELAY
		deb13:	sbis pind,5
				rjmp deb13
					
				LDI R17,$37
				rcall spi_transmit
			
		NHAY_13:
				SBIC PIND,6
				RJMP NHAY_14
				
				rcall DELAY
		deb14:	sbis pind,6
				rjmp deb14
			
				LDI R17,$38
				rcall spi_transmit

		NHAY_14:
				SBIC PIND,7
				RJMP NHAY_15
				
				rcall DELAY
		deb15:	sbis pind,7
				rjmp deb15

				LDI R17,$46
			    rcall spi_transmit
		NHAY_15:
				RJMP LAP
ret

spi_transmit:
	cbi portc,0
	nop
	nop
	nop
	nop
	out spdr,r17

	wait_transmit: 
	in r18,spsr
	sbrs r18,spif
	rjmp wait_transmit
	in r17,spdr
	sbi portc,0
	ret


spi_init:
	ldi r16,(1<<miso)|(0<<sck)|(0<<ss)|(0<<mosi)
	out ddrb,r16
	ldi r16,(1<<SPE)|(1<<spr0)
	out spcr,r16
	ret
DELAY:
L3: LDI R21,100 ;1MC
L1: LDI R20,200 ;1MC
L2: DEC R20 ;1MC
NOP ;1MC
BRNE L2 ;2/1MC
DEC R21 ;1MC
BRNE L1 ;2/1MC
RET