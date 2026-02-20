;START OF PROGRAM
org $8000             ;$8000 is 32768 in Decimal

;MAIN LOOP

call INIT

ld a,2
call OUTCHAN

ld de, str1
ld bc, ENDstr1-str1            
call PRINTSTR

ret

;END OF MAIN LOOP

;SUBROUTINES

INIT
;Lets set the paper to Blue
;Then clear the screen
ld  hl, ATTR_P
ld (hl),blu*8
call CLS

;Set the border
ld a, blk
call BORDER

ret                    ;Return from INIT


;************ Strings *************

str1
    defb _at,10,4,ink,yel
    defb "This is a",cr
    defb ink,grn,"string of text"
ENDstr1    equ $

;************ ROM ROUTINES ************

PRINTSTR EQU 8252                   ;ROM routine to print string.
OUTCHAN EQU 5633                    ;ROM routine to activate output channel.
CLS EQU 3503                        ;ROM routine to clear entire screen using attributes in ATTR-P (23693)
BORDER EQU 8859                     ;ROM routine to set border color.

;********** SYSTEM VARIABLES *********

ATTR_P EQU 23693                    ;ATTR-P Sysvar (Attributes)

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