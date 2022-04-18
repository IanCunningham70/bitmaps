                        //------------------------------------------------------------------------------
						// 0 - T > B On.			1 - T > B Off.
						// 2 - B > T On.			3 - B > T Off.
						// 4 - Lines On.			5 - Lines Off.
						// 6 - To The Middle On.		7 - To The Middle Off.
						// 8 - Every 8th Line On. (D)	9 - Every 8th Line Off. (D)
						// A - Mini Letter Box On.	B - Mini Letter Box Off.
						// C - Bottom To Top x4 On.	D - Bottom To Top x4 Off.
                        //------------------------------------------------------------------------------
BasicUpstart2(start)
                        //------------------------------------------------------------------------------
						// import music - default tune for the intro section only
                        //------------------------------------------------------------------------------
						.var music = LoadSid("/sids/Soldier_of_Fortune.sid")
						*=music.location "Music"
        				.fill music.size, music.getData(i)
                        //------------------------------------------------------------------------------

                        //------------------------------------------------------------------------------
						// import koala picture
                        //------------------------------------------------------------------------------
						*=$2000 "test picture"
						.import c64 "koala backdrop 1.kla"
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
						*=$6000 "main code"
                        //------------------------------------------------------------------------------
start:					ldy #200 	// Clear Bitmap fx Table.
						lda #$7b
set:					sta bitmap_table,y
						dey
						bne set
						sta screenmode

						lda #BLACK
						sta border
						sta screen

						lda #$00
						tax
						tay
						jsr music.init

						sei
						ldx #$2f
						ldy #$35
						stx $00
						sty $01						
						lda #$7f
						sta $dc0d
						lda $dc0d
						lda #$3b
						sta screenmode
						lda #$32
						sta raster
						lda #216
						sta smoothpos
						lda #24
						sta charset
						lda #$81
						sta irqenable
						lda #$01
						sta $d019
						sta $d01a
						lda $d019
						lda $d01a						
						ldx #<bitirq
						ldy #>bitirq
						stx $fffe
						sty $ffff
						cli 

						jsr show_bitmap

						
						
						jsr dofx0


						jmp *

						lda #$ad
						sta pause
pause: 					lda pause
						lda #$4c
						sta pause

key:					jsr $ffe4
						and #$3f
						ldy #$00
key_chk:				cmp keys,y
						beq is1
						iny
						cpy #$0f
						bne key_chk
						jmp key
is1:					cmp #$01
						bne is2
						jmp dofx0
is2:					cmp #$02
						bne is3
						jmp dofx0a
is3:					cmp #$03
						bne is4
						jmp dofx1
is4:					cmp #$04
						bne is5
						jmp dofx1a
is5:					cmp #$05
						bne is6
						jmp dofx2
is6:					cmp #$06
						bne is7
						jmp dofx2a
is7:					cmp #$07
						bne is8
						jmp dofx3
is8:					cmp #$08
						bne is9
						jmp dofx3a
is9:					cmp #$09
						bne isa
						jmp dofx4
isa:					cmp #$0a
						bne isB
						jmp dofx4a
isB:					cmp #$0b
						bne isC
						jmp dofx5
isC:					cmp #$0c
						bne key
						jmp dofx5a
						//------------------------------------------------------------------
show_bitmap:			ldx #00
				!:		lda screen_data,x
						sta $0400,x
						lda screen_data + $100,x
						sta $0500,x
						lda screen_data + $200,x
						sta $0600,x
						lda screen_data + $300,x
						sta $0700,x
						lda colour_data,x
						sta $d800,x
						lda colour_data + $100,x
						sta $d900,x
						lda colour_data + $200,x
						sta $da00,x
						lda colour_data + $300,x
						sta $db00,x						
						dex
						bne !-
						rts
						//------------------------------------------------------------------
						// This IRQ Is Used For The BITMAP Pictures.
						//------------------------------------------------------------------
bitirq:					pha
						txa
						pha
						tya
						pha

						ldx #(0*8)+$31
						cpx raster
						bne *-3
                        ldx #$04
						dex
						bne *-1
				!:		ldy timing_table,x
						lda bitmap_table,x
						dey
						bne *-1
						sta screenmode
						sta screenmode
						inx
						cpx #200
						bne !-
						ldx #$08
						dex
						bne *-1
						lda #$0b	// Mask Off Remaining Bitmap & FLI Data.
						sta screenmode

						ldx #(25*8)+$31
						cpx raster
						bne *-3

						jsr music.play

fxbyte0:				lda fx0_on	// Top To Bottom.
fxbyte1:				lda fx1_on	// Bottom To Top.
fxbyte2:				lda fx2_on	// The Lines.
fxbyte3:				lda fx3_on	// To The Middle.
fxbyte4:				lda fx4_on	// Every 8th Line. (Downwards)
fxbyte5:				lda fx5_on	// Mini Letter Box.

						inc irqflag
						pla
						tay
						pla
						tax
						pla
rti_vector:				rti
                        //------------------------------------------------------------------------------
add_one:				lda tablePosition
						clc
						adc #$01
						sta tablePosition
						rts
						//------------------------------------------------------------------
sub_one:				lda tablePosition
						sec
						sbc #$01
						sta tablePosition
						rts
						//------------------------------------------------------------------
						// The FX Routines.
						//------------------------------------------------------------------
dofx0:					lda #$00	// Table Start Position.
						ldx #$3b	// Bitmap Toggle Code.
						ldy #$20	
						sta tablePosition
						stx toggleByte
						sty fxbyte0
						jmp pause-5
						//------------------------------------------------------------------
dofx0a:					lda #$00	// Table Start Position.
						ldx #$7b	// Bitmap Toggle Code.
						ldy #$20	
						sta tablePosition
						stx toggleByte
						sty fxbyte0
						jmp pause-5
						//------------------------------------------------------------------
dofx1:					lda #240	// Table Start Position.
						ldx #$3b	// Bitmap Toggle Code.
						ldy #$20	
						sta tablePosition
						stx toggleByte
						sty fxbyte1
						jmp pause-5
						//------------------------------------------------------------------
dofx1a:					lda #240	// Table Start Position.
						ldx #$7b	// Bitmap Toggle Code.
						ldy #$20	
						sta tablePosition
						stx toggleByte
						sty fxbyte1
						jmp pause-5
						//------------------------------------------------------------------
dofx2:					lda #$00	// Table Start Position.
						ldx #$3b	// Bitmap Toggle Code.
						ldy #$20	
						sta tablePosition
						stx toggleByte
						sty fxbyte2
						jmp pause-5
						//------------------------------------------------------------------
dofx2a:					lda #$00	// Table Start Position.
						ldx #$7b	// Bitmap Toggle Code.
						ldy #$20	
						sta tablePosition
						stx toggleByte
						sty fxbyte2
						jmp pause-5
						//------------------------------------------------------------------
dofx3:					lda #$00	// Table Start Position.
						ldx #$3b	// Bitmap Toggle Code.
						ldy #$20	
						sta tablePosition
						stx toggleByte
						sty fxbyte3
						jmp pause-5
						//------------------------------------------------------------------
dofx3a:					lda #$00	// Table Start Position.
						ldx #$7b	// Bitmap Toggle Code.
						ldy #$20	
						sta tablePosition
						stx toggleByte
						sty fxbyte3
						jmp pause-5
						//------------------------------------------------------------------
dofx4:					lda #$00	// Table Start Position.
						ldx #$3b	// Bitmap Toggle Code.
						ldy #$20	
						sta tablePosition
						stx toggleByte
						sty fxbyte4
						jmp pause-5
						//------------------------------------------------------------------
dofx4a:					lda #$00	// Table Start Position.
						ldx #$7b	// Bitmap Toggle Code.
						ldy #$20	
						sta tablePosition
						stx toggleByte
						sty fxbyte4
						jmp pause-5
						//------------------------------------------------------------------
dofx5:					lda #$00	// Table Start Position.
						ldx #$3b	// Bitmap Toggle Code.
						ldy #$20	
						sta tablePosition
						stx toggleByte
						sty fxbyte5
						jmp pause-5
						//------------------------------------------------------------------
dofx5a:					lda #$00	// Table Start Position.
						ldx #$7b	// Bitmap Toggle Code.
						ldy #$20	
						sta tablePosition
						stx toggleByte
						sty fxbyte5
						jmp pause-5
						//------------------------------------------------------------------
						// fx0:draw bitmap from top of screen to botton, 1 pixel line at a
						// time. 
						//------------------------------------------------------------------
fx0_on:					ldy tablePosition
						cpy #240
						bne fx0_on1
						lda #$ad
						sta fxbyte0
						rts
fx0_on1:				lda toggleByte
						sta bitmap_table,y
						jmp add_one
						//------------------------------------------------------------------
						// fx1:draw bitmap from bottom of screen to top, 1 pixel line at a
						// time. 
						//------------------------------------------------------------------
fx1_on:					ldy tablePosition
						bne fx1_on1
						lda #$ad
						sta fxbyte1
						rts
fx1_on1:				lda toggleByte
						sta bitmap_table,y
						jmp sub_one
						//------------------------------------------------------------------
						// fx2:The Classic `LINES` Effect.
						//------------------------------------------------------------------
fx2_on:					ldy tablePosition
						cpy #240
						bne fx2_on1
						lda #$ad
						sta fxbyte2
						rts
fx2_on1:				tya
						lsr
						bcc fx2_on2
						lda #240
						sec
						sbc tablePosition
						tay
fx2_on2:				lda toggleByte
						sta bitmap_table,y
						jmp add_one
						//------------------------------------------------------------------
						// fx3:Top & Bottom of The Screen to the MIDDLE.
						//------------------------------------------------------------------
fx3_on:					ldy tablePosition
						cpy #101
						bne fx3_on1
						lda #$ad
						sta fxbyte3
						rts
fx3_on1:				lda toggleByte
						sta bitmap_table,y
						lda #240
						sec
						sbc tablePosition
						tay
						lda toggleByte
						sta bitmap_table,y
						jmp add_one
						//--------------------------------------------------------------------
						// fx4:Every 8th line (Downwards)
						//--------------------------------------------------------------------
fx4_on:					lda tablePosition
						clc
						adc #8
						cmp #$c8
						bcc fx4_on1
						sec
						sbc #$c7
						cmp #$08
						bne fx4_on1
						lda #$ad
						sta fxbyte4
						rts
fx4_on1:				sta tablePosition
						tay
						lda toggleByte
						sta bitmap_table,y
						rts
                        //------------------------------------------------------------------------------
						// fx5:Top & Bottom of The Screen to the MIDDLE.
                        //------------------------------------------------------------------------------
fx5_on:					ldy tablePosition
						cpy #51
						bne fx5_on1
						lda #$ad
						sta fxbyte5
						rts
fx5_on1:				lda toggleByte
						sta bitmap_table,y
						lda #100
						clc
						adc tablePosition
						tay
						lda toggleByte
						sta bitmap_table,y
						lda #100
						sec
						sbc tablePosition
						tay
						lda toggleByte
						sta bitmap_table,y
						lda #200
						sec
						sbc tablePosition
						tay
						lda toggleByte
						sta bitmap_table,y
						jmp add_one
                        //------------------------------------------------------------------------------
						//	 A   B   C   D   E   F   G   H   I   J   K   L   M   N   O
keys:					.byte	$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f
						//	 P   Q   R   S   T   U
						.byte	$10,$11,$12,$13,$14,$15
                        //------------------------------------------------------------------------------
areg:					.byte $00,$00
xreg:					.byte $00,$00
yreg:					.byte $00,$00

tablePosition:				.byte $00                       // Table Position Counter.
toggleByte:				.byte $00                       // Table Byte Position.
bank_no:				.byte $02
b_color:				.byte $00
						//------------------------------------------------------------------

						//------------------------------------------------------------------
						.align $1000
						.memblock "timing table"
													
timing_table:
						.byte	$0b,$08,$01,$08,$08,$08,$08,$08,$08,$08,$01,$08,$08,$08,$08,$08
						.byte	$08,$08,$01,$08,$08,$08,$08,$08,$08,$08,$01,$08,$08,$08,$08,$08
						.byte	$08,$08,$01,$08,$08,$08,$08,$08,$08,$08,$01,$08,$08,$08,$08,$08
						.byte	$08,$08,$01,$08,$08,$08,$08,$08,$08,$08,$01,$08,$08,$08,$08,$08
						.byte	$08,$08,$01,$08,$08,$08,$08,$08,$08,$08,$01,$08,$08,$08,$08,$08
						.byte	$08,$08,$01,$08,$08,$08,$08,$08,$08,$08,$01,$08,$08,$08,$08,$08
						.byte	$08,$08,$01,$08,$08,$08,$08,$08,$08,$08,$01,$08,$08,$08,$08,$08
						.byte	$08,$08,$01,$08,$08,$08,$08,$08,$08,$08,$01,$08,$08,$08,$08,$08
						.byte	$08,$08,$01,$08,$08,$08,$08,$08,$08,$08,$01,$08,$08,$08,$08,$08
						.byte	$08,$08,$01,$08,$08,$08,$08,$08,$08,$08,$01,$08,$08,$08,$08,$08
						.byte	$08,$08,$01,$08,$08,$08,$08,$08,$08,$08,$01,$08,$08,$08,$08,$08
						.byte	$08,$08,$01,$08,$08,$08,$08,$08,$08,$08,$01,$08,$08,$08,$08,$08
						.byte	$08,$08,$01,$08,$08,$08,$08,$08,$08,$08,$01,$08,$08,$08,$08,$08
						.byte	$08,$08,$01,$08,$08,$08,$08,$08,$08,$08,$01,$08,$08,$08,$08,$08
						.byte	$08,$08,$01,$08,$08,$08,$08,$08,$08,$08,$01,$08,$08,$08,$08,$08
						.byte	$08,$08,$01,$08,$08,$08,$08,$08,$08,$08,$01,$08,$08,$08,$08,$08
						.byte	$08,$08,$01,$08,$08,$08,$08,$08,$08,$08,$01,$08,$08,$08,$08,$08
						.byte	$08,$08,$01,$08,$08,$08,$08,$08,$08,$08,$01,$08,$08,$08,$08,$08
						.byte	$08,$08,$01,$08,$08,$08,$08,$08,$08,$08,$01,$08,$08,$08,$08,$08

						.align $200
						.memblock "d011 table"

bitmap_table:			.byte	$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b
						.byte	$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b
						.byte	$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b
						.byte	$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b
						.byte	$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b
						.byte	$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b
						.byte	$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b
						.byte	$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b
						.byte	$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b
						.byte	$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b
						.byte	$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b
						.byte	$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b
						.byte	$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b
						.byte	$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b
						.byte	$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b
						.byte	$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b
						.byte	$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b
						.byte	$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b
						.byte	$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b

