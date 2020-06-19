        * = $4000 "Game"

        .var star_dx_lo = $40
        .var star_dx_hi = $41
        .var star_dy_lo = $42
        .var star_dy_hi = $43

        .var star_count = 4

        .var star_first_char = 240
        .var star_first_char_def = $3800+(star_first_char * 8)

start_game:
        lda #%00000000
        sta interrupt_control

        jsr clear_screen

        // all white
        lda #$01
        jsr fill_screen_colour

        // silence SID
        lda #$00
        sta $d404
        sta $d40b
        sta $d412

        // clear char
        ldx #$00
        lda #$00
!loop:
        sta star_first_char_def,x
        inx
        cpx $08
        bmi !loop-

        // plot star char def
        lda #$01
        sta star_first_char_def

        // draw star
        lda #<$0400+40*12+20
        sta $40
        lda #>$0400+40*12+20
        sta $41

        lda #star_first_char
        sta $0400+40*12+20

        // star interrupt
        sei
        lda #%00000001
        sta interrupt_control
        lda #<star_irq
        sta irq_low
        lda #>star_irq
        sta irq_high
        lda #$80
        sta raster_line
        cli

        jmp *

star_irq:
        SetBorderColor(13)

        // star num
        ldy #$00

        // erase star
        lda #$00
        sta star_first_char_def

        // erase star char
        sta ($40),y

        // move star

        // plot star

        jmp !done+


        clc
        rol star_first_char_def
        bcc !done+

        // left one char
        ldy #$00
        lda #$00
        sta ($40),y
        dec $40
        lda #star_first_char
        sta ($40),y

        lda #$01
        sta star_first_char_def

!done:
        SetBorderColor(0)

        inc interrupt_status

        pla
        tay
        pla
        tax
        pla

        rti

// TODO: dont overwrite title screen chars
clear_chars:


star_chars:
        .byte 1, 2, 3, 4

star_xs:
        .word $0000
        .word $0000
        .word $0000
        .word $0000

star_ys:
        .word $0000
        .word $0000
        .word $0000
        .word $0000
