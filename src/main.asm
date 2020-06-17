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
        // lda #$35
        // sta $01

        SetScreenAndBorderColor($00)
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

        jsr clear_screen
        jsr title

        lda #$00
        sta raster_line

        asl interrupt_status
        cli

        jmp *

irq1:
        // pha
        // txa
        // pha
        // tya
        // pha

        SetBorderColor(2)
        jsr music+3
        SetBorderColor(5)
        jsr copy_frame_lut
        SetBorderColor(0)

        // next interrupt
        lda #<irq2
        sta irq_low
        lda #>irq2
        sta irq_high

        lda #91
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
        lda #93
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
        cmp #93
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
        nop
        nop
        nop

colour_bar_loop:
        jsr colour_bar
        jsr colour_bar
        jsr colour_bar
        jsr colour_bar

        //jsr badline_bar
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

        //jsr badline_bar
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

        //jsr badline_bar
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

        //jsr badline_bar
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

        //jsr badline_bar
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

        //jsr badline_bar
        inx
        lda colourbar_lut,x
        sta screen_colour
        nop
        nop
        nop
        nop
        nop


        lda #$00
        sta screen_colour

        //cli

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
        lda #$00
        sta screen_colour

        nop
        nop
        nop
        bit $00
        rts

badline_bar:
        inx
        stx screen_colour
        bit $00
        rts

clear_screen:
        lda #$00
        ldx #$00

clr_loop:
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
        bne clr_loop

        rts

        // ldx start poke val
        // ldy start offset
printer:
        ldy #$00
print_loop:
        txa
        sta $0500,y
        inx
        iny

        cpy #$9
        bne print_loop

        rts

        .var title_xpos = 15
        .var title_ypos = 6

title:
        // MEGA
//        ldx #$01
//        lda #40*title_ypos+title_xpos+1
//        sta printer+4
//        jsr printer
//
//        lda #40*(1+title_ypos)+title_xpos+1
//        sta printer+4
//        jsr printer
//
//        lda #40*(2+title_ypos)+title_xpos+1
//        sta printer+4
//        jsr printer
//
//        // THRUST
//        lda #$b
//        sta printer+9      // line is two longer
//
//        lda #40*(3+title_ypos)+title_xpos
//        sta printer+4
//        jsr printer
//
//        lda #40*(4+title_ypos)+title_xpos
//        sta printer+4
//        jsr printer
//
//        lda #40*(5+title_ypos)+title_xpos
//        sta printer+4
//        jsr printer

        jsr draw_char_block

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
        ldy mega_charmap
        dey
        sty dcb_width+1
        ldx #1
        ldy mega_charmap,X
        dey
        sty dcb_height+1

dcb_height:
        ldy #1

dcb_width:
        ldx #1
        lda mega_charmap+2,X
        sta $04fc,X
        dex
        cpx #$00
        bpl dcb_width+2

        // add one row to all the locs
        // add width to lda
        lda dcb_width+3
        clc
        adc #$12
        sta dcb_width+3
        lda dcb_width+4
        adc #$00
        sta dcb_width+4

        // add 40 to sta
        lda dcb_width+6
        clc
        adc #40
        sta dcb_width+6
        lda dcb_width+7
        adc #$00
        sta dcb_width+7

        dey
        cpy #$00
        bpl dcb_width

        rts


        * = $2000 "colour LUT"
colourbar_lut:
        .byte 6, 9, 11, 2, 4, 8, 12, 14, 10, 5, 15, 3, 7, 13, 1
        .byte 1, 13, 7, 3, 15, 5, 10, 14, 12, 8, 4, 2, 11, 9, 6
        .byte 6, 9, 11, 2, 4, 8, 12, 14, 10, 5, 15, 3, 7, 13, 1
        .byte 1, 13, 7, 3, 15, 5, 10, 14, 12, 8, 4, 2, 11, 9, 6
        .byte 6, 9, 11, 2, 4, 8, 12, 14, 10, 5, 15, 3, 7, 13, 1
        .byte 1, 13, 7, 3, 15, 5, 10, 14, 12, 8, 4, 2, 11, 9, 6

colourbar_lut_1:
        .byte 0, 0, 0, 0
        .byte 6, 6, 9, 11, 11, 2, 4, 4, 8, 12, 12, 14, 10, 10, 5, 15, 15, 3, 13, 7, 7, 1
        .byte 1, 7, 7, 13, 3, 15, 15, 5, 10, 10, 14, 12, 12, 8, 4, 4, 2, 11, 11, 9, 6, 6



colourbar_lut_2:
        .byte 0, 0, 0, 0
        .byte 6, 9, 9, 11, 2, 2, 4, 8, 8, 12, 14, 14, 10, 5, 5, 15, 3, 3, 13, 13, 7, 1
        .byte 1, 7, 13, 13, 3, 3, 15, 5, 5, 10, 14, 14, 12, 8, 8, 4, 2, 2, 11, 9, 9, 6


old_colour_lut:
        .byte 6, 9, 11, 2, 4, 8, 12, 14, 10, 5, 15, 3, 7, 13, 1
        .byte 1, 13, 7, 3, 15, 5, 10, 14, 12, 8, 4, 2, 11, 9, 6

mega_charmap:
        .import binary "gfx/mega-chars.bin"



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
