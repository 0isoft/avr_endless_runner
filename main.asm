.INCLUDE "m328pdef.inc"


;The .ORG directive forces the compiler to put the next chunk of code at a specific address
.ORG 0x0000 ; corresponds to the address loaded when the microcontroller is reset or boots up. 
RJMP start


.ORG 0x001A;according to datasheet?
RJMP timerOverfInterrupt2; this is for screen buffer update
;apparently this one needs to come first

.ORG 0x0020
RJMP timerOverfInterrupt


.INCLUDE "extrastuff.asm"


.EQU didWeHandleKeyboard=0x0099

.EQU screenBuffer= 0x0130; first in SRAM, and we can use LD/ST on it
.EQU gameOverFlag=0x0454

.EQU doWeUpdateMemoryFlag=0x0201
.EQU doWeUpdateScreenFlag=0x0200
.EQU patternByte = 0x0203 ; here we store some bit pattern for debugging the screen/memory update (not particlarly relevant anymore)

.EQU doWePressKey = 0x0204

.EQU characterMap=0x305;

.EQU obstacleMap=0x380

.EQU patternByte2=0x451
.EQU patternByte3=0x452
.EQU patternByte4=0x453

start:

LDI R16, 0
STS gameOverFlag, R16


CLR R1
;set timers and interrupts

;timer0 is for screen update
LDI R16, 0x02; normal mode, prescaler 64 <--  this one  is  for the  screen
OUT TCCR0B, R16

;LDI R16, 0x04; normal mode, prescaler 

LDI R16, 0x01
STS TIMSK0,R16 ; enable  interrupts on timer0

LDI R16, 6; initial timer  value =0. 
;this way, with the prescaler 64, we go from 16MHz -> 250KHz f_clk/prescaler.
; and we have 256-6=250 increments => 250.000 ticks/second /  250 increments = 1000 overflows/second = 1ms refresh
OUT TCNT0, R16 ;


;timer1 is for game logic. im planning it for a  'normal' fps updates of memory buffer
;timer1=16bit, goes upto 65536
;going to  pick a prescaler of 8 such that overflow time is ~33 ms
LDI R16,0b00000000
STS TCCR1A, R16; normal mode
LDI R16,0b00000011
STS TCCR1B, R16;  prescaler 256
LDI  R16, 0b00000001
STS TIMSK1,  R16; enable  overflow for timer1
LDI R16, LOW(65280)
STS TCNT1L,R16
LDI R16, HIGH(65280)
STS TCNT1H,R16; preload value for timer1 counter (with 0)

;configure display related stuff, clear it, load a pattern to memory, then call display function

SBI DDRC,2
SBI PORTC,2; initially the LED is off

SBI DDRB,3
SBI DDRB,4
SBI DDRB,5
LDI ZH, HIGH(screenBuffer)
LDI ZL, LOW(screenBuffer)
LDI R17,70
MemoryLoop:
LDI R16, 0b00000000 ; first clear screen buffer
ST Z+, R16
DEC R17
BRNE MemoryLoop

;lets also clear the memory where we store the map
LDI ZH, HIGH(characterMap)
LDI ZL, LOW(characterMap)
LDI R17,70
clearmap:
LDI R16, 0b00000000 ; first clear screen buffer
ST Z+, R16
DEC R17
BRNE clearmap

;lets clear the obstalce map too
LDI ZH, HIGH(obstacleMap)
LDI ZL, LOW(obstacleMap)
LDI R17,70
clearObstaclemap:
LDI R16, 0b00000000 ; first clear screen buffer
ST Z+, R16
DEC R17
BRNE clearObstaclemap
CLI


RJMP splashScreen

splashScreen:

;LDI ZH, HIGH(screenBuffer+0)
;LDI ZL, LOW(screenBuffer+0)
;LDI R16, 0b00111100
;ST Z+, R16
;LDI ZH, HIGH(screenBuffer+10)
;LDI ZL, LOW(screenBuffer+10)
;;LDI R16, 0b00100100;
;ST Z+, R16
;LDI ZH, HIGH(screenBuffer+20)
;LDI ZL, LOW(screenBuffer+20)
;LDI R16, 0b00100100
;ST Z+, R16
;LDI ZH, HIGH(screenBuffer+30)
;LDI ZL, LOW(screenBuffer+30)
;LDI R16, 0b00111100
;ST Z+, R16
;LDI ZH, HIGH(screenBuffer+40)
;LDI ZL, LOW(screenBuffer+40)
;LDI R16, 0b00100100
;ST Z+, R16
;LDI ZH, HIGH(screenBuffer+50)
;LDI ZL, LOW(screenBuffer+50)
;LDI R16, 0b00100100
;ST Z+, R16
;LDI ZH, HIGH(screenBuffer)
;LDI ZL, LOW(screenBuffer)
;



;LDI R20, 0 ; index of 'A' in FontTable
;LDI YH, HIGH(screenBuffer + 30)
;LDI YL, LOW(screenBuffer + 30)


RCALL Keyboard
LDS R16, doWePressKey
CPI R16,1
BRNE chekkeyboardagain


CPI R25,1
BREQ startGame
CPI R25,2
BREQ startGame
CPI R25,3
BREQ startGame
CPI R25,0
BREQ startGame

chekkeyboardagain:
RCALL Keyboard

RCALL DrawChar
RCALL DisplayPattern

RJMP splashScreen	

startGame:
SEI
;and place our character at an initial position
.EQU characterOffset1=0x300
.EQU characterOffset2=0x301
.EQU characterOffset3=0x302
.EQU characterOffset4=0x303

;do the same for obstacles + initialize
.EQU obstacleOffset1=0x376
LDI R16, 14 ;
STS obstacleOffset1, R16


.EQU obstacleOffset2=0x377
LDI R16, 44 ;
STS obstacleOffset2, R16

.EQU obstacleOffset3=0x378
LDI R16, 49
STS obstacleOffset3, R16

.EQU obstacleOffset4=0x379
LDI R16, 69

; we set up a ticking bomb to deploy each obstacle at different times
.EQU delayObstacle1= 0x66
LDI R16,0
STS delayObstacle1, R16

.EQU delayObstacle2 = 0x67
LDI R16,0;
STS delayObstacle2, R16

.EQU delayObstacle3=0x68
LDI R16,80
STS delayObstacle3,R16

.EQU delayObstacle4=0x69
LDI R16,50
STS delayObstacle4,R16


;for each counter, we have a delay 

;LDI R16, 50
;STS characterOffset1, R16
;LDI R16, 60
;STS characterOffset2, R16
;LDI R16, 5
;STS characterOffset3, R16
;LDI R16, 15
;STS characterOffset4, R16

;initial position for character..
LDI R16, 50
STS characterOffset1, R16
LDI R16, 60
STS characterOffset2, R16
LDI R16, 5
STS characterOffset3, R16
LDI R16, 15
STS characterOffset4, R16

;unfortunately simply doing ZH,HIGH(characterMap+characterOffsetLine) doesn't work. chacaterOffsetLine is treated
;as a '0', '1', '2', '3' and not as the value we store there.. so we need to use LDS to read the value and then do ADD

LDS R17, characteroffset1
LDI ZH, HIGH(characterMap)
LDI ZL, LOW(characterMap)
ADD ZL,R17 ; now  it will be characterMap + value at characteroffset1
ADC ZH, R1
LDI R16, 0b11110000
ST Z, R16

LDS R17, characteroffset2
LDI ZH, HIGH(characterMap)
LDI ZL, LOW(characterMap)
ADD ZL,R17
ADC ZH, R1
LDI R16, 0b11110000
ST Z, R16

LDS R17, characteroffset3
LDI ZH, HIGH(characterMap)
LDI ZL, LOW(characterMap)
LDI R16, 0b11110000
ADD ZL,R17
ADC ZH, R1
ST Z, R16

LDS R17, characteroffset4
LDI ZH, HIGH(characterMap)
LDI ZL, LOW(characterMap)
LDI R16, 0b11110000
ADD ZL,R17
ADC ZH, R1
ST Z, R16

RCALL WriteNewPatternToBuffer

;this  is just an initial pattern stuff to store in buffer at startup (debugging purposes)
;LDI ZH, HIGH(screenBuffer+6)
;LDI ZL, LOW(screenBuffer+6)
;LDI R16, 0b01111000
;ST Z+, R16
;LDI ZH, HIGH(screenBuffer+16)
;LDI ZL, LOW(screenBuffer+16)
;LDI R16, 0b01111000
;ST Z+, R16
;LDI ZH, HIGH(screenBuffer+61)
;LDI ZL, LOW(screenBuffer+61)
;LDI R16, 0b01111000
;ST Z+, R16
;LDI ZH, HIGH(screenBuffer+51)
;LDI ZL, LOW(screenBuffer+51)
;LDI R16, 0b01111000
;ST Z+, R16

;call function
;LDI ZH, HIGH(screenBuffer)
;LDI ZL, LOW(screenBuffer)

CLI
RCALL DisplayPattern
SEI

;debugging
LDI R16, 0b10000000
STS patternByte, R16

LDI R16, 0b10000000
STS patternByte2, R16

RJMP main





main:
	LDS R29, gameOverFlag
CPI R29, 1
BRNE GameContinues
JMP GameOver
GameContinues:
	
	RCALL Keyboard
	LDS R16, doWePressKey
	CPI R16,1
	BRNE BusinessAsUsual

	LDS R17,didWeHandleKeyboard
	CPI R17,0
	BREQ BusinessAsUsual

	;so now  we know the key has just been pressed and not handled yet
	;and we check which key was, and take action
	CPI R25,2
	BRNE SkipLed

	CBI PORTC,2
	;CLI
	LDS R16, doWePressKey
	CPI R16, 1
	BRNE skipCharacterMovement

	;we use another register to count if we have for whatever reason two presses at the same time
	LDI R18,0

	CPI R26,0
	BREQ CallMoveDown

	CPI R26,1
	BREQ CallMoveUp	

	CallMoveUp:
		CBI PORTC,2;debugging
		RCALL characterMovesUp
		SBI PORTC,2
		LDI R17,1
		STS didWeHandleKeyboard,R17
		RJMP BusinessAsUsual

	CallMoveDown:
		CBI PORTC,2
		RCALL characterMovesDown
		SBI PORTC,2
		LDI R17,1
		STS didWeHandleKeyboard,R17
		RJMP BusinessAsUsual
	
	BusinessAsUsual:
	LDS R17, doWeUpdateScreenFlag
	CPI R17,1
	BRNE NoScreenUpdate

	LDI R17,0
	STS doWeUpdateScreenFlag,R17

	LDI ZH, HIGH(screenBuffer)
	LDI ZL, LOW(screenBuffer)

	

	

	NoScreenUpdate:
		RCALL DisplayPattern
		;SBI PORTC,2
		;LDI R16,255
		;WasteTime:
		;	DEC R16
		;	BRNE WasteTime
		;CBI PORTC,2
		
		;CLI ;this andSEI below is to prevent writing to memory being interrupted by screen getting called to update -> ghost LEDs would occasionaly light up
		
		;RCALL characterMovesUp

		;if its time to update the display buffer
		LDS R17, doWeUpdateMemoryFlag
		CPI R17, 1
		BRNE skipBufferUpdate

		RCALL UpdateObstacleMap
		RCALL WriteNewPatternToBuffer
		LDS R17,0
		STS doWeUpdateMemoryFlag, R17;reset the flag
		;RCALL WriteNewPatternToBuffer
		;SEI

		;SBI PORTC,2
		;RCALL Keyboard
	
		
		;RJMP main

SkipBufferUpdate:
	;LDI R25, 99
	;LDI R26, 99
	;RCALL Keyboard
	;SEI


	LDI R16,0
	STS doWePressKey,R16
	;SEI
	;RJMP main

skipCharacterMovement:
	;SEI

SkipLed:
	SBI PORTC,2
	;SEI
	RJMP main

characterMovesUp:
	PUSH R0
	PUSH R1
	PUSH R16
	PUSH R17
	PUSH R18
	PUSH ZH
	PUSH ZL
	CLI
	LDI ZH, HIGH(characterMap)
	LDI ZL, LOW(characterMap)
	LDI R17,70
	clearmap2:
		LDI R16, 0b00000000 
		ST Z+, R16
		DEC R17
	BRNE clearmap2

	;debugging
	;LDI R16, 40
;STS characterOffset1, R16
;LDI R16, 50
;STS characterOffset2, R16
;LDI R16, 60
;STS characterOffset3, R16;
;LDI R16, 5
;STS characterOffset4, R16

;unfortunately simply doing ZH,HIGH(characterMap+characterOffsetLine) doesn't work. chacaterOffsetLine is treated
;as a '0', '1', '2', '3' and not as the value we store there.. so we need to use LDS to read the value and then do ADD

;LDS R17, characteroffset1
;LDI ZH, HIGH(characterMap)
;LDI ZL, LOW(characterMap)
;CLR R0
;ADD ZL,R17 ; now  it will be characterMap + value at characteroffset1
;ADC ZH, R0
;LDI R16, 0b11110000
;ST Z, R16

;LDS R17, characteroffset2
;LDI ZH, HIGH(characterMap)
;LDI ZL, LOW(characterMap)
;CLR R0
;ADD ZL,R17
;ADC ZH, R0
;LDI R16, 0b11110000
;ST Z, R16

;LDS R17, characteroffset3
;LDI ZH, HIGH(characterMap)
;LDI ZL, LOW(characterMap)
;LDI R16, 0b11110000
;CLR R0
;ADD ZL,R17
;ADC ZH, R0
;ST Z, R16

;LDS R17, characteroffset4
;LDI ZH, HIGH(characterMap)
;LDI ZL, LOW(characterMap)
;LDI R16, 0b11110000
;CLR R0
;ADD ZL,R17
;ADC ZH, R0
;ST Z, R16

	;we update the offsets. generally they decreease by 10 if character moves up, except if offset=5, then should become 60
	;due to awkward screen
	;line 1= 0-4
	;line 2= 10-14
	;line 3= 20-24
	;line 4= 30-34
	;line 5= 40-44
	;line6= 50-54
	;line7= 60-64
	;	----
	;line8=	5-9
	;line9= 15-19
	;line10=25-29
	;line 11= 35-39
	;line12= 45-49
    ;line13= 55-59
	;line14= 65-69

	;update the offset for each line..

	;generally, the rule is that if character moves up, offsets decrease by 10
	;however! offset1 cant be lower than 0. offset2 cant be lower than 10. offset3 cant be lower than 20. offset4 cant be lower than 30
	;that is the upper limit for character

	;also, the screen is split. so when any of the offsets is 5, it will become 60. if offset is  15, it will become 5. if offset is 60, then it will become 50 (rest of the logic still holds)

	;line 1
	LDS R16, characterOffset1
	CPI R16,5
	BREQ warpScreen1 ;if offset becomes 5 on this line, we're about  to go to the first half of the screen
	CPI R16,0
	BREQ DontAllowNegativeOffsets1
	SUBI R16,10
	RJMP updatechline1
	warpScreen1:
		LDI R16,60
		RJMP updatechline1
	DontAllowNegativeOffsets1:
		LDI R16,0
	updatechline1:
		STS characterOffset1, R16

	;line 2
	LDS R16, characterOffset2
	CPI R16,5
	BREQ warpScreen2
	CPI R16,10
	BREQ DontAllowNegativeOffsets2
	SUBI R16,10
	RJMP updatechline2
	warpScreen2:
		LDI R16,60
		RJMP updatechline2
	DontAllowNegativeOffsets2:
		LDI R16,10
	updatechline2:
		STS characterOffset2, R16

	;line 3
	LDS R16, characterOffset3
	CPI R16,5
	BREQ warpScreen3
	CPI R16,20
	BREQ DontAllowNegativeOffsets3
	SUBI R16,10
	RJMP updatechline3
	warpScreen3:
		LDI R16,60
		RJMP updatechline3
	DontAllowNegativeOffsets3:
		LDI R16,20
	updatechline3:
		STS characterOffset3, R16

	;line 4
	LDS R16, characterOffset4
	CPI R16,5
	BREQ warpScreen4
	CPI R16,30
	BREQ DontAllowNegativeOffsets4
	SUBI R16,10
	RJMP updatechline4
	warpScreen4:
		LDI R16,60
		RJMP updatechline4
	DontAllowNegativeOffsets4:
		LDI R16,30
	updatechline4:
		STS characterOffset4, R16

	;with the new offsets, update the character map
	
	LDS R17, characterOffset1
	LDI ZH,HIGH(charactermap)
	LDI ZL, LOW(characterMap)
	CLR R0
	ADD ZL, R17
	ADC ZH, R0
	LDI R18, 0b11110000
	ST Z,R18

	LDS R17, characterOffset2
	LDI ZH,HIGH(charactermap)
	LDI ZL, LOW(characterMap)
	CLR R0
	ADD ZL, R17
	ADC ZH, R0
	LDI R18, 0b11110000
	ST Z,R18

	LDS R17, characterOffset3
	LDI ZH,HIGH(charactermap)
	LDI ZL, LOW(characterMap)
	CLR R0
	ADD ZL, R17
	ADC ZH, R0
	LDI R18, 0b11110000
	ST Z,R18

	LDS R17, characterOffset4
	LDI ZH,HIGH(charactermap)
	LDI ZL, LOW(characterMap)
	CLR R0
	ADD ZL, R17
	ADC ZH, R0
	LDI R18, 0b11110000
	ST Z,R18
	
	RCALL WriteNewPatternToBuffer

	LDI ZH, HIGH(characterMap)
	LDI ZL, LOW(characterMap)
	LDI R17,70
	;clearmapagain:
	;	LDI R16, 0b00000000 
	;	ST Z+, R16
	;	DEC R17
	;BRNE clearmapagain
	SEI

	POP ZL
	POP ZH
	POP R18
	POP R17
	POP R16
	POP R1
	POP R0
	RET

characterMovesDown:
	PUSH R0
	PUSH R1
	PUSH R16
	PUSH R17
	PUSH R18
	PUSH ZH
	PUSH ZL
	CLI
	LDI ZH, HIGH(characterMap)
	LDI ZL, LOW(characterMap)
	LDI R17,70
	clearmapagain2:
		LDI R16, 0b00000000 
		ST Z+, R16
		DEC R17
	BRNE clearmapagain2


	;line 4
	LDS R16, characterOffset4
	CPI R16,60
	BREQ warpScreenDown4
	CPI R16,65
	BREQ DontAllowNegativeOffsetsDown4
	LDI R17,10;aux
	ADD R16,R17
	RJMP updatechlineDown4
	warpScreenDown4:
		LDI R16,5
		RJMP updatechlineDown4
	DontAllowNegativeOffsetsDown4:
		LDI R16,65
	updatechlineDown4:
		STS characterOffset4, R16

		;line 3
	LDS R16, characterOffset3
	CPI R16,60
	BREQ warpScreenDown3
	CPI R16,55
	BREQ DontAllowNegativeOffsetsDown3
	LDI R17,10;aux
	ADD R16,R17
	RJMP updatechlineDown3
	warpScreenDown3:
		LDI R16,5
		RJMP updatechlineDown3
	DontAllowNegativeOffsetsDown3:
		LDI R16,55
	updatechlineDown3:
		STS characterOffset3, R16

	;line 2
	LDS R16, characterOffset2
	CPI R16,60
	BREQ warpScreenDown2
	CPI R16,45
	BREQ DontAllowNegativeOffsetsDown2
	LDI R17,10;aux
	ADD R16,R17
	RJMP updatechlineDown2
	warpScreenDown2:
		LDI R16,5
		RJMP updatechlineDown2
	DontAllowNegativeOffsetsDown2:
		LDI R16,45
	updatechlineDown2:
		STS characterOffset2, R16

	;line 1
	LDS R16, characterOffset1
	CPI R16,60
	BREQ warpScreenDown1 ;if offset becomes 60 on this line, we're about  to go to the first half of the screen
	CPI R16,35
	BREQ DontAllowNegativeOffsetsDown1
	LDI R17,10;aux
	ADD R16,R17; INCREASE, unless we are on row 11
	RJMP updatechlineDown1
	warpScreenDown1:
		LDI R16,5;then it becomes 5
		RJMP updatechline1
	DontAllowNegativeOffsetsDown1:
		LDI R16,35 ; dont forget to clamp line
	updatechlineDown1:
		STS characterOffset1, R16

	;with the new offsets, update the character map
	
	LDS R17, characterOffset4
	LDI ZH,HIGH(charactermap)
	LDI ZL, LOW(characterMap)
	CLR R0
	ADD ZL, R17
	ADC ZH, R0
	LDI R18, 0b11110000
	ST Z,R18

	LDS R17, characterOffset3
	LDI ZH,HIGH(charactermap)
	LDI ZL, LOW(characterMap)
	CLR R0
	ADD ZL, R17
	ADC ZH, R0
	LDI R18, 0b11110000
	ST Z,R18

	LDS R17, characterOffset2
	LDI ZH,HIGH(charactermap)
	LDI ZL, LOW(characterMap)
	CLR R0
	ADD ZL, R17
	ADC ZH, R0
	LDI R18, 0b11110000
	ST Z,R18

	LDS R17, characterOffset1
	LDI ZH,HIGH(charactermap)
	LDI ZL, LOW(characterMap)
	CLR R0
	ADD ZL, R17
	ADC ZH, R0
	LDI R18, 0b11110000
	ST Z,R18
	
	RCALL WriteNewPatternToBuffer

	LDI ZH, HIGH(characterMap)
	LDI ZL, LOW(characterMap)
	LDI R17,70
	;clearmapagain:
	;	LDI R16, 0b00000000 
	;	ST Z+, R16
	;	DEC R17
	;BRNE clearmapagain
	
	SEI
	POP ZL
	POP ZH
	POP R18
	POP R17
	POP R16
	POP R1
	POP R0

	RET





UpdateObstacleMap:
	RCALL UpdateObstacle1
	RCALL UpdateObstacle2
	RCALL UpdateObstacle3
	RCALL UpdateObstacle4
	RET



UpdateObstacle1:
	PUSH R19
	PUSH R18
    PUSH R16
    PUSH R17
    PUSH ZH
    PUSH ZL

	;specifically obstacle 1
	;do we deploy it? or do we wait?
    LDS R19, delayObstacle1
    CPI R19, 0
    BRNE DecreaseDelay

	;we deploy it
    LDS R16, patternByte
    LSR R16
    STS patternByte, R16

    LDI ZH, HIGH(obstacleMap+10)
    LDI ZL, LOW(obstacleMap+10)
    LDI R17,5
	clearRow:
		LDI R18,0
		ST Z+, R18
		DEC R17
    BRNE clearRow

    LDS R17, obstacleOffset1
    LDI ZH, HIGH(obstacleMap)
    LDI ZL, LOW(obstacleMap)
    ADD ZL, R17
    ADC ZH, R1
    ST Z, R16

    CPI R16, 0
    BRNE Done

    DEC R17
    CPI R17, 9;if we reached beginning of line
    BRNE StoreNewOffset1
    LDI R17, 14;then wrap back around




StoreNewOffset1:
    STS obstacleOffset1, R17
    LDI R16, 0b10000000
    STS patternByte, R16

Done:
    RCALL WriteNewPatternToBuffer
    RJMP EndUpdateObstacle

DecreaseDelay:
    DEC R19
    STS delayObstacle1, R19
    RJMP EndUpdateObstacle

EndUpdateObstacle:
    POP ZL
    POP ZH
    POP R17
    POP R16
	POP R18
	POP  R19
    RET


UpdateObstacle2:
	PUSH R19
	PUSH R18
	PUSH R16
    PUSH R17
    PUSH ZH
    PUSH ZL

	;specifically obstacle 1
	;do we deploy it? or do we wait?
    LDS R19, delayObstacle2
    CPI R19, 0
    BRNE DecreaseDelay2

	LDS R16, patternByte2
    LSR R16
    STS patternByte2, R16

    LDI ZH, HIGH(obstacleMap+40)
    LDI ZL, LOW(obstacleMap+40)
    LDI R17,5
	clearRow2:
		LDI R18,0
		ST Z+, R18
		DEC R17
    BRNE clearRow2

	LDS R17, obstacleOffset2
    LDI ZH, HIGH(obstacleMap)
    LDI ZL, LOW(obstacleMap)
    ADD ZL, R17
    ADC ZH, R1
    ST Z, R16

	 CPI R16, 0
    BRNE Done2

    DEC R17
    CPI R17, 39;if we reached beginning of line
    BRNE StoreNewOffset2
    LDI R17, 44;then wrap back around

	StoreNewOffset2:
    STS obstacleOffset2, R17
    LDI R16, 0b10000000
    STS patternByte2, R16

Done2:
    RCALL WriteNewPatternToBuffer
    RJMP EndUpdateObstacle2

DecreaseDelay2:
    DEC R19
    STS delayObstacle2, R19
    RJMP EndUpdateObstacle2

EndUpdateObstacle2:
    POP ZL
    POP ZH
    POP R17
    POP R16
	POP R18
	POP R19
    RET

;obstacle3
UpdateObstacle3:
	PUSH R19
	PUSH R18
	PUSH R16
    PUSH R17
    PUSH ZH
    PUSH ZL

	;specifically obstacle 1
	;do we deploy it? or do we wait?
    LDS R19, delayObstacle3
    CPI R19, 0
    BRNE DecreaseDelay3

	LDS R16, patternByte3
    LSR R16
    STS patternByte3, R16

    LDI ZH, HIGH(obstacleMap+45)
    LDI ZL, LOW(obstacleMap+45)
    LDI R17,5
	clearRow3:
		LDI R18,0
		ST Z+, R18
		DEC R17
    BRNE clearRow3

	LDS R17, obstacleOffset3
    LDI ZH, HIGH(obstacleMap)
    LDI ZL, LOW(obstacleMap)
    ADD ZL, R17
    ADC ZH, R1
    ST Z, R16

	 CPI R16, 0
    BRNE Done3

    DEC R17
    CPI R17, 44;if we reached beginning of line
    BRNE StoreNewOffset3
    LDI R17, 49;then wrap back around

	StoreNewOffset3:
    STS obstacleOffset3, R17
    LDI R16, 0b10000000
    STS patternByte3, R16

Done3:
    RCALL WriteNewPatternToBuffer
    RJMP EndUpdateObstacle3

DecreaseDelay3:
    DEC R19
    STS delayObstacle3, R19
    RJMP EndUpdateObstacle3

EndUpdateObstacle3:
    POP ZL
    POP ZH
    POP R17
    POP R16
	POP R18
	POP R19
    RET

UpdateObstacle4:
	PUSH R19
	PUSH R18
	PUSH R16
    PUSH R17
    PUSH ZH
    PUSH ZL

	;specifically obstacle 1
	;do we deploy it? or do we wait?
    LDS R19, delayObstacle4
    CPI R19, 0
    BRNE DecreaseDelay4

	LDS R16, patternByte4
    LSR R16
    STS patternByte4, R16

    LDI ZH, HIGH(obstacleMap+64)
    LDI ZL, LOW(obstacleMap+64)
    LDI R17,5
	clearRow4:
		LDI R18,0
		ST Z+, R18
		DEC R17
    BRNE clearRow4

	LDS R17, obstacleOffset4
    LDI ZH, HIGH(obstacleMap)
    LDI ZL, LOW(obstacleMap)
    ADD ZL, R17
    ADC ZH, R1
    ST Z, R16

	 CPI R16, 0
    BRNE Done4

    DEC R17
    CPI R17, 64;if we reached beginning of line
    BRNE StoreNewOffset4
    LDI R17, 69;then wrap back around

	StoreNewOffset4:
    STS obstacleOffset4, R17
    LDI R16, 0b10000000
    STS patternByte4, R16

Done4:
    RCALL WriteNewPatternToBuffer
    RJMP EndUpdateObstacle4

DecreaseDelay4:
    DEC R19
    STS delayObstacle4, R19
    RJMP EndUpdateObstacle4

EndUpdateObstacle4:
    POP ZL
    POP ZH
    POP R17
    POP R16
	POP  R18
	POP R19
    RET


WriteNewPatternToBuffer:
		PUSH R16
		PUSH R30
		PUSH R31

		;initially, this was doing an animation, as below:
		CLI

		;then lets change whats stored in buffer
		LDI ZH, HIGH(screenBuffer)
		LDI ZL, LOW(screenBuffer)
		LDI R17,70

		;cleaning memory not necessary since we copy from charactermap which is already cleaned 
		;CleanMemoryLoop:
		;	LDI R16, 0b00000000 ; first clear memory
		;	ST Z+, R16
		;	DEC R17
		;BRNE CleanMemoryLoop

		;LDS R16, patternByte
		;ROR R16; next frame the pattern will be different => animation
		;STS patternByte, R16
		;CPI R16, 0
		;BREQ ReinitiatePattern
	
		

		;LDI ZH, HIGH(screenBuffer+0)
		;LDI ZL, LOW(screenBuffer+0)
		;ST Z, R16

		;LDI ZH, HIGH(screenBuffer+10)
		;LDI ZL, LOW(screenBuffer+10)
		;ST Z, R16

		;LDI ZH, HIGH(screenBuffer+1)
		;LDI ZL, LOW(screenBuffer+1)
		;ST Z, R16

		;LDI ZH, HIGH(screenBuffer+11)
		;LDI ZL, LOW(screenBuffer+11)
		;ST Z, R16

		;LDI ZH, HIGH(screenBuffer+2)
		;LDI ZL, LOW(screenBuffer+2)
		;ST Z, R16

		;LDI ZH, HIGH(screenBuffer+22)
		;LDI ZL, LOW(screenBuffer+22)
		;ST Z, R16

		;LDI ZH, HIGH(screenBuffer+3)
		;LDI ZL, LOW(screenBuffer+3)
		;ST Z, R16

		;LDI ZH, HIGH(screenBuffer+32)
		;LDI ZL, LOW(screenBuffer+33)
		;LDI R16, 0b11111111
		;ST Z, R16

		;LDI ZH, HIGH(screenBuffer+4)
		;LDI ZL, LOW(screenBuffer+4)
		;ST Z, R16

		;LDI ZH, HIGH(screenBuffer+44)
		;LDI ZL, LOW(screenBuffer+44)
		;ST Z, R16

		;however, we want to have a consistent map of obstacles and character position, that we shouldnt refresh and then hardcode at each frame
		;for this we use another memorybuffer and then copy it to screenbuffer

		LDI ZH, HIGH(characterMap)
		LDI ZL, LOW(characterMap)

		LDI XH, HIGH(obstacleMap)
		LDI XL, LOW(obstacleMap)

		LDI YH, HIGH(screenBuffer)
		LDI YL, LOW(screenBuffer)
		LDI  R17,70
		copyCharacterOrObstacleToScreen:
			LD R16,Z+
			LD R18, X+

			;this bit of the logic is for obstacle colision
			MOV R19, R16; copy of character byte (current)
			AND R19,R18
			CPI R19,0
			BREQ NoCollision

			LDI R20,1
			STS gameOverFlag,R20
			CBI PORTC,2

			NoCollision: ;all resumes as  usual
			OR R16,R18 ; this is what gets shown
			ST Y+,R16
			DEC R17
			BRNE copyCharacterOrObstacleToScreen

		SEI

		POP R31
		POP R30
		POP R16
	RET

;ReinitiatePattern:
;	LDI R16,0b10000000
;	STS patternByte,R16
	POP R31
	POP R30
	POP R16
	RET
	

Keyboard:
	; keyboard -> DDRD, PORTD. columns = PD0-PD3, rows=PD4-PD7
	; all rows are cleared
	; if all cols  are high, exit (no button pressed)
	; else, store the column number that was low

	; all columns are cleared
	;  set rows as input (pull up resistor)
	; if any row is low, we store it

	; at then end we get (row, col) of pressed button and return to main
	; OR we keep iterating

	
	; so we start with step 1. rows are 'outputs'
	PUSH R16
    PUSH R17
    PUSH R18
    PUSH R19
    PUSH R20
    PUSH R21
    PUSH R30
	
	LDI R16, 0b11110000
	OUT DDRD, R16; equivalent to doing SBI on every bit for rows
	LDI R16, 0b00000000
	OUT PORTD, R16

	; we now ask if all columns are high -> then no button is pressed, we just rjmp to start of routine
	; we must first configure THEN read the column pins
	
	; we must do an equivalent of CBI DDRD,0-3 and then SBI PORTD,0-3
	IN R17, DDRD
	ANDI R17, 0b11110000
	OUT DDRD, R17

	IN  R17, PORTD
	ORI R17, 0b00001111
	OUT PORTD, R17

	;reconfigure PD0-PD3 to be pulled low
	IN R17, DDRD
	ORI R17, 0b00001111
	OUT DDRD, R17

	IN R17, PORTD
	ANDI R17, 0b11110000 
	OUT PORTD, R17

	; now we read the column pins
	IN R17, PIND
	ANDI R17, 0b00001111; since we re only interested in PIND,0-3

	; we check if all columns are high, then it means no key is pressed and we restart the routine
	CPI R17, 0b00001111
	;BREQ Keyboard <-no longer call this if we have a function instead of a routine. this leads to stackoverflow
	BREQ NoKeyPressed

	LDI R18, 14; 0b00001110
	LDI R19, 13; 0b00001101
	LDI R20, 11; 0b00001011
	LDI R21, 7;0b00000111
	CP R17, R18 ; if these are equal, then column corresponding to pressed button is the 0 one
	BREQ Col0
	CP R17, R19 ; if these are equal, then column corresponding to pressed button is the 1 one
	BREQ Col1
	CP R17, R20 ; if these are equal, then cfor olumn corresponding to pressed button is the 2 one
	BREQ Col2
	CP R17, R21 ; if these are equal, then column corresponding to pressed button is the 3 one
	BREQ Col3

Col0:
	LDI R25, 0; column 0 pressed
	;CBI PORTC,2 
	RJMP Step2
Col1:
	LDI R25,1
	;CBI PORTC,2 
	RJMP Step2
Col2:
	LDI R25,2
	;CBI PORTC,2 
	RJMP Step2
Col3:
	LDI R25,3
	;CBI PORTC,2 
	RJMP Step2

Step2:
	;rows become inputs -> all columns are LOW
	IN R17, DDRD
	ANDI R17, 0b00001111
	OUT DDRD, R17

	IN  R17, PORTD
	ORI R17, 0b11110000
	OUT PORTD, R17

	LDI R30, 255
	RowWait: //WAIT because of  metastability bullshit, otherwise it will not  work
		DEC R30
		BRNE RowWait
	
	; read row pins
	IN R17, PIND
	ANDI R17, 0b11110000; since we re only interested in PIND,4-7

	;if any row pins are low, store them
	LDI R18, 224; 0b11100000
	LDI R19, 208; 0b11010000
	LDI R20, 176; 0b10110000
	LDI R21, 112; 0b01110000
	CP R17, R18 ; if these are equal, then row corresponding to pressed button is the 0 one
	BREQ Row0
	CP R17, R19 ; if these are equal, then row corresponding to pressed button is the 1 one
	BREQ Row1
	CP R17, R20 ; if these are equal, then row corresponding to pressed button is the 2 one
	BREQ Row2
	CP R17, R21 ; if these are equal, then row corresponding to pressed button is the 3 one
	BREQ Row3

	RET

Row0:
	LDI R26, 0;
	RJMP ButtonFound
Row1:
	LDI R26,1;
	RJMP ButtonFound
Row2:
	LDI R26,2;
	RJMP ButtonFound
Row3:
	LDI R26,3
	RJMP ButtonFound

ButtonFound:
	LDI R16,  1
	STS doWePressKey, R16
	
	POP R30
    POP R21
    POP R20
    POP R19
    POP R18
    POP R17
    POP R16
    RET

NoKeyPressed:
	LDI R16,  0
	STS doWePressKey, R16

	POP R30
    POP R21
    POP R20
    POP R19
    POP R18
    POP R17
    POP R16
	CLR R25
	CLR R26
    RET


DisplayPattern:
	;we define a screen buffer in SRAM
	;fill it with data
	
	;loop: for each row
	;	select row (set bit corresponding to current row, clear the other rows
	;	load the 80 bits from the screen buffer for that row (=10 memory addresses)
	;		shift:
	;			for  each of the 80 bits  = 10 registers 
	;				clear/set the bit
	;				pulse clock
	;		shift:
	;			for the last 8 bits (for rows)
	;				clear/set bit
	;				pulse clock
	;		latch:
	;			clear pb4,  set pb4, clear pb4
	;		add small time delay

	;load the address to SRAM wehre buffer is


	;then we go over each address, and at that address in buffer
	;we set the value to be 1 (will turn on LED there)
	;and then we move on to next address by postincrementing with the pointer

	


	;--------this stuff works to show a pattern of 1s and 0s (of 8 bits) continuously----;
	;LDI R17, 70
	;	LDI R16, 0b00000011
	;LDI R18, 0b01001111
	;fill_pixel_values2:
	;	ST Z+, R16
		;EOR R16,R18
		;COM R16;for chess board pattern
	;	DEC R17
	;BRNE fill_pixel_values2



	;   LDI ZH, HIGH(screenBuffer)
   ;LDI ZL, LOW(screenBuffer)
    ;LDI R16, 0b00000001    ; All LEDs off is represented by 0
;    LDI R17, 70      ; 70 bytes to clear
;ClearLoop:
 ;   ST Z+, R16
  ;  DEC R17
   ; BRNE ClearLoop
	
	;LDI ZH, HIGH(screenBuffer)
    ;LDI ZL, LOW(screenBuffer)
    ;LDI R16, 0xFF   ; 0xFF means all 8 bits ON (assuming active-high LED drive)
    ;ST Z+, R16
;
	;LDI ZH, HIGH(screenBuffer+15)
    ;LDI ZL, LOW(screenBuffer +15)
    ;LDI R16, 0xFF   ; 0xFF means all 8 bits ON (assuming active-high LED drive);
	;ST Z, R16
	; --- Clear screen ---
;LDI ZH, HIGH(screenBuffer)
;LDI ZL, LOW(screenBuffer)
;LDI R16, 0
;LDI R17, 70
;ClearLoop:
;    ST Z+, R16
;    DEC R17
;   BRNE ClearLoop

; --- Set a full row (row 2, columns 0–7) ON ---
; LDI   R20, 2         ; row 2
 ;  LDI   R22, 10
  ; MUL   R20, R22       ; offset = 20 (in R1:R0)
   ; now add that offset to screenBuffer; make sure to use ADC for the high byte
   ;LDI   ZH, HIGH(screenBuffer)
   ;LDI   ZL, LOW(screenBuffer)
   ;ADD   ZL, R0
   ;ADC   ZH, R1
   ;LDI   R16, 0b10000000
   ;ST    Z, R16

;LDI R30, LOW(screenBuffer + 30) ; 2 * 10 = row offset
;LDI R31, HIGH(screenBuffer + 30)
;LDI R16, 0b10000000
;ST Z, R16
	MOV R2, R30
	MOV R3, R31
	PUSH R0
    PUSH R1
    PUSH R16
    PUSH R17
    PUSH R18
    PUSH R19
    PUSH R20
    PUSH R21
    PUSH R22
    PUSH R23
    PUSH R24
    PUSH R25
    PUSH R26
    PUSH R27
    PUSH R28
    PUSH R29
    PUSH R30
    PUSH R31
	
	LDI R20,7
	LDI R28,1
	LoopOverRows:
		; we prepare the bits to send for each row
		CLR R0
		CLR R1
		MOV R19,  R20;  R19 gets 6...5...5,0 at each iteration (current row index)
		LDI R22, 10; just to use as multiplier 
		MUL R19, R22 ; R1 will be 70, 60, 50, 40.. in memory space as we loop over rows
		; as a 16-bit result in R1 and R0

	
		;LDI ZH, HIGH(screenBuffer); base addresses
		;LDI ZL, LOW(screenBuffer)
		;the lines above worked when this was a routine. now it becomes a function, and we pass the pointer

		MOV ZL, R2
		MOV ZH, R3
		ADD ZL, R0
		ADC ZH, R1
		;the lines above are the replacements of the lines below: (now that this is using the stack)
		;ADD ZL, R0; base address+
		;ADC ZH, R1;ADC instead of ADD to propagate overflows?
		;  pointer to the memory address where current row starts
		; (base addresses + 490, 420,  350, 280..)

		;now we loop over all 80 bits of a row
		LDI R23, 10; byte counter
		LoopOverColumns:
			; 1.extract bits found at address in ZH, ZL. then post  increement to move to next byte
			LD R24, -Z
			//MOV R29, R24
			 //for each row, these columns should be on (01110)
			;LDI R24, 0b01001000

			; 2. PB3 closed or not depending on bits found at address
			; PB3 is the data pin register to shift register 
			; PB5 is the clock pin (shift bit from Pb3 to register at rising edge)
			LDI R25, 8; 8 bits to send (and  iterate over)
			LDI R26, 128; this  will be our mask to check each bit. initially 0b10000000, then this gets shifted 

			BitLoop:
				MOV R27, R26  ; we use R27 as an auxiliary so not to lose the mask when shifting
				AND R27, R24; andbetween bits and mask
				BREQ SendZero
				SBI PORTB,3
				RJMP PulseClk
							
			SendZero:
				CBI PORTB,3 ; send zero 
			
			PulseClk:
				CBI PORTB,5
				SBI PORTB,5; when high, latch bit into shift register
				LSR R26
				DEC R25
				BRNE BitLoop

			DEC  R23
			BRNE LoopOverColumns

		
		;last 8bits are at address pointed by Z, if we incremented everything correctly
		;R20 alrready contains current row index
		;we want for each row (7 rows), based on current row index, to send the sequence of bits
		;equating to a byte that tell the display which of the rows is enabled or not

		;force columns high (debugging)
		;LDI R25, 80
		;ForceColsHigh:
		;	SBI PORTB,3
		;	CBI PORTB,5
		;	SBI PORTB,5
		;	DEC R25
		;	BRNE ForceColsHigh

		;we  iterate over the rows

		MOV R16,R20

		LDI R30,1
		
		CPI R16,0
		LDI R30,255
			ComputeRowMask:
			BREQ RowMaskComputed
			ROL R30
			DEC R16
			RJMP ComputeRowMask
		RowMaskComputed:
			CLC
			LDI R25,8


		;LDI R25, 8; 8 bits per row select

		;LDI R29, 0b1000000 ; //RROW
		
		;LDI R31,8
		;SUB R31,R20; //R31=7-current_row
		
		;LDI R30,1
		;CLC
		;RowPatterncalc:
		;	CPI R31,0
		;	BREQ RowBitLoop
		;	LSL R30
		;	DEC R31
		;	RJMP RowPatterncalc
		

		;LDI R28, 0b11001011

		//
		RowBitLoop:
			;compare bits at address pointed by Z with a mask that we shift at each iteration
			;if mask at bit =1, then we send a 1, else send a 0

			;MOV R27, R28 ;make a copy of the mask
			ROL R30
			//AND R27, R26; compare mask with the last 8 bits from displayBuffer
			BRCC RowSendZero ; if rowIndex bit is  0, we go and clear PB3 (LED not on)
			CBI PORTB,3
			RJMP pulseClk2
			
			RowSendZero: 
				SBI PORTB,3 ;the opposite friom columns, these need to be turned ON for current to pass

			pulseClk2:
			CBI PORTB,5
			SBI PORTB,5
			;LSR R28
			DEC R25
		
			
			BRNE RowBitLoop

		;now latch
		;ROL R28
		CBI PORTB,4
		SBI PORTB,4
		LDI R16, 255
		WasteTime3:
			DEC R16
			BRNE WasteTime3
		CBI PORTB,4

		//LDI R28, 50
		
		DEC R20

		

		BRNE LoopOverRows

		POP R31
    POP R30
    POP R29
    POP R28
    POP R27
    POP R26
    POP R25
    POP R24
    POP R23
    POP R22
    POP R21
    POP R20
    POP R19
    POP R18
    POP R17
    POP R16
    POP R1
    POP R0
    RET

	
 timerOverfInterrupt:
	LDI R16, 1
	STS doWeUpdateScreenFlag, R16
	RETI

timerOverfInterrupt2:
	CBI PORTC,2
	LDI R16,1
	STS doWeUpdateMemoryFlag, R16
	RETI

GameOver:
	;clear screen + clear character map, character=0,  clear obstacles + show game over screen
	LDI ZH, HIGH(characterMap)
	LDI ZL, LOW(characterMap)
	LDI R17,70
clearmapagain:
	LDI R16, 0b00000000 
	ST Z+, R16
	DEC R17
	BRNE clearmapagain

RJMP GameOverScreen
	


