        * = $4000 "Game"

start_game:
        jsr clear_screen

        lda #%00000000
        sta interrupt_control

        brk
