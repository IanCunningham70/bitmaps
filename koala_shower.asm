BasicUpstart2(start)
                        //------------------------------------------------------------------------------
						// import music - default tune for the intro section only
                        //------------------------------------------------------------------------------
						.var music = LoadSid("/sids/Soldier_of_Fortune.sid")
						*=music.location "Music"
        				.fill music.size, music.getData(i)
                        //------------------------------------------------------------------------------

                        //------------------------------------------------------------------------------
						// import standard library definitions
                        //------------------------------------------------------------------------------
						#import "standardLibrary.asm" 
                        //------------------------------------------------------------------------------

                        //------------------------------------------------------------------------------
						.var screen_data = $3f40
						.var colour_data = $4328
						.var back_colour = $4710
                        //------------------------------------------------------------------------------


                        //------------------------------------------------------------------------------
                        * = $0900 "start"
                        //------------------------------------------------------------------------------
start:
						sei
						lda #$2f
						ldy #$35
						sta $00
						sty $01

						lda #$00
						tay
						tax
						jsr music.init

						jsr show_bitmap

						lda #$7f
						sta $dc0d
						lda $dc0d
						lda #$81
						sta irqenable

						lda #$18
						sta charset
						lda #$18
						sta smoothpos
						lda #32
						sta raster
						lda #<do_music
						ldy #>do_music
						sta $fffe
						sty $ffff
						lda #<rti_vector
						ldy #>rti_vector
						sta $fffa
						sty $fffb
						cli

case:    				jmp case
                        //------------------------------------------------------------------------------

                        //------------------------------------------------------------------------------
						// x - raster line position.
						// a - LO-byte of next irq section.
						// y - HI-byte of next irq section.
                        //------------------------------------------------------------------------------

                        //------------------------------------------------------------------------------
do_music:				sta areg
						stx xreg
						sty yreg
						asl irqflag

						// turn on bitmap mode

						lda #$18
						sta charset
						lda #$18
						sta smoothpos

						jsr music.play

						lda #$3b
						sta screenmode

						lda back_colour
						sta screen
						
						ldx #$01
						lda #<do_music
						ldy #>do_music
						jmp return_irq
                        //------------------------------------------------------------------------------


                        //------------------------------------------------------------------------------
						// IRQ Process Routines.
                        //------------------------------------------------------------------------------
return_irq:				stx raster
						sta $fffe
						sty $ffff
						lda areg
						ldx xreg
						ldy yreg
rti_vector:				rti
                        //------------------------------------------------------------------------------
areg:					.byte $00
xreg:					.byte $00
yreg:					.byte $00
                        //------------------------------------------------------------------------------


show_bitmap:			ldx #00
						lda screen_data,x
						sta $0400,x
						lda screen_data + $100,x
						sta $0500,x
						lda screen_data + $200,x
						sta $0600,x
						lda screen_data + $300,x
						sta $0700,x
						dex
						bne show_bitmap+2
						rts



                        //------------------------------------------------------------------------------
						// plot bitmap colours from top of the screen to the bottom line by line
                        //------------------------------------------------------------------------------
top2Bottom:				

						lda #BLACK
						jsr recolor

						lda #$00
						sta DH_line
						sta DH_color

				!:		lda DH_line
						cmp #25
						beq DH_exit

						jsr DH_colorCycle
						inc DH_line
						lda DH_lineColor+1 						// set the next screen line
						clc
						adc #40
						sta DH_lineColor+1
						lda DH_lineColor+2
						adc #00
						sta DH_lineColor+2
						jmp !-
DH_colorCycle:			lda DH_color
						cmp #17
						bne !+
						lda #$00
						sta DH_color
						rts
				!:		ldy #32
				!:		ldx #64
				!:		dex
						bne !-
						dey
						bne !--
						jsr DH_linePlot
						inc DH_color
						jmp DH_colorCycle
DH_linePlot:			ldx #$00
						ldy DH_color
						lda DH_colorTable,y
DH_lineColor:			sta $d800,x
						inx
						cpx #40
						bne DH_lineColor
						rts
DH_exit:				jsr standardPause
						rts
                        //------------------------------------------------------------------------------
DH_line:				.byte $00				// current line number
DH_color:				.byte $00				// current colour counter
DH_colorTable:									// fade from black to brown
						.byte $00,$00, $0b,$0b,$02,$02,$04,$04,$0e,$0e,$03,$03,$0d,$0d, $01,$01
						.byte BROWN				// final version will show actual bitmap colors
                        //------------------------------------------------------------------------------
standardPause:			
						jsr pauseLoop
						jsr pauseLoop

						rts
                        //------------------------------------------------------------------------------
pauseLoop:				ldy #255
			!:			ldx #255
				!:		dex
						bne !-
						dey
						bne !--
						rts
                        //------------------------------------------------------------------------------
recolor:				ldx #$00
				!:		sta $d800,x
						sta $d900,x
						sta $da00,x
						sta $db00,x
						dex
						bne !-
						rts
                        //------------------------------------------------------------------------------
						lda colour_data,x
						sta $d800,x
						lda colour_data + $100,x
						sta $d900,x
						lda colour_data + $200,x
						sta $da00,x
						lda colour_data + $300,x
						sta $db00,x
						rts
                        //------------------------------------------------------------------------------
						// import koala picture
                        //------------------------------------------------------------------------------
						*=$2000
						.import c64 "koala backdrop 1.kla"
                        //------------------------------------------------------------------------------
