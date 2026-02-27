;START OF PROGRAM
ORG $8000             ;$8000 is 32768 in Decimal

        call Init

        ld a, 2
        call OUTCHAN

        call Init_Interrupt
        ; ret

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
        LD a, d
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

; Prints a score, where each decimal digit is stored
; as one byte.
;   hl = address of first byte of score
;   c = number of bytes to display
;   d = y pos
;   e = x pos
Print_Score
        ; Position and set the ink
        push hl
        push bc
        ld ix, high_score_attributes
        ld (ix + 1), d
        ld (ix + 2), e
        ld de, high_score_attributes
        ld bc, 5
        call PRINTSTR
        pop bc
        pop hl

        _print_score_loop
        ld a, (hl)
        push bc
        push hl
        call Print_Number
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
Print_Number
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
_print_number_numbers defb 0,1,2,3,4,5,6,7,8,9
_print_number_chars defb "0123456789"

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
        ld hl, _interrupt_container
        ld a, (hl)
        cp 0
        jr nz, _interrupt_end

        ; reset the interrupt counter
        ld hl, _interrupt_container
        ld a, 26
        ld (hl), a

        ; print the current high score
        ld hl, high_score
        ld bc, high_score_end - high_score
        ld de, 0x0B0A ; row 11, col 10
        call Print_Score

        ; increment the high score
        ld hl, high_score_end - 1
        ld a, (hl)
        cp 9
        jr z, _interrupt_zero_score
        inc a
        ld (hl), a
        jr _interrupt_end
_interrupt_zero_score
        ld a, 0
        ld (hl), a

_interrupt_end
        ; decrement the interrupt counter
        ld hl, _interrupt_container
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
_interrupt_container defb 25

;******** INTERRUPT SETUP *********************

;******** High Score stuff ********************
high_score_attributes defb _at, 10, 10, ink, wht
high_score defb 0,0,0,7,6,8,9,2,3
high_score_end equ $

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
