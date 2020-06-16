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

        lda #$ff
        sta interrupt_status
        //asl interrupt_status
        SetBorderColor(2)
        jsr music+3
        SetBorderColor(0)

        // next interrupt
        lda #<irq2
        sta irq_low
        lda #>irq2
        sta irq_high

        lda #8*12+4
        sta raster_line

        pla
        tay
        pla
        tax
        pla

        rti

irq2:
        // pha
        // txa
        // pha
        // tya
        // pha

        lda #$ff
        sta interrupt_status

        ldx raster_line
        cpx #$91
        bpl reset_irq

        inc raster_line
        inc screen_colour

        pla
        tay
        pla
        tax
        pla

        rti

reset_irq:
        lda #<irq1
        sta irq_low
        lda #>irq1
        sta irq_high

        lda #$00
        sta raster_line

        lda #$00
        sta screen_colour

        pla
        tay
        pla
        tax
        pla

        rti

clear_screen:
        lda #$00
        ldx #$00

clr_loop:
        sta $0400, x
        sta $04fa, x
        sta $05f4, x
        sta $06ee, x
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
        ldx #$01
        lda #40*title_ypos+title_xpos+1
        sta printer+4
        jsr printer

        lda #40*(1+title_ypos)+title_xpos+1
        sta printer+4
        jsr printer

        lda #40*(2+title_ypos)+title_xpos+1
        sta printer+4
        jsr printer

        // THRUST
        lda #$b
        sta printer+9      // line is two longer

        lda #40*(3+title_ypos)+title_xpos
        sta printer+4
        jsr printer

        lda #40*(4+title_ypos)+title_xpos
        sta printer+4
        jsr printer

        lda #40*(5+title_ypos)+title_xpos
        sta printer+4
        jsr printer

        rts

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
