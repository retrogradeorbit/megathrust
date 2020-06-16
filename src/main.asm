        .var irq_low = $0314
        .var irq_high = $0315
        .var irq_control = $dc0d
        .var nmi_control = $dd0d
        .var interrupt_control = $d01a
        .var screen_control = $d011
        .var raster_line = $d012
        .var interrupt_status = $d019
        .var vic_memory_setup = $d018

        // kernel
        .var normal_interrupt = $ea31
        .var normal_interrupt_no_keyboard_scan = $ea81

        * = $0801 "Main Program"
start:
        SetScreenAndBorderColor($00)
        lda #$00
        jsr music
        sei

        lda #<irq1
        sta irq_low
        lda #>irq1
        sta irq_high

        lda #%00000001
        sta irq_control
        sta nmi_control

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

        lda irq_control
        lda nmi_control
        asl interrupt_status
        cli
        jmp *

irq1:   asl interrupt_status
        SetBorderColor(2)
        jsr music+3
        SetBorderColor(0)
        jmp normal_interrupt_no_keyboard_scan

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

title:
        lda #$01
        sta $0400+40*5+10
        lda #$02
        sta $0400+40*5+11
        lda #$03
        sta $0400+40*5+12
        lda #$04
        sta $0400+40*5+13
        lda #$05
        sta $0400+40*5+14
        lda #$06
        sta $0400+40*5+15
        lda #$07
        sta $0400+40*5+16
        lda #$08
        sta $0400+40*5+17
        lda #$09
        sta $0400+40*5+18

        lda #$0a
        sta $0400+40*6+10
        lda #$0b
        sta $0400+40*6+11
        lda #$0c
        sta $0400+40*6+12
        lda #$0d
        sta $0400+40*6+13
        lda #$0e
        sta $0400+40*6+14
        lda #$0f
        sta $0400+40*6+15
        lda #$10
        sta $0400+40*6+16
        lda #$11
        sta $0400+40*6+17
        lda #$12
        sta $0400+40*6+18

        lda #$13
        sta $0400+40*7+10
        lda #$14
        sta $0400+40*7+11
        lda #$15
        sta $0400+40*7+12
        lda #$16
        sta $0400+40*7+13
        lda #$17
        sta $0400+40*7+14
        lda #$18
        sta $0400+40*7+15
        lda #$19
        sta $0400+40*7+16
        lda #$1a
        sta $0400+40*7+17
        lda #$1b
        sta $0400+40*7+18

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
