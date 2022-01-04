.global ONES

ONES:      // recieves data in R1, returns result in R0
          MOV    R0,#0 // Reset R0 to 0 to keep the count.
LOOP:      CMP    R1,#0 // Loop until no more ones.
          MOVEQ    PC, LR    // If done counting, go back to the calling function.
          LSR    R2,R1,#1
          AND    R1,R1,R2
          ADD    R0,#1 // add to keep count.
          B        LOOP