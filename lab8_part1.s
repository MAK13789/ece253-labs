		  .text
		  .global _start
		  .global ONES

_start:
		  MOV 	R5, #0 			// largest consecutive number of 1s.
		  MOV	R7, #0			// Offset to load the next word by.

M_LOOP:	  LDR	R3,=TEST_NUM	// Load TEST_NUM address in R1.
		  LDR	R1, [R3, R7]	// Load into R1 the TEST_NUM word at offset.

		  CMP	R1, #-1
		  BEQ	END				// We have reached the terminating word. Finished.

		  BL 	ONES		// Jump to the ONES function after loading data in R1.
		  CMP 	R5, R0
		  MOVLT R5, R0			// Update R5 if R5 is smaller than R0
		  ADD	R7, #4			// Move to the next word.
		  B		M_LOOP

ONES:	  // recieves data in R1, returns result in R0
		  MOV	R0,#0 // Reset R0 to 0 to keep the count.
LOOP:	  CMP	R1,#0 // Loop until no more ones.
		  MOVEQ	PC, LR	// If done counting, go back to the calling function.
		  LSR	R2,R1,#1
		  AND	R1,R1,R2
		  ADD	R0,#1 // add to keep count.
		  B		LOOP
		  
END:	  B 	END

		  .data
TEST_NUM: .word 0x103fe00f, 50019, 0xC, 104920, 1110101, 0x1001C, 6, 69, 100, 420, 99999999, -1

.end