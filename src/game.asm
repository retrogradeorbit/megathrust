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

        .var    star_x_sub = $7f
        .var    star_x_lo = $80
        .var    star_x_hi = $81

        .var    star_y_sub = $82
        .var    star_y = $83

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

        // star starting pos
        lda #<200
        sta star_x_lo
        lda #>200
        sta star_x_hi
        lda #100
        sta star_y

        lda #0
        sta star_x_sub
        sta star_y_sub

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

star_irq:
        SetBorderColor(13)

        // x
        lda star_x_lo
        sta _X
        lda star_x_hi
        sta _X+1

        // y
        lda star_y
        sta _Y

        jsr clear_byte

        // move
        clc
        lda star_x_sub
        adc #10
        sta star_x_sub
        lda star_x_lo
        adc #0
        sta star_x_lo
        lda star_x_hi
        adc #0
        sta star_x_hi

        sec
        lda star_y_sub
        sbc #50
        sta star_y_sub
        lda star_y
        sbc #0
        sta star_y

        // x
        lda star_x_lo
        sta _X
        lda star_x_hi
        sta _X+1

        // y
        lda star_y
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
        SetBorderColor(11)

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
