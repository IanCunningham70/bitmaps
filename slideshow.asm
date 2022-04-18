                        //------------------------------------------------------------------------------
						// SlideShow II
						// ~~~~~~~~~~~~
						// v1.0		: 03/12/1994
						//	The Basic Version Containg All The Effects.
						//
						// v1.0a	: 20/12/1994
						//	Now With The Transfer Routines Implemented & Working.
						//
						// V1.1  	: 19/10/1995
						//	This Version Is Being Prepared For Release At Christmas,
						//	All Pictures, An Intro/End Sequence & Also A Hidden Demo
						//	Part Have Been Designed.
                        //------------------------------------------------------------------------------

                        //------------------------------------------------------------------------------
						// MEMORY MAP v1.0 FOR SLIDESHOW
						// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
						// $0800-$0FFF : IRQ LOADER INITIALISE & LOAD ROUTINES.
						// $1000-$1FFF : CURRENT MUSIC.
						// $2000-$7fff : GFX DATA (AFTER DEPACKING).
						// $8000-$???? : SLIDESHOW CODE.
						// $8B00-$8BC8 : FLI TABLE #1 ($D011)
						// $8C00-$8CC8 : FLI TABLE #2 ($D018)
						// $8D00-$8DC8 : RASTER TIMING TABLE.
						// $8E00-$8EC8 : BITMAP FX TABLE.
						// $8F00-$FFFF : RESERVED FOR FILES AFTER LOADING (SEE BELOW).
						//
						// MEMORY MAP FOR BITMAP PICTURES.
						// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
						// $9000-$AFFF : BITMAP DATA.
						// $B000-$B3FF : HARD COLORS ($0400).
						// $B400-$B7FF : SOFT COLORS ($D800).
						//
						// MEMORY MAP v1.0 FOR ALL FILES.
						// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
						//	$8f00 : FX On Code.
						//	$8f01 : FX Off Code.
						//	$8f02 : Picture Display Code. 
						//		$00 - Standard Bitmap.
						//		$01 - Fli 
						//		$02 - Hires. 		** NOT IN THIS VERSION **
						//
						//	$8f03 : Load New Music.
						//		$00 - No Change.
						//		$01 - Load Next Music.
						//
						//	$8f04 : New Music`s Init JSR 
						//	$8f07 : New Music`s Play JSR
						//	$8f0a : Music Is Twin Speed ?
						//		$00 - No.
						//		$01 - Yes.
						//	$8f0b : New Music`s Twin Play JSR.
						//
						// ALL FILES MUST BE LEVEL-PACKED AND LOAD TO $8f00 IN MEMORY!
						//
						// FX Code Table.
						// ~~~~~~~~~~~~~~
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
						.var music_twin	= $1003
						.var fli_tabd011 = $8b00
						.var fli_tabd018 = $8c00
						.var fli_tabd021 = $3b00

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
						sta $d011

						ldx #$ff
						txs
						ldx #$2f
						ldy #$36
						stx $00
						sty $01
						lda #$00	// Set Character & Border Colors.
						sta $d021	// Works On OLD Kernal 64's Aswell.
						sta 646
						jsr $e544
						lda #$00
						sta $d020
						sta $d021
						sta 650

						lda #$00
						tax
						tay
						jsr music.init

						lda #<rti_vector
						ldy #>rti_vector
						sta $fffa
						sty $fffb

						jsr switch0	// Set FLI Irq As > DEFAULT <
						// jsr switch1	// Set FLI Irq As > DEFAULT <
	
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
						//------------------------------------------------------------------
						//	 A   B   C   D   E   F   G   H   I   J   K   L   M   N   O
keys:					.byte	$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f
						//	 P   Q   R   S   T   U
						.byte	$10,$11,$12,$13,$14,$15
						//------------------------------------------------------------------
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
switch0:	
						// jsr bitmap_mover						// Transfer New Bitmap Data.

show_bitmap:			ldx #00
						lda screen_data,x
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
						bne show_bitmap+2
						
						sei								// BITMAP IRQ-Booter.
						lda #$7f
						sta $dc0d
						lda $dc0d
						lda #$0b
						sta $d011
						lda #$30						// Define Starting Raster Line.
						sta $d012 
						lda #$18
						sta $d018
						lda #216
						sta $d016
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
						rts
						//------------------------------------------------------------------
switch1: 
						jsr fli_mover						// Transfer New Fli Picture.

						sei		// FLI IRQ-Booter.
						lda #$7f
						sta $dc0d
						lda $dc0d
						lda #$3b
						sta $d011
						lda #$32	// Define Starting Raster Line.
						sta $d012 
						lda #$18
						sta $d016
						lda #$00
						sta $d020
						lda #$01
						sta $d019
						sta $d01a
						lda $d019
						lda $d01a
						ldx #<fliirq
						ldy #>fliirq
						stx $0314
						sty $0315
						cli
						rts
						//------------------------------------------------------------------
						// This IRQ Is Used For The BITMAP Pictures.
						//------------------------------------------------------------------
bitirq:	
						sta areg
						stx xreg
						sty yreg
						asl irqflag

						ldx #$04
						dex
						bne *-1
bitloop:				ldy timing_table,x
						lda bitmap_table,x
						dey
						bne *-1
						sta $d011
						sta $d011
						inx
						cpx #200
						bne bitloop
irqfin:					ldx #$08
						dex
						bne *-1
						lda #$7b	// Mask Off Remaining Bitmap & FLI Data.
						sta $d011
						ldx #$ff
						cpx $d012
						bne *-3

zakp1:					jsr music.play

fxbyte0:				lda fx0_on	// Top To Bottom.
fxbyte1:				lda fx1_on	// Bottom To Top.
fxbyte2:				lda fx2_on	// The Lines.
fxbyte3:				lda fx3_on	// To The Middle.
fxbyte4:				lda fx4_on	// Every 8th Line. (Downwards)
fxbyte5:				lda fx5_on	// Mini Letter Box.
	
zakp2:					lda music_twin

						ldx #$32
						lda #<bitirq
						ldy #>bitirq
						jmp return_irq
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

						//------------------------------------------------------------------
						// This IRQ Is Used For The FLI Pictures.
						//------------------------------------------------------------------
fliirq:				
						sta areg
						stx xreg
						sty yreg
						asl irqflag
						lda $dd00
						and #$fc
						ora bank_no
						sta $dd00
						bit $02
						lda #$08
						sta $d018
						lda fli_tabd021
						sta $d021
						bit $02
						inc $d019
						ldy #$00
fliloop:				lda fli_tabd011,y
						ldx fli_tabd018,y
						sta $d011
						stx $d018
						iny
						cpy #$c8
						bne fliloop
						ldy #$08
						dey
						bne *-1
						sta $d011
						stx $d018
						jmp irqfin
						//------------------------------------------------------------------
add_one:				lda tab_pos
						clc
						adc #$01
						sta tab_pos
						rts
						//------------------------------------------------------------------
sub_one:				lda tab_pos
						sec
						sbc #$01
						sta tab_pos
						rts
						//------------------------------------------------------------------
						// The FX Routines.
						//------------------------------------------------------------------
dofx0:					lda #$00	// Table Start Position.
						ldx #$3b	// Bitmap Toggle Code.
						ldy #$20	
						sta tab_pos
						stx tog_byt
						sty fxbyte0
						jmp pause-5
						//------------------------------------------------------------------
dofx0a:					lda #$00	// Table Start Position.
						ldx #$7b	// Bitmap Toggle Code.
						ldy #$20	
						sta tab_pos
						stx tog_byt
						sty fxbyte0
						jmp pause-5
						//------------------------------------------------------------------
dofx1:					lda #200	// Table Start Position.
						ldx #$3b	// Bitmap Toggle Code.
						ldy #$20	
						sta tab_pos
						stx tog_byt
						sty fxbyte1
						jmp pause-5
						//------------------------------------------------------------------
dofx1a:					lda #200	// Table Start Position.
						ldx #$7b	// Bitmap Toggle Code.
						ldy #$20	
						sta tab_pos
						stx tog_byt
						sty fxbyte1
						jmp pause-5
						//------------------------------------------------------------------
dofx2:					lda #$00	// Table Start Position.
						ldx #$3b	// Bitmap Toggle Code.
						ldy #$20	
						sta tab_pos
						stx tog_byt
						sty fxbyte2
						jmp pause-5
						//------------------------------------------------------------------
dofx2a:					lda #$00	// Table Start Position.
						ldx #$7b	// Bitmap Toggle Code.
						ldy #$20	
						sta tab_pos
						stx tog_byt
						sty fxbyte2
						jmp pause-5
						//------------------------------------------------------------------
dofx3:					lda #$00	// Table Start Position.
						ldx #$3b	// Bitmap Toggle Code.
						ldy #$20	
						sta tab_pos
						stx tog_byt
						sty fxbyte3
						jmp pause-5
						//------------------------------------------------------------------
dofx3a:					lda #$00	// Table Start Position.
						ldx #$7b	// Bitmap Toggle Code.
						ldy #$20	
						sta tab_pos
						stx tog_byt
						sty fxbyte3
						jmp pause-5
						//------------------------------------------------------------------
dofx4:					lda #$00	// Table Start Position.
						ldx #$3b	// Bitmap Toggle Code.
						ldy #$20	
						sta tab_pos
						stx tog_byt
						sty fxbyte4
						jmp pause-5
						//------------------------------------------------------------------
dofx4a:					lda #$00	// Table Start Position.
						ldx #$7b	// Bitmap Toggle Code.
						ldy #$20	
						sta tab_pos
						stx tog_byt
						sty fxbyte4
						jmp pause-5
						//------------------------------------------------------------------
dofx5:					lda #$00	// Table Start Position.
						ldx #$3b	// Bitmap Toggle Code.
						ldy #$20	
						sta tab_pos
						stx tog_byt
						sty fxbyte5
						jmp pause-5
						//------------------------------------------------------------------
dofx5a:					lda #$00	// Table Start Position.
						ldx #$7b	// Bitmap Toggle Code.
						ldy #$20	
						sta tab_pos
						stx tog_byt
						sty fxbyte5
						jmp pause-5
						//------------------------------------------------------------------
tab_pos:				.byte	$00 // Table Position Counter.
tog_byt:				.byte	$00 // Table Byte Position.
bank_no:				.byte	$02
b_color:				.byte	$00
						//------------------------------------------------------------------
						// fx0:draw bitmap from top of screen to botton, 1 pixel line at a
						// time. 
						//------------------------------------------------------------------
fx0_on:					ldy tab_pos
						cpy #200
						bne fx0_on1
						lda #$ad
						sta fxbyte0
						rts
fx0_on1:				lda tog_byt
						Bitmap()
						jmp add_one
						//------------------------------------------------------------------
						// fx1:draw bitmap from bottom of screen to top, 1 pixel line at a
						// time. 
						//------------------------------------------------------------------
fx1_on:					ldy tab_pos
						bne fx1_on1
						lda #$ad
						sta fxbyte1
						rts
fx1_on1:				lda tog_byt
						Bitmap()
						jmp sub_one
						//------------------------------------------------------------------
						// fx2:The Classic `LINES` Effect.
						//------------------------------------------------------------------
fx2_on:					ldy tab_pos
						cpy #200
						bne fx2_on1
						lda #$ad
						sta fxbyte2
						rts
fx2_on1:				tya
						lsr
						bcc fx2_on2
						lda #200
						sec
						sbc tab_pos
						tay
fx2_on2:				lda tog_byt
						Bitmap()
						jmp add_one
						//------------------------------------------------------------------
						// fx3:Top & Bottom of The Screen to the MIDDLE.
						//------------------------------------------------------------------
fx3_on:					ldy tab_pos
						cpy #101
						bne fx3_on1
						lda #$ad
						sta fxbyte3
						rts
fx3_on1:				lda tog_byt
						Bitmap()
						lda #200
						sec
						sbc tab_pos
						tay
						lda tog_byt
						Bitmap()
						jmp add_one
						//--------------------------------------------------------------------
						// fx4:Every 8th line (Downwards)
						//--------------------------------------------------------------------
fx4_on:					lda tab_pos
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
fx4_on1:				sta tab_pos
						tay
						lda tog_byt
						Bitmap()
						rts
						//------------------------------------------------------------------
						// fx5:Top & Bottom of The Screen to the MIDDLE.
						//------------------------------------------------------------------
fx5_on:					ldy tab_pos
						cpy #51
						bne fx5_on1
						lda #$ad
						sta fxbyte5
						rts
fx5_on1:				lda tog_byt
						Bitmap()
						lda #100
						clc
						adc tab_pos
						tay
						lda tog_byt
						Bitmap()
						lda #100
						sec
						sbc tab_pos
						tay
						lda tog_byt
						Bitmap()
						lda #200
						sec
						sbc tab_pos
						tay
						lda tog_byt
						Bitmap()
						jmp add_one
						//------------------------------------------------------------------

						//------------------------------------------------------------------
bitmap_mover:			lda #$36
						sta $01
						ldx #$00

						// Move $9000 to $2000.

bitmap_mover2:			lda $9000,x
						sta $2000,x
						lda $9100,x
						sta $2100,x
						lda $9200,x
						sta $2200,x
						lda $9300,x
						sta $2300,x
						lda $9400,x
						sta $2400,x
						lda $9500,x
						sta $2500,x
						lda $9600,x
						sta $2600,x
						lda $9700,x
						sta $2700,x
						lda $9800,x
						sta $2800,x
						lda $9900,x
						sta $2900,x
						lda $9a00,x
						sta $2a00,x
						lda $9b00,x
						sta $2b00,x
						lda $9c00,x
						sta $2c00,x
						lda $9d00,x
						sta $2d00,x
						lda $9e00,x
						sta $2e00,x
						lda $9f00,x
						sta $2f00,x

						// Move $a000 to $3000.

						lda $a000,x
						sta $3000,x
						lda $a100,x
						sta $3100,x
						lda $a200,x
						sta $3200,x
						lda $a300,x
						sta $3300,x
						lda $a400,x
						sta $3400,x
						lda $a500,x
						sta $3500,x
						lda $a600,x
						sta $3600,x
						lda $a700,x
						sta $3700,x
						lda $a800,x
						sta $3800,x
						lda $a900,x
						sta $3900,x
						lda $aa00,x
						sta $3a00,x
						lda $ab00,x
						sta $3b00,x
						lda $ac00,x
						sta $3c00,x
						lda $ad00,x
						sta $3d00,x
						lda $ae00,x
						sta $3e00,x
						lda $af00,x
						sta $3f00,x

						// Move $b000 to $0400.

						lda $b000,x
						sta $0400,x
						lda $b100,x
						sta $0500,x
						lda $b200,x
						sta $0600,x
						lda $b300,x
						sta $0700,x

						// Move $b400 to $d800.

						lda $b400,x
						sta $d800,x
						lda $b500,x
						sta $d900,x
						lda $b600,x
						sta $da00,x
						lda $b700,x
						sta $db00,x

						inx
						cpx #$00
						beq bitmap_mover3
						jmp bitmap_mover2
bitmap_mover3:			lda #$36
						sta $01
						rts
						//------------------------------------------------------------------

						//------------------------------------------------------------------
fli_mover:				lda #$36
						sta $01
						ldx #$00
						
						// Move $9000 to $0400.
						
fli_mover2:				lda $9100,x
						sta $d800,x
						lda $9200,x
						sta $d900,x
						lda $9300,x
						sta $da00,x
						lda $9400,x
						sta $db00,x

						// Move $9500 to $4000

						lda $9500,x
						sta $4000,x
						lda $9600,x
						sta $4100,x
						lda $9700,x
						sta $4200,x
						lda $9800,x
						sta $4300,x
						lda $9900,x
						sta $4400,x
						lda $9a00,x
						sta $4500,x
						lda $9b00,x
						sta $4600,x
						lda $9c00,x
						sta $4700,x
						lda $9d00,x
						sta $4800,x
						lda $9e00,x
						sta $4900,x
						lda $9f00,x
						sta $4a00,x
						lda $a000,x
						sta $4b00,x
						lda $a100,x
						sta $4c00,x
						lda $a200,x
						sta $4d00,x
						lda $a300,x
						sta $4e00,x
						lda $a400,x
						sta $4f00,x

						// Move $a500 to $5000

						lda $a500,x
						sta $5000,x
						lda $a600,x
						sta $5100,x
						lda $a700,x
						sta $5200,x
						lda $a800,x
						sta $5300,x
						lda $a900,x
						sta $5400,x
						lda $aa00,x
						sta $5500,x
						lda $ab00,x
						sta $5600,x
						lda $ac00,x
						sta $5700,x
						lda $ad00,x
						sta $5800,x
						lda $ae00,x
						sta $5900,x
						lda $af00,x
						sta $5a00,x
						lda $b000,x
						sta $5b00,x
						lda $b100,x
						sta $5c00,x
						lda $b200,x
						sta $5d00,x
						lda $b300,x
						sta $5e00,x
						lda $b400,x
						sta $5f00,x

						// Move $b500 to $6000

						lda $b500,x
						sta $6000,x
						lda $b600,x
						sta $6100,x
						lda $b700,x
						sta $6200,x
						lda $b800,x
						sta $6300,x
						lda $b900,x
						sta $6400,x
						lda $ba00,x
						sta $6500,x
						lda $bb00,x
						sta $6600,x
						lda $bc00,x
						sta $6700,x
						lda $bd00,x
						sta $6800,x
						lda $be00,x
						sta $6900,x
						lda $bf00,x
						sta $6a00,x
						lda $c000,x
						sta $6b00,x
						lda $c100,x
						sta $6c00,x
						lda $c200,x
						sta $6d00,x
						lda $c300,x
						sta $6e00,x
						lda $c400,x
						sta $6f00,x

						// Move $c500 to $7000

						lda $c500,x
						sta $7000,x
						lda $c600,x
						sta $7100,x
						lda $c700,x
						sta $7200,x
						lda $c800,x
						sta $7300,x
						lda $c900,x
						sta $7400,x
						lda $ca00,x
						sta $7500,x
						lda $cb00,x
						sta $7600,x
						lda $cc00,x
						sta $7700,x
						lda $cd00,x
						sta $7800,x
						lda $ce00,x
						sta $7900,x
						lda $cf00,x
						sta $7a00,x
						inx
						beq fli_mover3
						jmp fli_mover2
fli_mover3:				sei
						ldx #$00
fli_mover4:				lda #$34
						sta $01
						lda $d000,x
						sta $7b00,x
						lda $d100,x
						sta $7c00,x
						lda $d200,x
						sta $7d00,x
						lda $d300,x
						sta $7e00,x
						lda $d400,x
						sta $7f00,x
						lda #$37
						sta $01
						inx
						bne fli_mover4
						cli
						lda #$36
						sta $01
						rts
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

						.align $200
						.memblock "d011 table"

bitmap_table:
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

//	fli_tabd011	= $8b00
.byte	$7b,$7c,$7d,$7e,$7f,$78,$79,$7a,$7b,$7c,$7d,$7e,$7f,$78,$79,$7a
.byte	$7b,$7c,$7d,$7e,$7f,$78,$79,$7a,$7b,$7c,$7d,$7e,$7f,$78,$79,$7a
.byte	$7b,$7c,$7d,$7e,$7f,$78,$79,$7a,$7b,$7c,$7d,$7e,$7f,$78,$79,$7a
.byte	$7b,$7c,$7d,$7e,$7f,$78,$79,$7a,$7b,$7c,$7d,$7e,$7f,$78,$79,$7a
.byte	$7b,$7c,$7d,$7e,$7f,$78,$79,$7a,$7b,$7c,$7d,$7e,$7f,$78,$79,$7a
.byte	$7b,$7c,$7d,$7e,$7f,$78,$79,$7a,$7b,$7c,$7d,$7e,$7f,$78,$79,$7a
.byte	$7b,$7c,$7d,$7e,$7f,$78,$79,$7a,$7b,$7c,$7d,$7e,$7f,$78,$79,$7a
.byte	$7b,$7c,$7d,$7e,$7f,$78,$79,$7a,$7b,$7c,$7d,$7e,$7f,$78,$79,$7a
.byte	$7b,$7c,$7d,$7e,$7f,$78,$79,$7a,$7b,$7c,$7d,$7e,$7f,$78,$79,$7a
.byte	$7b,$7c,$7d,$7e,$7f,$78,$79,$7a,$7b,$7c,$7d,$7e,$7f,$78,$79,$7a
.byte	$7b,$7c,$7d,$7e,$7f,$78,$79,$7a,$7b,$7c,$7d,$7e,$7f,$78,$79,$7a
.byte	$7b,$7c,$7d,$7e,$7f,$78,$79,$7a,$7b,$7c,$7d,$7e,$7f,$78,$79,$7a
.byte	$7b,$7c,$7d,$7e,$7f,$78,$79,$7a,$7b,$7c,$7d,$7e,$7f,$78,$79,$7a
.byte	$7b,$7c,$7d,$7e,$7f,$78,$79,$7a,$7b,$7c,$7d,$7e,$7f,$78,$79,$7a
.byte	$7b,$7c,$7d,$7e,$7f,$78,$79,$7a,$7b,$7c,$7d,$7e,$7f,$78,$79,$7a
.byte	$7b,$7c,$7d,$7e,$7f,$78,$79,$7a,$7b,$7c,$7d,$7e,$7f,$78,$79,$7a


//	fli_tabd018	= $8c00
.byte 	$18,$28,$38,$48,$58,$68,$78,$08,$18,$28,$38,48,$58,$68,$78,$08
.byte 	$18,$28,$38,$48,$58,$68,$78,$08,$18,$28,$38,48,$58,$68,$78,$08
.byte 	$18,$28,$38,$48,$58,$68,$78,$08,$18,$28,$38,48,$58,$68,$78,$08
.byte 	$18,$28,$38,$48,$58,$68,$78,$08,$18,$28,$38,48,$58,$68,$78,$08
.byte 	$18,$28,$38,$48,$58,$68,$78,$08,$18,$28,$38,48,$58,$68,$78,$08
.byte 	$18,$28,$38,$48,$58,$68,$78,$08,$18,$28,$38,48,$58,$68,$78,$08
.byte 	$18,$28,$38,$48,$58,$68,$78,$08,$18,$28,$38,48,$58,$68,$78,$08
.byte 	$18,$28,$38,$48,$58,$68,$78,$08,$18,$28,$38,48,$58,$68,$78,$08
.byte 	$18,$28,$38,$48,$58,$68,$78,$08,$18,$28,$38,48,$58,$68,$78,$08
.byte 	$18,$28,$38,$48,$58,$68,$78,$08,$18,$28,$38,48,$58,$68,$78,$08
.byte 	$18,$28,$38,$48,$58,$68,$78,$08,$18,$28,$38,48,$58,$68,$78,$08
.byte 	$18,$28,$38,$48,$58,$68,$78,$08,$18,$28,$38,48,$58,$68,$78,$08
.byte 	$18,$28,$38,$48,$58,$68,$78,$08,$18,$28,$38,48,$58,$68,$78,$08
.byte 	$18,$28,$38,$48,$58,$68,$78,$08,$18,$28,$38,48,$58,$68,$78,$08
.byte 	$18,$28,$38,$48,$58,$68,$78,$08,$18,$28,$38,48,$58,$68,$78,$08
.byte 	$18,$28,$38,$48,$58,$68,$78,$08,$18,$28,$38,48,$58,$68,$78,$08


						//------------------------------------------------------------------------------
						.macro 	Bitmap() {
										sta bitmap_table,y
										and #$70
										sta bm1+1
										lda fli_tabd011,y
										and #$0f
								bm1:	ora #$00
										sta fli_tabd011,y
						}
						//------------------------------------------------------------------------------
