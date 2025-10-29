# avr endless runner

This project is a hand-rolled game engine for a 7 x 80 LED matrix display driven by STP08DP05 shift registers, controlled by an ATmega328P microcontroller. Yes, the same chip used in the Arduino Uno, but here it’s running bare-metal assembly.
The game renders in real time, with animated obstacles, collision detection, and keyboard input, orchestrated via hardware timers and interrupts.

# Features
## Fully interrupt-driven architecture:
- Timer0 handles the screen refresh (1 ms rate).
- Timer1 drives the game logic updates (≈30 ms period).

## Dual memory-buffer system:
- characterMap and obstacleMap merged into a single screenBuffer. this prevents flicker and tearing during display refresh.

## Collision detection:
Performed bitwise between character and obstacle maps. Triggers a gameOverFlag when a collision is detected.

## Keyboard scanning routine (4×4 matrix keypad):
Implemented entirely in assembly with debounce and metastability protection; this is done by dynamic reconfiguration of DDRD and PORTD registers.

## Modularized code structure:
Independent subroutines for movement, obstacle logic, and display. Interrupts, flags, and buffers are neatly separated in SRAM.

## Splash screen and clean startup/reset sequence

# SRAM memory layout
| Label | Address |  Description |
|-------|---------|----------------------------|
| screenBuffer	| 0x0130 |	LED display buffer (70 bytes)|
| characterMap	| 0x0305	| current positions of pixels corresp. to character |
| obstacleMap	| 0x0380	| current positions of Moving obstacles |
| doWeUpdateScreenFlag |	0x0200 |	trigger for screen refresh |
|doWeUpdateMemoryFlag	| 0x0201 |	trigger for game logic update |
|gameOverFlag	| 0x0454	| Collision flag |
|patternByte(1–4)	| 0x0203–0x0453 |	obstacle pattern animation state |
|delayObstacle(1–4)	| 0x0066–0x0069 |	per-obstacle timers |

----

# Game Logic Summary

## Character movement:
characterMovesUp and characterMovesDown shift player offsets within defined row bounds, wrapping between upper/lower halves of the matrix.

## Obstacle updates:
Each obstacle has its own offset and delay counter (delayObstacleX).
When its delay hits zero, it begins shifting across the screen.

## Collision detection:
Happens inside WriteNewPatternToBuffer:

```asm
MOV R19, R16   ; character byte
AND R19, R18   ; overlap with obstacle byte?
CPI R19, 0
BREQ NoCollision
LDI R20,1
STS gameOverFlag,R20
```

## Display update:
DisplayPattern streams 80 x 7 bits via shift registers, row by row, pulsing the latch and clock lines.
