;START OF PROGRAM
ORG $8000             ;$8000 is 32768 in Decimal

        call Init

        ld a, 2
        call OUTCHAN

        call Init_Interrupt

main_loop
        xor a
        cp 0
        jr z, main_loop
        ret

Init
; Setup screen
        ld hl, ATTR_P
        ld (hl), blu * 8
        call CLS
        ld a, blk
        call BORDER
        ret

Init_Interrupt
        _init_interrupt_table equ 0xFE00
        _init_interrupt_jmp equ 0xFDFD

        di
        ld de, _init_interrupt_table
        ld a, d
        ; set the interrupt pointer to 0xFE
        ld i, a

        ; when the interrupt fires, the ROM loads a byte from the data
        ; bus, which could be any value, and uses that to index to the address
        ; of the interrupt code to execute.
        ; Therefpre, set all 257 bytes from 0xFE00 to 0xFF00, to the value 0xFD
        ; this will cause the code at 0xFDFD to be executed by the interrupt,
        ; no matter what low byte is read from the data bus
        ld hl, _init_interrupt_jmp
        ld a, l
        _init_interrupt_fill
                ld (de), a
                inc e
                jr nz, _init_interrupt_fill
        inc d
        ld (de), a

        ; place a 3 byte instruction at 0xFDFD to JP to our actual
        ; interrupt handling code
        ld (hl), 0xc3; JP
        ld bc, Interrupt
        inc l
        ld (hl), c; Low byte of interrupt handler code address
        inc l
        ld (hl), b; High byte..

        im 2
        ei

        ret

; **********************************************************************
; Adds a single decimal digit per byte (0-9) number to the current score.
;  hl = address of first digit of number to add
;  bc = number of bytes in the number
; **********************************************************************
Add_to_Score
; TODO - implement
; get the digit at (hl + c-1)
; add that to (high_score + high_score_len - 1)
; cp that to 10
;       if carry(overflow) set
;           set that digit to value minus 10
;           move left one digit in the high score
;           add 1 to that digit
;           go to if carry set
        ; load the last digit of the current score into d
        ld ix, high_score_end
        push hl
        pop iy
        add iy, bc
loop_1
        dec ix ; points to current digit of current score
        dec iy ; points to current digit of score to add

loop_2
        ld a, (ix)
        ld d, (iy)
        add a, d

        cp 10
        jp c, _store_current_digit

        ; greater than 10
        ;  subtract 10
        sub 10
        ;  store current digit
        ;  add 1 to previous digit 

        ; store that back
_store_current_digit
        ld (ix), a

        ret
; TODO - handle overflow of the entire high score
; *********************************************************************

; Prints a score, where each decimal digit is stored
; as one byte.
;   hl = address of first byte of score
;   c = number of bytes to display
Print_Score
        ; Position and set the ink
        push hl
        push bc
        ld de, high_score_attributes
        ld bc, 5
        call PRINTSTR
        pop bc
        pop hl

        _print_score_loop
        ld a, (hl)
        push bc
        push hl
        call Print_Digit
        pop hl
        pop bc
        inc hl
        dec c
        xor a
        cp c
        jr NZ, _print_score_loop

        ret

; Prints one decimal digit
;   a = the decimal value (0-9)
        _print_number_numbers defb 0,1,2,3,4,5,6,7,8,9
        _print_number_chars defb "0123456789"
Print_Digit
        ld hl, _print_number_numbers + 9
        ld bc, 10
        cpdr
        ld hl, _print_number_chars
        add hl, bc
        push hl
        pop de
        ld bc, 1
        call PRINTSTR
        ret

; *****************************
; INTERRUPT HANDLING CODE
; *****************************
        _interrupt_counter defb 50
Interrupt
        di

        ; store registers
        push af
        push bc
        push de
        push hl
        push ix
        push iy

        ; only perform this processing every 25 cycles (roughly every half second)
        ld hl, _interrupt_counter
        ld a, (hl)
        cp 0
        jr nz, _interrupt_end

        ; reset the interrupt counter
        ld hl, _interrupt_counter
        ld a, 50
        ld (hl), a

        ; add some points to the high score
        ld hl, points_to_add
        ld bc, points_to_add_end - points_to_add
        call Add_to_Score

        ; print the current high score
        ld hl, high_score
        ld bc, high_score_end - high_score
        call Print_Score

        ; increment the high score
        ; ld hl, high_score_end - 1
        ; ld a, (hl)
        ; cp 9
        ; jr z, _interrupt_zero_score
        ; inc a
        ; ld (hl), a
        ; jr _interrupt_end

        _interrupt_zero_score
                ld a, 0
                ld (hl), a

        _interrupt_end
                ; decrement the interrupt counter
                ld hl, _interrupt_counter
                ld a, (hl)
                dec a
                ld (hl), a

                ; restore registers
                pop iy
                pop ix
                pop hl
                pop de
                pop bc
                pop af

        ei
        ret

;******** INTERRUPT SETUP *********************

;******** High Score stuff ********************
high_score_attributes defb _at, 10, 10, ink, wht
high_score defb 0,0,0,7,6,8,9,0,1
high_score_end equ $

points_to_add defb 3,6,3
points_to_add_end equ $

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
