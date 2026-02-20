;START OF PROGRAM
        org $8000             ;$8000 is 32768 in Decimal

        call Init

        ld a, 2
        call OUTCHAN

        ld hl, high_score
        ld bc, high_score_end - high_score
        call Print_Score
        ret

Init
        ld hl, ATTR_P
        ld (hl), blu * 8
        call CLS
        ld a, blk
        call BORDER
        ret

; Prints a score, where each decimal digit is stored
; as one byte.
;   hl = address of first byte of score
;   bc = number of bytes to display
Print_Score
; Position and set the ink
        push hl
        push bc
        ld de, high_score_attributes
        ld bc, 5
        call PRINTSTR
        pop bc
        pop hl

Print_Score_Loop
        ld a, (hl)
        push bc
        push hl
        call Print_Number
        pop hl
        pop bc
        inc hl
        dec bc
        cp c
        jr NZ, Print_Score_Loop
        ret

; Prints one decimal digit
;   a = the decimal value (0-9)
Print_Number
        ld hl, numbers + 9
        ld bc, 10
        cpdr
        ld hl, chars
        add hl, bc
        push hl
        pop de
        ld bc, 1
        call PRINTSTR
        ret

high_score defb 0,0,0,7,6,8,9,2,3
high_score_end equ $

high_score_attributes defb _at, 10, 10, ink, wht

numbers defb 0,1,2,3,4,5,6,7,8,9
chars defb "0123456789"

;********** SYSTEM VARIABLES *********
ATTR_P EQU 23693                    ;ATTR-P Sysvar (Attributes)

;************ ROM ROUTINES ************
CLS equ 3503
BORDER EQU 8859 
PRINTSTR EQU 8252                   ;ROM routine to print string.
OUTCHAN EQU 5633                    ;ROM routine to activate output channel.

;******** CONTROL CODES ************
ink equ 16                          ;INK control code.
paper equ 17                        ;PAPER control code.
flash equ 18                        ;FLASH attribute.
bright equ 19                       ;BRIGHT attribute.
cr equ 13                           ;Carriage return.
_at equ 22                          ;AT control code.
tab equ 23                          ;TAB
blk equ 0                           ;Blk.
blu equ 1                           ;Blue.
red equ 2                           ;Red.
mag equ 3                           ;Magenta.
grn equ 4                           ;Green.
cyn equ 5                           ;Cyan.
yel equ 6                           ;Yellow.
wht equ 7                           ;White.

;******** End ***********
END $8000