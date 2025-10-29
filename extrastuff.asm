/*
 * extrastuff.asm
 *
 *  Created: 4/19/2025 1:25:56 AM
 *   Author: octavian
 */ 
 .CSEG

Font:
	.DB  0b00111100
	.DB  0b00100100
	.DB  0b00100100
	.DB  0b00111100
	.DB  0b00100100
	.DB  0b00100100
	.DB  0b00100100

B:
	.DB  0b01111100
	.DB  0b01000110
	.DB  0b01001100
	.DB  0b01110000
	.DB  0b01101100
	.DB  0b01000110
	.DB  0b01111100


	DrawChar:

LDI ZH, HIGH(screenBuffer+0)
LDI ZL, LOW(screenBuffer+0)
LDI R16, 0b00001111
ST Z+, R16
LDI ZH, HIGH(screenBuffer+10)
LDI ZL, LOW(screenBuffer+10)
LDI R16, 0b00001001;
ST Z+, R16
LDI ZH, HIGH(screenBuffer+20)
LDI ZL, LOW(screenBuffer+20)
LDI R16, 0b00001001
ST Z+, R16
LDI ZH, HIGH(screenBuffer+30)
LDI ZL, LOW(screenBuffer+30)
LDI R16, 0b00001111
ST Z+, R16
LDI ZH, HIGH(screenBuffer+40)
LDI ZL, LOW(screenBuffer+40)
LDI R16, 0b00000001
ST Z+, R16
LDI ZH, HIGH(screenBuffer+50)
LDI ZL, LOW(screenBuffer+50)
LDI R16, 0b00000001
ST Z+, R16
LDI ZH, HIGH(screenBuffer)
LDI ZL, LOW(screenBuffer)

LDI ZH, HIGH(screenBuffer+1)
LDI ZL, LOW(screenBuffer+1)
LDI R16, 0b00001111
ST Z+, R16
LDI ZH, HIGH(screenBuffer+11)
LDI ZL, LOW(screenBuffer+11)
LDI R16, 0b00001001;
ST Z+, R16
LDI ZH, HIGH(screenBuffer+21)
LDI ZL, LOW(screenBuffer+21)
LDI R16, 0b00001001
ST Z+, R16
LDI ZH, HIGH(screenBuffer+31)
LDI ZL, LOW(screenBuffer+31)
LDI R16, 0b00001111
ST Z+, R16
LDI ZH, HIGH(screenBuffer+41)
LDI ZL, LOW(screenBuffer+41)
LDI R16, 0b00000101
ST Z+, R16
LDI ZH, HIGH(screenBuffer+51)
LDI ZL, LOW(screenBuffer+51)
LDI R16, 0b00001001
ST Z+, R16
LDI ZH, HIGH(screenBuffer)
LDI ZL, LOW(screenBuffer)

LDI ZH, HIGH(screenBuffer+2)
LDI ZL, LOW(screenBuffer+2)
LDI R16, 0b00001111
ST Z+, R16
LDI ZH, HIGH(screenBuffer+12)
LDI ZL, LOW(screenBuffer+12)
LDI R16, 0b00000001;
ST Z+, R16
LDI ZH, HIGH(screenBuffer+22)
LDI ZL, LOW(screenBuffer+22)
LDI R16, 0b00000001
ST Z+, R16
LDI ZH, HIGH(screenBuffer+32)
LDI ZL, LOW(screenBuffer+32)
LDI R16, 0b00001111
ST Z+, R16
LDI ZH, HIGH(screenBuffer+42)
LDI ZL, LOW(screenBuffer+42)
LDI R16, 0b00000001
ST Z+, R16
LDI ZH, HIGH(screenBuffer+52)
LDI ZL, LOW(screenBuffer+52)
LDI R16, 0b00001111
ST Z+, R16
LDI ZH, HIGH(screenBuffer)
LDI ZL, LOW(screenBuffer)

LDI ZH, HIGH(screenBuffer+3)
LDI ZL, LOW(screenBuffer+3)
LDI R16, 0b00001111
ST Z+, R16
LDI ZH, HIGH(screenBuffer+13)
LDI ZL, LOW(screenBuffer+13)
LDI R16, 0b00000001;
ST Z+, R16
LDI ZH, HIGH(screenBuffer+23)
LDI ZL, LOW(screenBuffer+23)
LDI R16, 0b00001111
ST Z+, R16
LDI ZH, HIGH(screenBuffer+33)
LDI ZL, LOW(screenBuffer+33)
LDI R16, 0b00001000
ST Z+, R16
LDI ZH, HIGH(screenBuffer+43)
LDI ZL, LOW(screenBuffer+43)
LDI R16, 0b00001000
ST Z+, R16
LDI ZH, HIGH(screenBuffer+53)
LDI ZL, LOW(screenBuffer+53)
LDI R16, 0b00001111
ST Z+, R16
LDI ZH, HIGH(screenBuffer)
LDI ZL, LOW(screenBuffer)

LDI ZH, HIGH(screenBuffer+4)
LDI ZL, LOW(screenBuffer+4)
LDI R16, 0b00001111
ST Z+, R16
LDI ZH, HIGH(screenBuffer+14)
LDI ZL, LOW(screenBuffer+14)
LDI R16, 0b00000001;
ST Z+, R16
LDI ZH, HIGH(screenBuffer+24)
LDI ZL, LOW(screenBuffer+24)
LDI R16, 0b00001111
ST Z+, R16
LDI ZH, HIGH(screenBuffer+34)
LDI ZL, LOW(screenBuffer+34)
LDI R16, 0b00001000
ST Z+, R16
LDI ZH, HIGH(screenBuffer+44)
LDI ZL, LOW(screenBuffer+44)
LDI R16, 0b00001000
ST Z+, R16
LDI ZH, HIGH(screenBuffer+54)
LDI ZL, LOW(screenBuffer+54)
LDI R16, 0b00001111
ST Z+, R16
LDI ZH, HIGH(screenBuffer)
LDI ZL, LOW(screenBuffer)


;bottom half
LDI ZH, HIGH(screenBuffer+5)
LDI ZL, LOW(screenBuffer+5)
LDI R16, 0b01001111
ST Z+, R16
LDI ZH, HIGH(screenBuffer+15)
LDI ZL, LOW(screenBuffer+15)
LDI R16, 0b11001001;
ST Z+, R16
LDI ZH, HIGH(screenBuffer+25)
LDI ZL, LOW(screenBuffer+25)
LDI R16, 0b11001001
ST Z+, R16
LDI ZH, HIGH(screenBuffer+35)
LDI ZL, LOW(screenBuffer+35)
LDI R16, 0b01001111
ST Z+, R16
LDI ZH, HIGH(screenBuffer+45)
LDI ZL, LOW(screenBuffer+45)
LDI R16, 0b01001001
ST Z+, R16
LDI ZH, HIGH(screenBuffer+55)
LDI ZL, LOW(screenBuffer+55)
LDI R16, 0b01001001
ST Z+, R16
LDI ZH, HIGH(screenBuffer)
LDI ZL, LOW(screenBuffer)

LDI ZH, HIGH(screenBuffer+6)
LDI ZL, LOW(screenBuffer+6)
LDI R16, 0b10010010
ST Z+, R16
LDI ZH, HIGH(screenBuffer+16)
LDI ZL, LOW(screenBuffer+16)
LDI R16, 0b10010010;
ST Z+, R16
LDI ZH, HIGH(screenBuffer+26)
LDI ZL, LOW(screenBuffer+26)
LDI R16, 0b01100010
ST Z+, R16
LDI ZH, HIGH(screenBuffer+36)
LDI ZL, LOW(screenBuffer+36)
LDI R16, 0b01100011
ST Z+, R16
LDI ZH, HIGH(screenBuffer+46)
LDI ZL, LOW(screenBuffer+46)
LDI R16, 0b01000011
ST Z+, R16
LDI ZH, HIGH(screenBuffer+56)
LDI ZL, LOW(screenBuffer+56)
LDI R16, 0b01000010
ST Z+, R16
LDI ZH, HIGH(screenBuffer)
LDI ZL, LOW(screenBuffer)

LDI ZH, HIGH(screenBuffer+7)
LDI ZL, LOW(screenBuffer+7)
LDI R16, 0b01010000
ST Z+, R16
LDI ZH, HIGH(screenBuffer+17)
LDI ZL, LOW(screenBuffer+17)
LDI R16, 0b00110000;
ST Z+, R16
LDI ZH, HIGH(screenBuffer+27)
LDI ZL, LOW(screenBuffer+27)
LDI R16, 0b00010000
ST Z+, R16
LDI ZH, HIGH(screenBuffer+37)
LDI ZL, LOW(screenBuffer+37)
LDI R16, 0b00110000
ST Z+, R16
LDI ZH, HIGH(screenBuffer+47)
LDI ZL, LOW(screenBuffer+47)
LDI R16, 0b01010000
ST Z+, R16
LDI ZH, HIGH(screenBuffer+57)
LDI ZL, LOW(screenBuffer+57)
LDI R16, 0b10010000
ST Z+, R16
LDI ZH, HIGH(screenBuffer)
LDI ZL, LOW(screenBuffer)

LDI ZH, HIGH(screenBuffer+8)
LDI ZL, LOW(screenBuffer+8)
LDI R16, 0b00111100
ST Z+, R16
LDI ZH, HIGH(screenBuffer+18)
LDI ZL, LOW(screenBuffer+18)
LDI R16, 0b00000100;
ST Z+, R16
LDI ZH, HIGH(screenBuffer+28)
LDI ZL, LOW(screenBuffer+28)
LDI R16, 0b00000100
ST Z+, R16
LDI ZH, HIGH(screenBuffer+38)
LDI ZL, LOW(screenBuffer+38)
LDI R16, 0b00111100
ST Z+, R16
LDI ZH, HIGH(screenBuffer+48)
LDI ZL, LOW(screenBuffer+48)
LDI R16, 0b00000100
ST Z+, R16
LDI ZH, HIGH(screenBuffer+58)
LDI ZL, LOW(screenBuffer+58)
LDI R16, 0b00111100
ST Z+, R16
LDI ZH, HIGH(screenBuffer)
LDI ZL, LOW(screenBuffer)

LDI ZH, HIGH(screenBuffer+9)
LDI ZL, LOW(screenBuffer+9)
LDI R16, 0b00001001
ST Z+, R16
LDI ZH, HIGH(screenBuffer+19)
LDI ZL, LOW(screenBuffer+19)
LDI R16, 0b00001001;
ST Z+, R16
LDI ZH, HIGH(screenBuffer+29)
LDI ZL, LOW(screenBuffer+29)
LDI R16, 0b00000110
ST Z+, R16
LDI ZH, HIGH(screenBuffer+39)
LDI ZL, LOW(screenBuffer+39)
LDI R16, 0b00000110
ST Z+, R16
LDI ZH, HIGH(screenBuffer+49)
LDI ZL, LOW(screenBuffer+49)
LDI R16, 0b00000100
ST Z+, R16
LDI ZH, HIGH(screenBuffer+59)
LDI ZL, LOW(screenBuffer+59)
LDI R16, 0b00000100
ST Z+, R16
LDI ZH, HIGH(screenBuffer)
LDI ZL, LOW(screenBuffer)


	;LDI R18,1; 1 for B,...
	;LDI R19,7; 
	;MUL R18, R19

	;LDI  ZH, HIGH(Font)
	;LDI  ZL, LOW (Font)
	;ADD ZL, R0
	;ADC ZH, R1

	;LDI  YH, HIGH(screenBuffer)
	;LDI  YL, LOW (screenBuffer)
	;LDI  R17,7

	;drawLetterLoop:
	;	LPM R16,Z+
	;	ST Y+, R16
	;	ADIW YL, 9
	;	DEC R17
	;	BRNE drawLetterLoop
	
	RET


	
	
GameOverScreen:
IN R16,SREG


PUSH R16

;	LDI ZH, HIGH(screenBuffer)
 ;   LDI ZL, LOW(screenBuffer)
  ;  LDI R17,70
	;clearscreenatGameOver:
	;	LDI R18,0
	;	ST Z+, R18
	;	DEC R17
    ;BRNE clearscreenatGameOver

LDI ZH, HIGH(screenBuffer+0)
LDI ZL, LOW(screenBuffer+0)
LDI R16, 0b11001111
ST Z+, R16
LDI ZH, HIGH(screenBuffer+10)
LDI ZL, LOW(screenBuffer+10)
LDI R16, 0b01000001;
ST Z+, R16
LDI ZH, HIGH(screenBuffer+20)
LDI ZL, LOW(screenBuffer+20)
LDI R16, 0b01001101
ST Z+, R16
LDI ZH, HIGH(screenBuffer+30)
LDI ZL, LOW(screenBuffer+30)
LDI R16, 0b11001001
ST Z+, R16
LDI ZH, HIGH(screenBuffer+40)
LDI ZL, LOW(screenBuffer+40)
LDI R16, 0b01001001
ST Z+, R16
LDI ZH, HIGH(screenBuffer+50)
LDI ZL, LOW(screenBuffer+50)
LDI R16, 0b01001001
ST Z+, R16
LDI ZH, HIGH(screenBuffer)
LDI ZL, LOW(screenBuffer)

LDI ZH, HIGH(screenBuffer+1)
LDI ZL, LOW(screenBuffer+1)
LDI R16, 0b00000011
ST Z+, R16
LDI ZH, HIGH(screenBuffer+11)
LDI ZL, LOW(screenBuffer+11)
LDI R16, 0b00000010;
ST Z+, R16
LDI ZH, HIGH(screenBuffer+21)
LDI ZL, LOW(screenBuffer+21)
LDI R16, 0b00000010
ST Z+, R16
LDI ZH, HIGH(screenBuffer+31)
LDI ZL, LOW(screenBuffer+31)
LDI R16, 0b00000011
ST Z+, R16
LDI ZH, HIGH(screenBuffer+41)
LDI ZL, LOW(screenBuffer+41)
LDI R16, 0b00000010
ST Z+, R16
LDI ZH, HIGH(screenBuffer+51)
LDI ZL, LOW(screenBuffer+51)
LDI R16, 0b00000010
ST Z+, R16
LDI ZH, HIGH(screenBuffer)
LDI ZL, LOW(screenBuffer)

LDI ZH, HIGH(screenBuffer+2)
LDI ZL, LOW(screenBuffer+2)
LDI R16, 0b00001111
ST Z+, R16
LDI ZH, HIGH(screenBuffer+12)
LDI ZL, LOW(screenBuffer+12)
LDI R16, 0b00000001;
ST Z+, R16
LDI ZH, HIGH(screenBuffer+22)
LDI ZL, LOW(screenBuffer+22)
LDI R16, 0b00000001
ST Z+, R16
LDI ZH, HIGH(screenBuffer+32)
LDI ZL, LOW(screenBuffer+32)
LDI R16, 0b00001111
ST Z+, R16
LDI ZH, HIGH(screenBuffer+42)
LDI ZL, LOW(screenBuffer+42)
LDI R16, 0b00000001
ST Z+, R16
LDI ZH, HIGH(screenBuffer+52)
LDI ZL, LOW(screenBuffer+52)
LDI R16, 0b00001111
ST Z+, R16
LDI ZH, HIGH(screenBuffer)
LDI ZL, LOW(screenBuffer)

LDI ZH, HIGH(screenBuffer+3)
LDI ZL, LOW(screenBuffer+3)
LDI R16, 0b00001111
ST Z+, R16
LDI ZH, HIGH(screenBuffer+13)
LDI ZL, LOW(screenBuffer+13)
LDI R16, 0b00000001;
ST Z+, R16
LDI ZH, HIGH(screenBuffer+23)
LDI ZL, LOW(screenBuffer+23)
LDI R16, 0b00001111
ST Z+, R16
LDI ZH, HIGH(screenBuffer+33)
LDI ZL, LOW(screenBuffer+33)
LDI R16, 0b00001000
ST Z+, R16
LDI ZH, HIGH(screenBuffer+43)
LDI ZL, LOW(screenBuffer+43)
LDI R16, 0b00001000
ST Z+, R16
LDI ZH, HIGH(screenBuffer+53)
LDI ZL, LOW(screenBuffer+53)
LDI R16, 0b00001111
ST Z+, R16
LDI ZH, HIGH(screenBuffer)
LDI ZL, LOW(screenBuffer)

LDI ZH, HIGH(screenBuffer+4)
LDI ZL, LOW(screenBuffer+4)
LDI R16, 0b00001111
ST Z+, R16
LDI ZH, HIGH(screenBuffer+14)
LDI ZL, LOW(screenBuffer+14)
LDI R16, 0b00000001;
ST Z+, R16
LDI ZH, HIGH(screenBuffer+24)
LDI ZL, LOW(screenBuffer+24)
LDI R16, 0b00001111
ST Z+, R16
LDI ZH, HIGH(screenBuffer+34)
LDI ZL, LOW(screenBuffer+34)
LDI R16, 0b00001000
ST Z+, R16
LDI ZH, HIGH(screenBuffer+44)
LDI ZL, LOW(screenBuffer+44)
LDI R16, 0b00001000
ST Z+, R16
LDI ZH, HIGH(screenBuffer+54)
LDI ZL, LOW(screenBuffer+54)
LDI R16, 0b00001111
ST Z+, R16
LDI ZH, HIGH(screenBuffer)
LDI ZL, LOW(screenBuffer)

CLI
RCALL displayPattern
SEI


	LDI R17,255
	wasteTime1:
		LDI R18,255
		wasteTime2:
			LDI R19,255
			wasteTime4:
				DEC R19
				BRNE wasteTime4
			DEC R18
			BRNE wasteTime2
		DEC R17
		BRNE wasteTime1
POP R16
OUT SREG,R16
			
RJMP start



