        * = $0801 "Main Program"
start:
        lda #$00
        sta $d020
        sta $d021
        lda #$00
        jsr music
        sei
        lda #<irq1
        sta $0314
        lda #>irq1
        sta $0315
        lda #$7f
        sta $dc0d
        sta $dd0d
        lda #$81
        sta $d01a
        lda #$1b
        sta $d011
        lda #$80
        sta $d012
        lda $dc0d
        lda $dd0d
        asl $d019
        cli
        jmp *

irq1:   asl $d019
        SetBorderColor(2)
        jsr music+3
        SetBorderColor(0)
        jmp $ea81

        *=$1000 "Music"
music:
        .import binary "music/Rob_Hubbard_Remix.sid",$7e

.macro SetBorderColor(color) {
        lda #color
        sta $d020
}
