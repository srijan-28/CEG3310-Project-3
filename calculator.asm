.ORIG x3000

; =====================================================
; MAIN PROGRAM
; =====================================================

MAIN
    ; Ask for first number
    LEA R0, PROMPT1
    PUTS
    JSR GETNUM
    ADD R4, R0, #0          ; save first number in R4

    ; Ask for operation
    LEA R0, PROMPTOP
    PUTS
    JSR GETOP
    ADD R5, R0, #0          ; save operation in R5

    ; Ask for second number
    LEA R0, PROMPT2
    PUTS
    JSR GETNUM
    ADD R1, R0, #0          ; second number goes into R1

    ; Prepare registers for CALC
    ADD R0, R4, #0          ; R0 = first number
    ADD R2, R5, #0          ; R2 = operation

    JSR CALC                 ; result returned in R0

    ; Print "Result: "
    ADD R4, R0, #0          ; temporarily save result
    LEA R0, RESULTMSG
    PUTS
    ADD R0, R4, #0          ; restore result

    JSR DISPLAY              ; display result

    BRnzp MAIN               ; repeat forever


; =====================================================
; GETNUM
; Reads a positive number from 0 to 99
; Returns number in R0
; =====================================================

GETNUM
    ST R7, GETNUM_R7

    GETC                     ; get first digit
    OUT                      ; echo first digit

    LD R1, NEG48
    ADD R2, R0, R1          ; convert first digit to number

    GETC                     ; get next character

    ; Check if next character is ENTER
    LD R3, NEG10
    ADD R3, R0, R3
    BRz GETNUM_ONE_DIGIT

    ; If not ENTER, it is the second digit
    OUT                      ; echo second digit
    ADD R0, R0, R1          ; convert second digit to number
    ADD R3, R0, #0          ; save second digit in R3

    ; Multiply first digit by 10
    ADD R0, R2, R2          ; x2
    ADD R0, R0, R0          ; x4
    ADD R0, R0, R2          ; x5
    ADD R0, R0, R0          ; x10

    ADD R2, R0, R3          ; first*10 + second

    ; Consume ENTER after second digit
    GETC
    OUT

    ADD R0, R2, #0          ; answer into R0
    LD R7, GETNUM_R7
    RET

GETNUM_ONE_DIGIT
    ; Echo the ENTER
    OUT
    ADD R0, R2, #0          ; first digit is the number
    LD R7, GETNUM_R7
    RET


; =====================================================
; GETOP
; Reads +, -, or *
; Returns operation character in R0
; =====================================================

GETOP
    ST R7, GETOP_R7

    GETC                     ; get operation
    OUT                      ; echo operation

    ADD R2, R0, #0          ; save operation

    GETC                     ; consume ENTER
    OUT

    ADD R0, R2, #0          ; return operation in R0

    LD R7, GETOP_R7
    RET


; =====================================================
; CALC
;
; Input:
; R0 = first number
; R1 = second number
; R2 = operation
;
; Output:
; R0 = result
; =====================================================

CALC
    ; Check for +
    LD R3, NEG_PLUS
    ADD R3, R2, R3
    BRz DO_ADD

    ; Check for -
    LD R3, NEG_MINUS
    ADD R3, R2, R3
    BRz DO_SUB

    ; Otherwise operation is *
    BRnzp DO_MULT


DO_ADD
    ADD R0, R0, R1
    RET


DO_SUB
    NOT R1, R1
    ADD R1, R1, #1
    ADD R0, R0, R1
    RET


DO_MULT
    ADD R3, R0, #0          ; save first number
    AND R0, R0, #0          ; result = 0
    ADD R1, R1, #0
    BRz MULT_DONE

MULT_LOOP
    ADD R0, R0, R3          ; add first number
    ADD R1, R1, #-1         ; decrease counter
    BRp MULT_LOOP

MULT_DONE
    RET


; =====================================================
; DISPLAY
; Displays a positive or negative number
; up to 4 digits
;
; Input:
; R0 = number to display
; =====================================================

DISPLAY
    ST R7, DISPLAY_R7

    ; Check if number is negative
    ADD R0, R0, #0
    BRzp DISPLAY_POSITIVE

    ; Print minus sign
    ADD R4, R0, #0
    LD R0, MINUS_CHAR
    OUT
    ADD R0, R4, #0

    ; Make number positive
    NOT R0, R0
    ADD R0, R0, #1


DISPLAY_POSITIVE
    ADD R3, R0, #0          ; R3 = remaining number
    AND R4, R4, #0          ; R4 = printed digit flag


; -------------------------
; Thousands digit
; -------------------------

    AND R2, R2, #0

THOUSAND_LOOP
    LD R1, NEG1000
    ADD R0, R3, R1
    BRn THOUSAND_DONE

    ADD R3, R0, #0
    ADD R2, R2, #1
    BRnzp THOUSAND_LOOP

THOUSAND_DONE
    ADD R2, R2, #0
    BRz HUNDREDS_START

    LD R1, ASCII48
    ADD R0, R2, R1
    OUT

    ADD R4, R4, #1


; -------------------------
; Hundreds digit
; -------------------------

HUNDREDS_START
    AND R2, R2, #0

HUNDRED_LOOP
    LD R1, NEG100
    ADD R0, R3, R1
    BRn HUNDRED_DONE

    ADD R3, R0, #0
    ADD R2, R2, #1
    BRnzp HUNDRED_LOOP

HUNDRED_DONE
    ADD R4, R4, #0
    BRp PRINT_HUNDRED

    ADD R2, R2, #0
    BRz TENS_START

PRINT_HUNDRED
    LD R1, ASCII48
    ADD R0, R2, R1
    OUT

    ADD R4, R4, #1


; -------------------------
; Tens digit
; -------------------------

TENS_START
    AND R2, R2, #0

TEN_LOOP
    LD R1, NEG10
    ADD R0, R3, R1
    BRn TEN_DONE

    ADD R3, R0, #0
    ADD R2, R2, #1
    BRnzp TEN_LOOP

TEN_DONE
    ADD R4, R4, #0
    BRp PRINT_TEN

    ADD R2, R2, #0
    BRz ONES_START

PRINT_TEN
    LD R1, ASCII48
    ADD R0, R2, R1
    OUT


; -------------------------
; Ones digit
; -------------------------

ONES_START
    LD R1, ASCII48
    ADD R0, R3, R1
    OUT

    ; Print newline
    LD R0, NEWLINE
    OUT

    LD R7, DISPLAY_R7
    RET


; =====================================================
; DATA
; =====================================================

PROMPT1
    .STRINGZ "Enter first number (0 - 99): "

PROMPTOP
    .STRINGZ "Enter an operation (+, -, *): "

PROMPT2
    .STRINGZ "Enter second number (0 - 99): "

RESULTMSG
    .STRINGZ "Result: "


; ASCII / math constants

NEG48
    .FILL #-48

ASCII48
    .FILL #48

NEG10
    .FILL #-10

NEG100
    .FILL #-100

NEG1000
    .FILL #-1000

NEG_PLUS
    .FILL #-43

NEG_MINUS
    .FILL #-45

MINUS_CHAR
    .FILL #45

NEWLINE
    .FILL #10


; Save locations for R7

GETNUM_R7
    .BLKW 1

GETOP_R7
    .BLKW 1

DISPLAY_R7
    .BLKW 1


.END