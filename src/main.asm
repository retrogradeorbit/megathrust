        .var irq_low = $0314
        .var irq_high = $0315
        .var irq_control = $dc0d
        .var nmi_control = $dd0d
        .var interrupt_control = $d01a
        .var screen_control = $d011
        .var raster_line = $d012
        .var interrupt_status = $d019
        .var vic_memory_setup = $d018

        .var border_colour = $d020
        .var screen_colour = $d021

        // kernel
        .var normal_interrupt = $ea31
        .var normal_interrupt_no_keyboard_scan = $ea81

        * = $0801 "Main Program"
start:
        //lda #$37
        //sta $01

        SetScreenAndBorderColor($00)

        // init indecies
        lda #$00
        sta $03

        lda #$00
        jsr music
        sei

        lda #<irq1
        sta irq_low
        lda #>irq1
        sta irq_high

        // turn of CIA1 and CIA2 interrupts
        lda #%01111111
        sta irq_control
        sta nmi_control

        // ack CIA1 and CIA2
        lda irq_control
        lda nmi_control

        lda #%00000001
        sta interrupt_control

        lda #%00011011
        sta screen_control

        lda #%00011110
        sta vic_memory_setup

        // jsr clear_screen
        jsr fill_screen
        jsr title

        lda #$00
        sta raster_line

        asl interrupt_status
        cli

        jmp *

irq1:
        SetBorderColor(0)
        jsr music+3
        SetBorderColor(0)
        jsr copy_frame_lut
        SetBorderColor(0)
        jsr cycle_colours
        SetBorderColor(0)


        // next interrupt
        lda #<irq2
        sta irq_low
        lda #>irq2
        sta irq_high

        lda #91-24
        sta raster_line

        // ack interrupt
        inc interrupt_status

        pla
        tay
        pla
        tax
        pla

        rti

irq2:
        lda #93-24
        sta raster_line
        lda #<irq3
        sta irq_low
        lda #>irq3
        sta irq_high
        // ack interrupt
        inc interrupt_status
        cli
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop

        pla
        tay
        pla
        tax
        pla

        rti

irq3:
        nop            // 2 cycles each
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop

        bit $00        // 3 cycles
        lda raster_line
        cmp #93-24
        beq next_instr

        // now three cycles after the start of rasterline

next_instr:
        // now we are cycle exact
        lda #$00
        ldx #$00
        ldy #$00
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        jsr colour_bar_loop

        jsr colour_bar
        jsr colour_bar

        // thrust bar
        lda #$00
        ldx #$00
        ldy #$00
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        bit $00

        jsr colour_bar_loop

        lda #$00
        sta screen_colour

        inc interrupt_status

        lda #<irq1
        sta irq_low
        lda #>irq1
        sta irq_high

        lda #$00
        sta raster_line

        pla
        tay
        pla
        tax
        pla

        rti

colour_bar:
        nop
        nop
        nop
        nop
        nop

        inx
        lda colourbar_lut,x
        sta screen_colour
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        lda #$00
        sta screen_colour

        nop
        nop
        bit $00
        rts

colour_bar_loop:
        jsr colour_bar
        jsr colour_bar
        jsr colour_bar
        jsr colour_bar

        // badline
        inx
        lda colourbar_lut,x
        sta screen_colour
        nop
        nop
        nop
        nop
        nop

        jsr colour_bar
        jsr colour_bar
        jsr colour_bar
        jsr colour_bar
        jsr colour_bar
        jsr colour_bar
        jsr colour_bar

        //badline
        inx
        lda colourbar_lut,x
        sta screen_colour
        nop
        nop
        nop
        nop
        nop

        jsr colour_bar
        jsr colour_bar
        jsr colour_bar
        jsr colour_bar
        jsr colour_bar
        jsr colour_bar
        jsr colour_bar

        // badline
        inx
        lda colourbar_lut,x
        sta screen_colour
        nop
        nop
        nop
        nop
        nop

        jsr colour_bar
        jsr colour_bar
        jsr colour_bar
        jsr colour_bar
        jsr colour_bar
        jsr colour_bar
        jsr colour_bar

        // badline
        inx
        lda colourbar_lut,x
        sta screen_colour
        nop
        nop
        nop
        nop
        nop

        jsr colour_bar
        jsr colour_bar
        jsr colour_bar
        jsr colour_bar
        jsr colour_bar
        jsr colour_bar
        jsr colour_bar

        // badline
        inx
        lda colourbar_lut,x
        sta screen_colour
        nop
        nop
        nop
        nop
        nop

        jsr colour_bar
        jsr colour_bar
        jsr colour_bar
        jsr colour_bar
        jsr colour_bar
        jsr colour_bar
        jsr colour_bar

        // badline
        inx
        lda colourbar_lut,x
        sta screen_colour
        nop
        nop
        nop
        nop
        nop

        rts

clear_screen:
        lda #$00
        ldx #$00

!loop:
        // chars
        sta $0400, x
        sta $04fa, x
        sta $05f4, x
        sta $06ee, x

        // colour ram
        sta $d800, x
        sta $d8fa, x
        sta $d9f4, x
        sta $daee, x

        inx
        cpx #$fa
        bne !loop-

        rts

fill_screen:
        ldx #$00

!loop:
        // chars
        lda #$01
        sta $0400, x
        sta $04fa, x
        sta $05f4, x
        sta $06ee, x

        // colour ram
        lda #$00
        sta $d800, x
        sta $d8fa, x
        sta $d9f4, x
        sta $daee, x

        inx
        cpx #$fa
        bne !loop-

        rts

        // ldx start poke val
        // ldy start offset
printer:
        ldy #$00
!loop:
        txa
        sta $0500,y
        inx
        iny

        cpy #$9
        bne !loop-

        rts

        .var title_xpos = 15
        .var title_ypos = 6

title:
        // MEGA
        // width
        lda mega_charmap
        sta $10

        // height
        lda mega_charmap+1
        sta $11

        // source block location
        lda #<mega_charmap
        clc
        adc #$02 // first 2 bytes are width and height
        sta $12

        lda #>mega_charmap
        adc #$00 // add carry in case 256 byte boundary crossing
        sta $13

        // screen destination location
        lda #$04
        sta $15
        lda #$84
        sta $14

        jsr draw_char_block

        // THRUST
        // width
        lda thrust_charmap
        sta $10

        // height
        lda thrust_charmap+1
        sta $11

        // source block location
        lda #<thrust_charmap
        clc
        adc #$02 // first 2 bytes are width and height
        sta $12

        lda #>thrust_charmap
        adc #$00 // add carry in case 256 byte boundary crossing
        sta $13

        // screen destination location
        lda #$05
        sta $15
        lda #$4a
        sta $14

        jsr draw_char_block


        // PRESS FIRE
        lda #<text_press_fire
        sta $16
        lda #>text_press_fire
        sta $17

        // x
        lda #$09
        sta $18

        // y
        lda #18
        sta $19

        // colour
        lda #$01
        sta $20
        jsr write_text

        rts

cycle_colours:
        // x
        lda #$09
        sta $18

        // y
        lda #18
        sta $19

        // length
        lda #25
        sta $20

        // colour
        ldx $03
        inx
        stx $03
        cpx text_colour_lut_length
        bne !write+

        lda #$00
        sta $03

!write:
        lda text_colour_lut,x
        sta $21
        jsr write_text_colours

        rts

copy_lut_1:
        ldx #48
cl1_loop:
        lda colourbar_lut_1,x
        sta colourbar_lut,x
        dex
        cpx #$ff
        bpl cl1_loop
        rts

copy_lut_2:
        ldx #48
cl2_loop:
        lda colourbar_lut_2,x
        sta colourbar_lut,x
        dex
        cpx #$ff
        bpl cl2_loop
        rts

frame_num:
        .byte 0

copy_frame_lut:
        inc frame_num
        lda frame_num
        and #$01
        cmp #$01
        bne cfl_jmp
        jsr copy_lut_1
        rts
cfl_jmp:
        jsr copy_lut_2
        rts

draw_char_block:
        ldx #$0
!loop_line:
        ldy #$0
!read:
        lda ($12),y
        sta ($14),y
        iny
        cpy $10
        bmi !read-

        // add one row to all the locs
        // add width to lda
        lda $12
        clc
        adc $10
        sta $12
        lda $13
        adc #$00
        sta $13

        // add 40 to sta
        lda $14
        clc
        adc #40
        sta $14
        lda $15
        adc #$00
        sta $15

        inx
        cpx $11
        bmi !loop_line-

        rts

write_text:
        // src $16/$17. x: $18. y $19. colour $20
        // calc destinations $21-$24

        ldx $19
        lda screen_rows_lo,x
        sta $21
        lda screen_rows_hi,x
        sta $22
        lda colour_rows_lo,x
        sta $23
        lda colour_rows_hi,x
        sta $24

        // xpos
        lda $21
        clc
        adc $18
        sta $21
        lda $22
        adc #0
        sta $22

        lda $23
        clc
        adc $18
        sta $23
        lda $24
        adc #0
        sta $24

        ldy #$00

!write_write:
        lda ($16),y
        cmp #$ff
        bne !write_char+
        rts

!write_char:
        sta ($21),y

        // colour
        lda $20
        sta ($23),y

        iny
        jmp !write_write-

        /*

        */
write_text_colours:
        // x: $18. y $19. length $20. colour $21.
        // calc destinations $22/$23

        ldx $19
        lda colour_rows_lo,x
        sta $22
        lda colour_rows_hi,x
        sta $23

        // xpos
        lda $22
        clc
        adc $18
        sta $22
        lda $23
        adc #0
        sta $23

        ldy #$00

!write_write:
        cpy $20
        bne !write_char+
        rts

!write_char:
        // colour
        lda $21
        sta ($22),y

        iny
        jmp !write_write-


        * = $2000 "colour LUT"
colourbar_lut:
        .byte 6, 9, 11, 2, 4, 8, 12, 14, 10, 5, 15, 3, 7, 13, 1
        .byte 1, 13, 7, 3, 15, 5, 10, 14, 12, 8, 4, 2, 11, 9, 6
        .byte 6, 9, 11, 2, 4, 8, 12, 14, 10, 5, 15, 3, 7, 13, 1
        .byte 1, 13, 7, 3, 15, 5, 10, 14, 12, 8, 4, 2, 11, 9, 6
        .byte 6, 9, 11, 2, 4, 8, 12, 14, 10, 5, 15, 3, 7, 13, 1
        .byte 1, 13, 7, 3, 15, 5, 10, 14, 12, 8, 4, 2, 11, 9, 6

colourbar_lut_1:
        .byte 6, 6, 9, 11, 11, 2, 4, 4, 8, 12, 12, 14, 10, 10, 5, 15, 15, 3, 13, 7, 7, 1
        .byte 1, 7, 7, 13, 3, 15, 15, 5, 10, 10, 14, 12, 12, 8, 4, 4, 2, 11, 11, 9, 6, 6



colourbar_lut_2:
        .byte 6, 9, 9, 11, 2, 2, 4, 8, 8, 12, 14, 14, 10, 5, 5, 15, 3, 3, 13, 13, 7, 1
        .byte 1, 7, 13, 13, 3, 3, 15, 5, 5, 10, 14, 14, 12, 8, 8, 4, 2, 2, 11, 9, 9, 6


text_colour_lut:
        .byte 6, 9, 11, 2, 4, 8, 12, 14, 10, 5, 15, 3, 7, 13, 1
        .byte 1, 13, 7, 3, 15, 5, 10, 14, 12, 8, 4, 2, 11, 9, 6

text_colour_lut_length:
        .byte 30

screen_rows_lo:
        .byte <$0400, <$0400+40, <$0400+80, <$0400+120, <$0400+160
        .byte <$0400+200, <$0400+240, <$0400+280, <$0400+320, <$0400+360
        .byte <$0400+400, <$0400+440, <$0400+480, <$0400+520, <$0400+560
        .byte <$0400+600, <$0400+640, <$0400+680, <$0400+720, <$0400+760
        .byte <$0400+800, <$0400+840, <$0400+880, <$0400+920, <$0400+960

screen_rows_hi:
        .byte >$0400, >$0400+40, >$0400+80, >$0400+120, >$0400+160
        .byte >$0400+200, >$0400+240, >$0400+280, >$0400+320, >$0400+360
        .byte >$0400+400, >$0400+440, >$0400+480, >$0400+520, >$0400+560
        .byte >$0400+600, >$0400+640, >$0400+680, >$0400+720, >$0400+760
        .byte >$0400+800, >$0400+840, >$0400+880, >$0400+920, >$0400+960


colour_rows_lo:
        .byte <($d800), <($d800+40), <($d800+80), <($d800+120), <($d800+160)
        .byte <($d800+200), <($d800+240), <($d800+280), <($d800+320), <($d800+360)
        .byte <($d800+400), <($d800+440), <($d800+480), <($d800+520), <($d800+560)
        .byte <($d800+600), <($d800+640), <($d800+680), <($d800+720), <($d800+760)
        .byte <($d800+800), <($d800+840), <($d800+880), <($d800+920), <($d800+960)

colour_rows_hi:
        .byte >($d800), >($d800+40), >($d800+80), >($d800+120), >($d800+160)
        .byte >($d800+200), >($d800+240), >($d800+280), >($d800+320), >($d800+360)
        .byte >($d800+400), >($d800+440), >($d800+480), >($d800+520), >($d800+560)
        .byte >($d800+600), >($d800+640), >($d800+680), >($d800+720), >($d800+760)
        .byte >($d800+800), >($d800+840), >($d800+880), >($d800+920), >($d800+960)


text_press_fire:
        .import binary "data/press-fire-text.bin"

mega_charmap:
        .import binary "gfx/mega-chars.bin"

thrust_charmap:
        .import binary "gfx/thrust-chars.bin"


        *=$1000 "Music"
music:
        .import binary "music/Rob_Hubbard_Remix.sid",$7e

        *=$3800 "charmap 01"
charmap_01:
        .import binary "gfx/charmap-01.bin"

.macro SetBorderColor(color) {
        lda #color
        sta $d020
        }

.macro SetScreenAndBorderColor(color) {
        lda #color
        sta $d020
        sta $d021
        }
