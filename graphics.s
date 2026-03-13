;*****************************************************************
; Import both the background and sprite character sets
;*****************************************************************

.segment "TILES"
.incbin "chr/patafondos.chr"


;*****************************************************************
; Some useful functions
;*****************************************************************

.segment "CODE"
; ppu_update: waits until next NMI, turns rendering on (if not already), uploads OAM, palette, and nametable update to PPU
.proc ppu_update
	lda #1
	sta nmi_ready
	loop:
		lda nmi_ready
		bne loop
	rts
.endproc

; ppu_off: waits until next NMI, turns rendering off (now safe to write PPU directly via PPU_VRAM_IO)
.proc ppu_off
	lda #2
	sta nmi_ready
	loop:
		lda nmi_ready
		bne loop
	rts
.endproc

.segment "CODE"
.proc clear_nametable
 	lda PPU_STATUS ; reset address latch
 	lda #$20 ; set PPU address to $2000
 	sta PPU_VRAM_ADDRESS2
 	lda #$00
 	sta PPU_VRAM_ADDRESS2

 	; empty nametable
 	lda #0
 	ldy #30 ; clear 30 rows
 	rowloop:
 		ldx #32 ; 32 columns
 		columnloop:
 			sta PPU_VRAM_IO
 			dex
 			bne columnloop
 		dey
 		bne rowloop

 	; empty attribute table
 	ldx #64 ; attribute table is 64 bytes
 	loop:
 		sta PPU_VRAM_IO
 		dex
 		bne loop
 	rts
 .endproc

;********************************************************************************************************
;draw_animation_duck: draws duck animation
;********************************************************************************************************

.segment "CODE"
.proc draw_animation_duck
	inc frame_count
	lda frame_count
	cmp #10 ; change animation frame every 10 frames
	bne end_anim
	lda #0
	sta frame_count
	inc curent_anim_frame
	lda curent_anim_frame
	cmp #2
	bne end_anim
	lda #0
	sta curent_anim_frame
	end_anim:
	lda curent_anim_frame
	bne draw_anim_2
	jsr draw_duck_anim_1
	jmp end_draw
draw_anim_2:
	jsr draw_duck_anim_2
end_draw:
	rts
.endproc

.proc draw_duck_anim_1
	ldx #0
	ldy #0
	lda duck_y ; load Y Coordinate
	sta oam,x 
	inx
	lda duck_tiles,y ; load Tile Index
	sta oam,x
	inx
	lda #%00000001 ; Sprite Attributes
	sta oam,x
	inx
	lda duck_x ; load X Coordinate
	sta oam,x
	inx
	; second Sprite
	iny
	lda duck_y ; load Y Coordinate
	sta oam,x
	inx
	lda duck_tiles,y ; load Tile Index
	sta oam,x
	inx	
	lda #%00000001 ; Sprite Attributes
	sta oam,x
	inx
	lda duck_x
	clc
	adc #8 ; load X Coordinate
	sta oam,x
	inx
	iny
	lda duck_y ; load Y Coordinate
	clc
	adc #8
	sta oam,x
	inx
	lda duck_tiles,y ; load Tile Index
	sta oam,x
	inx
	lda #%00000001 ; Sprite Attributes
	sta oam,x
	inx
	lda duck_x ; load X Coordinate
	sta oam,x
	inx
	iny
	lda duck_y ; load Y Coordinate
	clc
	adc #8
	sta oam,x
	inx
	lda duck_tiles,y
	sta oam,x
	inx
	lda #%00000001 ; Sprite Attributes
	sta oam,x
	inx
	lda duck_x
	clc
	adc #8 ; load X Coordinate
	sta oam,x
	rts
.endproc 

.proc draw_duck_anim_2
	ldx #0
	ldy #0
	lda duck_y ; load Y Coordinate
	sta oam,x 
	inx
	lda duck_tiles_2,y ; load Tile Index
	sta oam,x
	inx
	lda #%00000001 ; Sprite Attributes
	sta oam,x
	inx
	lda duck_x ; load X Coordinate
	sta oam,x
	inx
	; second Sprite
	iny
	lda duck_y ; load Y Coordinate
	sta oam,x
	inx
	lda duck_tiles_2,y ; load Tile Index
	sta oam,x
	inx	
	lda #%00000001 ; Sprite Attributes
	sta oam,x
	inx
	lda duck_x
	clc
	adc #8 ; load X Coordinate
	sta oam,x
	inx
	iny
	lda duck_y ; load Y Coordinate
	clc
	adc #8
	sta oam,x
	inx
	lda duck_tiles_2,y ; load Tile Index
	sta oam,x
	inx
	lda #%00000001 ; Sprite Attributes
	sta oam,x
	inx
	lda duck_x ; load X Coordinate
	sta oam,x
	inx
	iny
	lda duck_y ; load Y Coordinate
	clc
	adc #8
	sta oam,x
	inx
	lda duck_tiles_2,y
	sta oam,x
	inx
	lda #%00000001 ; Sprite Attributes
	sta oam,x
	inx
	lda duck_x
	clc
	adc #8 ; load X Coordinate
	sta oam,x
	rts
.endproc 

.segment "CODE"
; Draw obstacle sprite at current position
.proc draw_obstacle
	ldx #16
	;first sprite
	lda #GROUND_Y
	sta oam,x
	inx
	lda #$04
	sta oam,x
	inx
	lda #%00000010 ; Sprite Attributes
	sta oam,x
	inx
	lda obstacle_x
	sta oam,x
	inx
	; second sprite
	lda #GROUND_Y+8
	sta oam,x
	inx
	lda #$14
	sta oam,x
	inx
	lda #%00000010 ; Sprite Attributes
	sta oam,x
	inx
	lda obstacle_x
	sta oam,x
	inx
	; third sprite
	lda #GROUND_Y
	sta oam,x
	inx
	lda #$05
	sta oam,x
	inx
	lda #%00000010 ; Sprite Attributes
	sta oam,x
	inx
	lda obstacle_x
	clc
	adc #8
	sta oam,x
	inx
	; fourth sprite
	lda #GROUND_Y+8
	sta oam,x
	inx
	lda #$15
	sta oam,x
	inx
	lda #%00000010 ; Sprite Attributes
	sta oam,x
	inx
	lda obstacle_x
	clc
	adc #8
	sta oam,x
.endproc

.segment "CODE"
.proc disable_sprites
	ldx #0
loop:
	lda #0
	sta oam,x
	inx
	sta oam,x
	inx
	sta oam,x
	inx
	sta oam,x
	inx
	bne loop
	rts
.endproc

.macro draw_background background_address
 ; draw background from array
 	lda PPU_STATUS ; reset address latch
 	lda #$20 ; set PPU address to $2000
 	sta PPU_VRAM_ADDRESS2
 	lda #$00
 	sta PPU_VRAM_ADDRESS2
 	
 	; write first 256 bytes
 	ldx #0
:	lda background_address, x
 	sta PPU_VRAM_IO
 	inx
 	bne :-
 	; write second 256 bytes
 	ldx #0
:	lda background_address +256, x
 	sta PPU_VRAM_IO
 	inx
 	bne :-
 	; write third 256 bytes
 	ldx #0
:	lda background_address +512, x
 	sta PPU_VRAM_IO
 	inx
 	bne :-
 	; write remaining 192 bytes (768-959)
 	ldx #0
:	lda background_address +768, x
 	sta PPU_VRAM_IO
 	inx
 	cpx #192
 	bne :-

	; reset scroll position
	lda PPU_STATUS
	lda #0
	sta PPU_VRAM_ADDRESS1
	sta PPU_VRAM_ADDRESS1
.endmacro

;******************************************************************
; Graphics DATA (ROM)
;******************************************************************

.segment "RODATA"
; Duck tiles for animation (4 tiles, 2 frames)
duck_tiles:
.byte $10,$11,$20,$21

duck_tiles_2:
; Duck tiles for animation 2(4 tiles, 2 frames)
.byte $12,$13,$22,$23

; Palette Data

.segment "RODATA"
default_palette:
.byte $0f,$19,$00,$2c
.byte $0f,$0c,$21,$32
.byte $0f,$24,$26,$38
.byte $0f,$0b,$1a,$29
.byte $0f,$0c,$21,$32 ; sp0 yellow
.byte $0f,$24,$26,$38 ; sp1 purple
.byte $0f,$1a,$16,$14 ; sp2 teal
.byte $0f,$12,$22,$32 ; sp3 marine


;; Background Tiles for Drawing

; Full screen background (960 bytes = 30 rows * 32 columns)
.segment "RODATA"
background_tiles_A:
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$62,$63,$64,$65,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$72,$73,$74,$75,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$82,$83,$84,$85,$50,$51,$52,$53,$54,$55,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$70,$71,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$80,$81,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$56,$57,$58,$59,$5a,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$66,$67,$68,$69,$6a,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e

background_tiles_B:
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$06,$00,$00,$00,$00,$07,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$08,$09,$00,$00,$00,$0a,$0b,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0c,$02,$0d,$0e,$00,$00,$0f,$02,$10,$00,$00,$00,$00
	.byte $00,$11,$03,$00,$00,$00,$00,$12,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$13,$14,$15,$16,$17,$18,$19,$1a,$00,$00,$03,$00
	.byte $00,$1b,$1c,$00,$00,$00,$1d,$1e,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$02,$02,$02,$02,$02,$02,$1f,$00,$00,$20,$21,$00
	.byte $22,$23,$24,$25,$00,$00,$26,$27,$28,$00,$00,$00,$00,$00,$00,$00,$00,$29,$2a,$2b,$2c,$2d,$2e,$02,$02,$02,$2f,$30,$00,$31,$32,$00
	.byte $01,$01,$01,$01,$33,$34,$35,$36,$37,$38,$00,$00,$00,$00,$39,$3a,$3b,$01,$01,$01,$01,$01,$01,$3c,$3d,$3e,$3f,$40,$00,$41,$42,$43
	.byte $01,$01,$01,$01,$01,$01,$01,$44,$45,$46,$04,$04,$47,$48,$49,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$4a,$4b,$4c,$4d,$01,$01
	.byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
	.byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
	.byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
	.byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
	.byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
	.byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
	.byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
	.byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01


game_over_tiles:
		.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$a0,$a1,$a2,$a3,$a4,$a5,$a6,$a7,$a8,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$76,$77,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$86,$87,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$66,$4e,$4e,$4e,$6a,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e
