; this code gets two unsigned numbers from the user
; ,computes their prime factors
; ,computes their LCM & GCM
; and displays all results

include "emu8086.inc"

;=========================================
; *** MACROS ***  

; So much faster than the macro provided in emu8086.inc
M_PRINT    MACRO   str_
LOCAL       s, skip
            
            JMP     skip
            s       db  str_,"$"
    skip:   PUSH    AX
            PUSH    DX
            
            MOV     AH, 9
            LEA     DX, s
            INT     21H
            
            POP     DX
            POP     AX
                        
ENDM

            
;=========================================

name "prime"

org     100h


            ;get first number
            M_PRINT "Enter the 1st number: "
            CALL    scan_num                ;get the number
            MOV     num_1, CL               ;save it
            M_PRINT 0Dh                     ;new line
            M_PRINT 0Ah                             
            
            ;get first number
            M_PRINT "Enter the 2nd number: "
            CALL    scan_num                ;get the number
            MOV     num_2, CL               ;save it
            M_PRINT 0Dh                     ;new line
            M_PRINT 0Ah
 
        
            ;prime factorization of 1st number
            MOV     DH, 2                   ;prime factor
            MOV     DI, 0                   ;prime factor array index
            MOV     DL, num_1               ;temp copy of num_1 to be modified in iterations
        
P1:         MOV     AL, DL                  ;fit the number in AX for division
            MOV     AH, 0                                                     
            DIV     DH                      ;AL = AX / DH, AH = remainder
            CMP     AH, 0                   ;check remainder
            JZ      RZ1                              
            INC     DH                      ;   - remainder not zero, invalid prime factor
                                            ;   - increment prime factor
            JMP     P1                      ;   - loop over.
                                            ;   + remainder zero, valid prime factor
RZ1:        MOV     prime_1[DI], DH         ;   + store the current prime factor
            INC     DI                      ;   + increase prime factor array index 
            CMP     AL, 1                   ;Is the division result 1 ?
            JZ      FINISHED1               ;   + yes, factorization is done, exit
            MOV     DL, AL                  ;   - No, update the number
            JMP     P1                      ;   - loop again
FINISHED1: 



            ;prime factorization of 1st number
            MOV     DH, 2                   ;prime factor
            MOV     DI, 0                   ;prime factor array index
            MOV     DL, num_2               ;temp copy of num_1 to be modified in iterations
        
P2:         MOV     AL, DL                  ;fit the number in AX for division
            MOV     AH, 0                                                     
            DIV     DH                      ;AL = AX / DH, AH = remainder
            CMP     AH, 0                   ;check remainder
            JZ      RZ2                            
            INC     DH                      ;   - remainder not zero, invalid prime factor
                                            ;   - increment prime factor
            JMP     P2                      ;   - loop over.
                                            ;   + remainder zero, valid prime factor
RZ2:        MOV     prime_2[DI], DH         ;   + store the current prime factor
            INC     DI                      ;   + increase prime factor array index
            CMP     AL, 1                   ;Is the division result 1 ? 
            JZ      FINISHED2               ;   + yes, factorization is done, exit
            MOV     DL, AL                  ;   - No, update the number
            JMP     P2                      ;   - loop again
FINISHED2: 



            ;calculating GCD
            MOV     DI, 0                   ;i
            MOV     SI, 0                   ;k
            MOV     BX, 0                   ;j
G1:         CMP     prime_1[DI], 0          ;is a[i] equal to zero?
            JE      EX                      ;yes, exit

G2:         MOV     AL, prime_1[DI]
            CMP     AL, prime_2[BX+SI]      ;is a[i] equal to b[j+k] ?
            JNE     G3                      ;no
            MUL     gcd                     ;yes, update gcd = gcd * a(i)
            MOV     GCD, AL
            INC     DI                      ;update i, j and k
            INC     SI                      
            ADD     BX, SI
            MOV     SI, 0
            JMP     G1                                  

G3:         CMP     prime_2[BX+SI], 0
            JNE     G4
            INC     DI
            MOV     SI, 0
            JMP     G1
G4:         INC     SI
            JMP     G2
            
EX:         

            ;calculating LCM = ( a * b / GCD )
            MOV     AL, num_1
            MUL     num_2               ;AX = a * b
            MOV     DX, 0
            MOV     BH, 0               ;AL = AX / GCD
            MOV     BL, GCD
            DIV     BX                  ;I used BX as operand to force Word Division
            MOV     lcm, AX
            
            
            

            ;printing numbers
            M_PRINT "*******************************"
            M_PRINT 0Dh                     ;new line
            M_PRINT 0Ah
            M_PRINT "1st number: "
            MOV     AH, 00H                 ;store the number in AX
            MOV     AL, num_1
            CALL    print_num_uns           ;print it
            M_PRINT "  prime factors: "
            MOV     SI, 0                   ;index
b1:         CMP     prime_1[SI], 0          ;loop over prime factors array
            JE      b2                      ;if you find a zero element exit
            MOV     AL, prime_1[SI]         ;store the number in AX
            CALL    print_num_uns           ;print it
            M_PRINT " "                     ;space seperation
            INC     SI                      ;increment the index
            JMP     b1                

b2:         M_PRINT 0Dh                     ;new line
            M_PRINT 0Ah
            M_PRINT   "2nd number: "        
            MOV     AL, num_2               ;store the number in AX
            CALL    print_num_uns           ;print it
            M_PRINT "  prime factors: "
            MOV     SI, 0                   ;index
b3:         CMP     prime_2[SI], 0          ;loop over prime factors array
            JE      b4                      ;if you find a zero element exit
            MOV     AL, prime_2[SI]         ;store the number in AX
            CALL    print_num_uns           ;print it
            M_PRINT " "                     ;space seperation
            INC     SI                      ;increment the index
            JMP     b3       

b4:         M_PRINT 0Dh                     ;new line
            M_PRINT 0Ah
            PRINT   "LCM:  "
            MOV     AX, lcm
            CALL    print_num_uns
            M_PRINT 0Dh                     ;new line
            M_PRINT 0Ah
            PRINT   "GCD:  "  
            MOV     AH, 0
            MOV     AL, gcd
            CALL    print_num_uns


RET


;================================================
num_1       db      ?
num_2       db      ?
prime_1     db      8 dup(0)
prime_2     db      8 dup(0)
gcd         db      1
lcm         dw      1


DEFINE_SCAN_NUM
DEFINE_PRINT_STRING
DEFINE_PRINT_NUM_UNS
 
END