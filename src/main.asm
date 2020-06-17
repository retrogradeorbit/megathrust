        .var irq_low = $0314
        .var irq_high = $0315
        .var irq_control = $dc0d
        .var nmi_control = $dd0d
        .var interrupt_control = $d01a
        .var screen_control = $d011
        .var raster_line = $d012
        .var interrupt_status = $d019
        .var vic_memory_setup = $d018
        .var vic_bank_select = $dd00

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

        lda #%00000011
        sta vic_bank_select

        jsr clear_screen
        jsr title
        jsr init_sprites

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
        //jsr copy_frame_lut
        SetBorderColor(0)

        // next interrupt
        lda #<sprites_1
        sta irq_low
        lda #>sprites_1
        sta irq_high

        lda #90
        sta raster_line

        // ack interrupt
        inc interrupt_status

        pla
        tay
        pla
        tax
        pla

        rti

sprites_1:
        inc $d021

        // sprite pointers
        lda #$f8
        sta $07f8
        lda #$f9
        sta $07f9
        lda #$fa
        sta $07fa
        lda #$fb
        sta $07fb
        lda #$fc
        sta $07fc
        lda #$fd
        sta $07fd

        // sprite positions
        ldx #94
        stx $d001
        stx $d003
        stx $d005
        stx $d007
        stx $d009
        stx $d00b

        inc interrupt_status
        lda #113
        sta raster_line
        lda #<sprites_2
        sta irq_low
        lda #>sprites_2
        sta irq_high

        pla
        tay
        pla
        tax
        pla

        rti

sprites_2:
        inc $d021

        // sprite pointers
        lda #$fe
        sta $07f8
        lda #$ff
        sta $07f9
        lda #$fa
        sta $07fa
        lda #$fb
        sta $07fb
        lda #$fc
        sta $07fc
        lda #$fd
        sta $07fd

        // sprite positions
        ldx #94+21
        stx $d001
        stx $d003
        stx $d005
        stx $d007
        stx $d009
        stx $d00b

        inc interrupt_status
        lda #0
        sta raster_line
        lda #<irq1
        sta irq_low
        lda #>irq1
        sta irq_high

        pla
        tay
        pla
        tax
        pla

        rti




irq2:
        //lda #93
        //sta raster_line
        //lda #<irq3
        //sta irq_low
        //lda #>irq3
        //sta irq_high

        //inc $d021

        // ack interrupt
        inc interrupt_status

        ldx raster_line

        // sprites
        cpx #80  // $50
        bmi skip
        jsr sprites_1

        ldx raster_line
        cpx #100
        bmi skip
        jsr sprites_2

skip:
        // end
        ldx raster_line
        cpx #200
        bpl reset_irq1

end:
        ldx raster_line
        inx
        stx raster_line

        pla
        tay
        pla
        tax
        pla

        rti




reset_irq1:
        lda #$00
        sta $d021

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


        // temp
        //nop
        //nop
        //nop

        //jsr colour_bar
        //jsr sprite_line
        //jsr colour_bar
        //jsr colour_bar
        //jsr colour_bar

        //lda #$08
        //sta $d021

//      TEMP
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
        //nop
        //nop
        //nop


        //TEMP
        jsr colour_bar_loop

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

short_colour_bar:
        //nop
        //nop
        //nop
        bit $00   // instead of nop
        nop

        inx
        lda colourbar_lut,x
        sta screen_colour
        nop
        nop
        nop
        //nop
        //nop
        bit $00//nop
        nop
        nop
        nop
        lda #$00
        sta screen_colour

        nop
        nop
        bit $00
        rts

sprite_line:
        nop
        nop
        nop
        nop
        nop
        nop
        rts

colour_bar_loop:
        jsr short_colour_bar
        jsr short_colour_bar
        jsr short_colour_bar
        jsr short_colour_bar

        //jsr badline_bar
        inx
        lda colourbar_lut,x
        sta screen_colour
        //nop
        //nop
        //nop
        bit $00//nop
        nop

        jsr short_colour_bar
        jsr short_colour_bar
        jsr short_colour_bar
        jsr short_colour_bar
        jsr short_colour_bar
        jsr short_colour_bar
        jsr short_colour_bar

        //jsr badline_bar
        inx
        lda colourbar_lut,x
        sta screen_colour
        //nop
        //nop
        //nop
        bit $00//nop
        nop

        jsr short_colour_bar
        jsr short_colour_bar
        jsr short_colour_bar
        jsr short_colour_bar
        jsr short_colour_bar
        jsr short_colour_bar
        jsr short_colour_bar

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

init_sprites:
        // sprite pointers
        lda #$f8
        sta $07f8
        lda #$f9
        sta $07f9
        lda #$fa
        sta $07fa
        lda #$fb
        sta $07fb
        lda #$fc
        sta $07fc
        lda #$fd
        sta $07fd
        lda #$fe
        sta $07fe
        lda #$ff
        sta $07ff

        // sprite extra colors
        //lda #$01
        //sta $d025
        //lda #$06
        //sta $d026

        // sprite colours
        lda #$01
        sta $d027
        sta $d028
        sta $d029
        sta $d02a
        sta $d02b
        sta $d02c
        sta $d02d
        sta $d02e

        // sprite enable
        lda #%00111111
        sta $d015

        // sprite priority. in front of screen
        lda #%00000000
        sta $d01b

        // sprite multicolor off
        lda #%00000000
        sta $d01c

        // double width + double height
        lda #%00000000
        sta $d01d
        sta $d017

        // x-coord bit 8
        lda #%00000000
        sta $d010

        // sprite 0
        lda #120
        sta $d000
        ldx #94
        stx $d001

        adc #23
        sta $d002
        ldx #94
        stx $d003

        adc #24
        sta $d004
        ldx #94
        stx $d005

        adc #24
        sta $d006
        ldx #94
        stx $d007

        adc #24
        sta $d008
        ldx #94
        stx $d009

        adc #24
        sta $d00a
        ldx #94
        stx $d00b


        //lda #150
        //sta $d002
        //sta $d003

        //lda #200
        //sta $d002
        //sta $d003


        lda #%00011110
        sta $d018

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
        lda #$fc
        sta $14

        jsr draw_char_block


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
        lda #$c2
        sta $14

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

dcb_height:
        ldx #$0
dcb_width:
        ldy #$0
dcb_read:
        lda ($12),y
dcb_screen_dest:
        sta ($14),y
        iny
        cpy $10
        bmi dcb_read

        // add one row to all the locs
        // add width to lda
        lda $12
        clc
dcb_rowsize:
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
        bmi dcb_width

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
        .byte 1, 0, 1, 0
        .byte 6, 6, 9, 11, 11, 2, 4, 4, 8, 12, 12, 14, 10, 10, 5, 15, 15, 3, 13, 7, 7, 1
        .byte 1, 7, 7, 13, 3, 15, 15, 5, 10, 10, 14, 12, 12, 8, 4, 4, 2, 11, 11, 9, 6, 6



colourbar_lut_2:
        .byte 0, 1, 0, 1
        .byte 6, 9, 9, 11, 2, 2, 4, 8, 8, 12, 14, 14, 10, 5, 5, 15, 3, 3, 13, 13, 7, 1
        .byte 1, 7, 13, 13, 3, 3, 15, 5, 5, 10, 14, 14, 12, 8, 8, 4, 2, 2, 11, 9, 9, 6


old_colour_lut:
        .byte 6, 9, 11, 2, 4, 8, 12, 14, 10, 5, 15, 3, 7, 13, 1
        .byte 1, 13, 7, 3, 15, 5, 10, 14, 12, 8, 4, 2, 11, 9, 6

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

        *=$3e00 "spritemap 01"
spritemap_01:
        .import binary "gfx/spritemap-01.bin"

.macro SetBorderColor(color) {
        lda #color
        sta $d020
        }

.macro SetScreenColor(color) {
        lda #color
        sta $d021
        }

.macro SetScreenAndBorderColor(color) {
        lda #color
        sta $d020
        sta $d021
        }
