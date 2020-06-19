        * = $4000 "Game"

        .var star_dx_lo = $40
        .var star_dx_hi = $41
        .var star_dy_lo = $42
        .var star_dy_hi = $43

        .var star_count = 4

        .var star_first_char = 240
        .var star_first_char_def = $3800+(star_first_char * 8)

        .var _Vmem = $6000
        .var _Y = $2
        .var _X = $3
        .var wOffs = $fd

silence_sid:
        // silence SID
        lda #$00
        sta $d404
        sta $d40b
        sta $d412
        rts

clear_bitmap:
        lda #$00
        ldx #$00
!loop:
        sta $6000,x
        sta $6100,x
        sta $6200,x
        sta $6300,x
        sta $6400,x
        sta $6500,x
        sta $6600,x
        sta $6700,x
        sta $6800,x
        sta $6900,x
        sta $6a00,x
        sta $6b00,x
        sta $6c00,x
        sta $6d00,x
        sta $6e00,x
        sta $6f00,x
        sta $7000,x
        sta $7100,x
        sta $7200,x
        sta $7300,x
        sta $7400,x
        sta $7500,x
        sta $7600,x
        sta $7700,x
        sta $7800,x
        sta $7900,x
        sta $7a00,x
        sta $7b00,x
        sta $7c00,x
        sta $7d00,x
        sta $7e00,x
        sta $7f00,x
        inx
        cpx #$00
        bne !loop-

        rts

reset_bitmap_colours:
        // set all colours to white fore, black back
        lda #$10
        ldx #$00

!loop:
        // colour ram
        sta $4400, x
        sta $44fa, x
        sta $45f4, x
        sta $46ee, x

        inx
        cpx #$fa
        bne !loop-
        rts

start_game:
        jsr silence_sid

        lda #%00000000
        sta interrupt_control

        // bitmap mode
        lda #%00111011
        sta screen_control

        lda #%00001000
        sta screen_control_2

        // pixels at $6000
        // colours at $4400
        lda #%00011000
        sta vic_memory_setup

        lda #%00000010
        sta $dd00

        jsr clear_bitmap
        jsr reset_bitmap_colours

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



/************************************************
;
;       Plot
;
;       input: _X* (word 0-319**)
;              _Y* (byte 0-200**)
;       *_X, _Y are variables in memory, not the registers
;       **no boundary check
;
; offset = BaseAddr + 320*int(Y/8)+(Y and 7) + 8*int(X/8)
; pixel  = 2^(7-(X and 7))
;
************************************************/
plot:
        ldy #0          // 2     // comput. dY
        sty wOffs       // 3     // reset lobyte
        lda _Y          // 3
        lsr             // 2
        lsr             // 2
        lsr             // 2     // int(Y/8)
        sta wOffs+1     // 3     // 256*int(Y/8) hibyte (lobyte=0)
        lsr             // 2
        ror wOffs       // 5
        lsr             // 2     // 64*int(Y/8)  hibyte
        ror wOffs       // 5     // 64*int(Y/8)  lobyte  (= 320*int(Y/8) lobyte)
        adc wOffs+1     // 3     // 256*int(Y/8) + 64*int(Y/8)  hibyte
        sta wOffs+1     // 3     // =320*int(Y/8) hibyte
        lda _Y          // 3     // add (Y and 7)
        and #7          // 2
        ora wOffs       // 3     // lobyte [xx000xxx]
        sta wOffs       // 3  48

        lda _X          // 3     // dX + dY + BaseAddr
        and #248        // 2
        adc wOffs       // 3
        sta wOffs       // 3
        lda wOffs+1     // 3
        adc _X+1        // 3
        adc #>_Vmem     // 2
        sta wOffs+1     // 3  22

        lda _X          // 3     // set pixel-bit
        and #7          // 2
        tax             // 2
        lda (wOffs),y   // 5     // draws the pixel
        ora ortab,x     // 4
        sta (wOffs),y   // 6  22

        rts

clear_byte:
        ldy #0          // 2     // comput. dY
        sty wOffs       // 3     // reset lobyte
        lda _Y          // 3
        lsr             // 2
        lsr             // 2
        lsr             // 2     // int(Y/8)
        sta wOffs+1     // 3     // 256*int(Y/8) hibyte (lobyte=0)
        lsr             // 2
        ror wOffs       // 5
        lsr             // 2     // 64*int(Y/8)  hibyte
        ror wOffs       // 5     // 64*int(Y/8)  lobyte  (= 320*int(Y/8) lobyte)
        adc wOffs+1     // 3     // 256*int(Y/8) + 64*int(Y/8)  hibyte
        sta wOffs+1     // 3     // =320*int(Y/8) hibyte
        lda _Y          // 3     // add (Y and 7)
        and #7          // 2
        ora wOffs       // 3     // lobyte [xx000xxx]
        sta wOffs       // 3  48

        lda _X          // 3     // dX + dY + BaseAddr
        and #248        // 2
        adc wOffs       // 3
        sta wOffs       // 3
        lda wOffs+1     // 3
        adc _X+1        // 3
        adc #>_Vmem     // 2
        sta wOffs+1     // 3  22

        lda #0
        sta (wOffs),y   // 6  22

        rts

ortab:
        .byte 128, 64, 32, 16, 8, 4, 2, 1

plot_pixel:
        .var xpos = 128
        .var ypos = 200

        lda #ypos

        // ypos / 8
        lsr
        lsr
        lsr
        tax

        // yremain
        and #7
        sta $44

        // lookup line start
        lda y_char_start_lo,y
        sta $40
        lda y_char_start_hi,y
        sta $41

        // xpos / 8
        lda #xpos
        lsr
        lsr
        lsr
        tax

        // xremain
        and #7
        sta $45

        // lookup byte offset
        lda x_char_start_lo,y
        sta $42
        lda x_char_start_hi,y
        sta $43







y_char_start_lo:
        .byte <$6000+(0*40*8)
        .byte <$6000+(1*40*8)
        .byte <$6000+(2*40*8)
        .byte <$6000+(3*40*8)
        .byte <$6000+(4*40*8)
        .byte <$6000+(5*40*8)
        .byte <$6000+(6*40*8)
        .byte <$6000+(7*40*8)
        .byte <$6000+(8*40*8)
        .byte <$6000+(9*40*8)
        .byte <$6000+(10*40*8)
        .byte <$6000+(11*40*8)
        .byte <$6000+(12*40*8)
        .byte <$6000+(13*40*8)
        .byte <$6000+(14*40*8)
        .byte <$6000+(15*40*8)
        .byte <$6000+(16*40*8)
        .byte <$6000+(17*40*8)
        .byte <$6000+(18*40*8)
        .byte <$6000+(19*40*8)
        .byte <$6000+(20*40*8)
        .byte <$6000+(21*40*8)
        .byte <$6000+(22*40*8)
        .byte <$6000+(23*40*8)
        .byte <$6000+(24*40*8)
        .byte <$6000+(25*40*8)

y_char_start_hi:
        .byte >$6000+(0*40*8)
        .byte >$6000+(1*40*8)
        .byte >$6000+(2*40*8)
        .byte >$6000+(3*40*8)
        .byte >$6000+(4*40*8)
        .byte >$6000+(5*40*8)
        .byte >$6000+(6*40*8)
        .byte >$6000+(7*40*8)
        .byte >$6000+(8*40*8)
        .byte >$6000+(9*40*8)
        .byte >$6000+(10*40*8)
        .byte >$6000+(11*40*8)
        .byte >$6000+(12*40*8)
        .byte >$6000+(13*40*8)
        .byte >$6000+(14*40*8)
        .byte >$6000+(15*40*8)
        .byte >$6000+(16*40*8)
        .byte >$6000+(17*40*8)
        .byte >$6000+(18*40*8)
        .byte >$6000+(19*40*8)
        .byte >$6000+(20*40*8)
        .byte >$6000+(21*40*8)
        .byte >$6000+(22*40*8)
        .byte >$6000+(23*40*8)
        .byte >$6000+(24*40*8)
        .byte >$6000+(25*40*8)

x_char_start_lo:
        .byte <0*8
        .byte <1*8
        .byte <2*8
        .byte <3*8
        .byte <4*8
        .byte <5*8
        .byte <6*8
        .byte <7*8
        .byte <8*8
        .byte <9*8
        .byte <10*8
        .byte <11*8
        .byte <12*8
        .byte <13*8
        .byte <14*8
        .byte <15*8
        .byte <16*8
        .byte <17*8
        .byte <18*8
        .byte <19*8
        .byte <20*8
        .byte <21*8
        .byte <22*8
        .byte <23*8
        .byte <24*8
        .byte <25*8
        .byte <26*8
        .byte <27*8
        .byte <28*8
        .byte <29*8
        .byte <30*8
        .byte <31*8
        // now over 256
        .byte <32*8
        .byte <33*8
        .byte <34*8
        .byte <35*8
        .byte <36*8
        .byte <37*8
        .byte <38*8
        .byte <39*8

x_char_start_hi:
        .byte >0*8
        .byte >1*8
        .byte >2*8
        .byte >3*8
        .byte >4*8
        .byte >5*8
        .byte >6*8
        .byte >7*8
        .byte >8*8
        .byte >9*8
        .byte >10*8
        .byte >11*8
        .byte >12*8
        .byte >13*8
        .byte >14*8
        .byte >15*8
        .byte >16*8
        .byte >17*8
        .byte >18*8
        .byte >19*8
        .byte >20*8
        .byte >21*8
        .byte >22*8
        .byte >23*8
        .byte >24*8
        .byte >25*8
        .byte >26*8
        .byte >27*8
        .byte >28*8
        .byte >29*8
        .byte >30*8
        .byte >31*8
        // now over 256
        .byte >32*8
        .byte >33*8
        .byte >34*8
        .byte >35*8
        .byte >36*8
        .byte >37*8
        .byte >38*8
        .byte >39*8






        jsr clear_screen

        // all white
        lda #$01
        jsr fill_screen_colour


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

        lda #<100
        sta _X
        lda #>100
        sta _X+1
        lda #100
        sta _Y

        jsr plot

        jmp !done+

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
