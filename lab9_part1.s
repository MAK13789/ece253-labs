	.text
	.global _start

    // Addresses taken from https://www-ug.eecg.utoronto.ca/desl/arm_SoC.html
    .equ LEDR_addr, 0xFF200000
    .equ KEY_addr, 0xFF200050
    .equ timer_addr, 0xFFFEC600 	// base address of timer (ARM A9 Private Timer)
    .equ delay_time, 50000000 // 200Mhz clock. Should be 0.25 seconds.

_start: 
    // Port addresses.
	LDR R8, =LEDR_addr
	LDR R9, =KEY_addr
	LDR R4, =timer_addr

	// Initial value.
    MOV R10,#512 // 0b1000000000 // pattern left.
    MOV R11,#1 // 0b0000000001 // pattern right.

	ORR R1, R10, R11
    MOV R3, #0 // 0 = IN, 1 = OUT. Direction.
	MOV R2, #0 // Key pressed?
M_LOOP:
    STR R1, [R8] // Set the pattern.
	LDR R6, [R9]
	MOV R2, R6 // if key pressed, R2 is #8.
    
    // change direction if we hit the 'walls' and also update the leds if not.
    CMP R3, #0
    BLEQ S_IN
    BLNE S_OUT

    CMP R3, #0 // Direction inwards is EQ, Outwards is NE.
    LSREQ R10, #1 // If inwards, shift left pattern right
    LSLEQ R11, #1 // If inwards, shift right pattern left

    LSLNE R10, #1
    LSRNE R11, #1
    ORR R1, R10, R11 // combine both patterns.

    BL DELAY

	CMP R2, #8
	BLEQ CHECK_PRESS

    B M_LOOP

CHECK_PRESS:
	LDR R6, [R9]
    CMP R6, #0 // (1000) = KEY3.
    BLEQ PRESS_2 // if key not pressed, go check that out. It means that the key was released.
	MOV PC, LR

S_IN:
//    CMP R1, #48 // 0b0000110000 LEDR5 and LEDR4 are both on.
//	MOVEQ R12, #1
//	CMP R11, #32
	CMP R10, #32 // 0b0000100000
    MOVEQ R3, #1 // change direction.
    MOV PC, LR

S_OUT:
//    CMP R1, #513 // 0b1000000001 LEDR9 and LEDR0 are both on.
//	ORR R1, R10, R11
	CMP R11, #1
    MOVEQ R3, #0 // change direction.
    MOV PC, LR

DELAY:
    LDR R0, =delay_time	// how many clock cycles before the delay finishes
	STR R0, [R4]		// put this in the timer base address (start value)
	MOV R0, #3 // 0b011		// I = 0, A = E = 1, no interrupts. auto-restart. enabled.
	STR R0, [R4, #8]	// put this in control register
LOOP: // Polling loop.
    LDR R0, [R4, #0xC]	// fetch interrupt status
	CMP R0, #0		// is counter done? (0 is not done)
	BEQ LOOP		// loop until counter reports done
	STR R0, [R4, #0xC]	// reset interrupt status to 0
	MOV PC, LR		// finish counting, exit DELAY subroutine

PRESS_2:
	LDR R6, [R9]
    CMP R6, #8 // key3 pressed if true.
    BNE PRESS_2
PRESS_3:
	LDR R6, [R9]
    CMP R6, #0 // key3 not pressed if true.
	BNE PRESS_3
	BL DELAY
	B M_LOOP