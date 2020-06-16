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

        *=$1000 "Music"
music:
        .import binary "music/Rob_Hubbard_Remix.sid",$7e

.macro SetBorderColor(color) {
        lda #color
        sta $d020
        }

.macro SetScreenAndBorderColor(color) {
        lda #color
        sta $d020
        sta $d021
        }
