.text
.global _start
_start:
	LDR R1, = TEST_NUM
	MOV R8, #0
	MOV R7, #0
	LOOP: 
		  LDR R2, [R1]
		  CMP R2, #0
		  BLT END
		  ADD R8, R8, #1
		  ADD R7, R7, R2
		  ADD R1, R1, #4
		  B LOOP
END: B END

.end