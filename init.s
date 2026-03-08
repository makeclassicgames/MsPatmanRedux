;*****************************************************************
; Define NES cartridge Header
;*****************************************************************

.include "inc.s"

.segment "HEADER"
INES_MAPPER = 0 ; 0 = NROM
INES_MIRROR = 0 ; 0 = horizontal mirroring, 1 = vertical mirroring
INES_SRAM   = 0 ; 1 = battery backed SRAM at $6000-7FFF

.byte 'N', 'E', 'S', $1A ; ID 
.byte $02 ; 16k PRG bank count
.byte $01 ; 8k CHR bank count
.byte INES_MIRROR | (INES_SRAM << 1) | ((INES_MAPPER & $f) << 4)
.byte (INES_MAPPER & %11110000)
.byte $0, $0, $0, $0, $0, $0, $0, $0 ; padding

;*****************************************************************
; Import both the background and sprite character sets
;*****************************************************************

.segment "TILES"
.incbin "chr/patafondos.chr"

;*****************************************************************
; Define NES interrupt vectors
;*****************************************************************

.segment "VECTORS"
.word nmi
.word reset
.word irq

;*****************************************************************
; 6502 Zero Page Memory (256 bytes)
;*****************************************************************

.segment "ZEROPAGE"

nmi_ready:		.res 1 ; set to 1 to push a PPU frame update, 
					   ;        2 to turn rendering off next NMI
gamepad:		.res 1 ; stores the current gamepad values

d_x:			.res 1 ; x velocity of ball
d_y:			.res 1 ; y velocity of ball
sprite_index:	.res 1 ; current sprite index for animation
duck_x:			.res 1 ; duck sprite X
duck_y:			.res 1 ; duck sprite Y
current_state:	.res 1 ; current state of the game (title, playing, gameover)
scene_loaded:		.res 1 ; flag to indicate if the scene has been loaded (for animation purposes)
frame_count:		.res 1 ; frame counter for animation timing
curent_anim_frame:	.res 1 ; current animation frame for duck sprite
is_jumping:		.res 1 ; flag to indicate if the duck is currently jumping
jump_pressed:		.res 1 ; flag to indicate if the jump button is currently pressed
a_was_down:		.res 1 ; latch to detect a new A press (edge trigger)
obstacle_x:		.res 1 ; x position of obstacle
obstacle_dx:		.res 1 ; x velocity of obstacle
;*****************************************************************
; Sprite OAM Data area - copied to VRAM in NMI routine
;*****************************************************************

.segment "OAM"
oam: .res 256	; sprite OAM data

;*****************************************************************
; Remainder of normal RAM area
;*****************************************************************

.segment "BSS"
palette: .res 32 ; current palette buffer

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




;*****************************************************************
; Main application entry point for starup/reset
;*****************************************************************

.segment "CODE"
.proc reset
	sei			; mask interrupts
	lda #0
	sta PPU_CONTROL	; disable NMI
	sta PPU_MASK	; disable rendering
	sta APU_DM_CONTROL	; disable DMC IRQ
	lda #$40
	sta JOYPAD2		; disable APU frame IRQ

	cld			; disable decimal mode
	ldx #$FF
	txs			; initialise stack

	; wait for first vBlank
	bit PPU_STATUS
wait_vblank:
	bit PPU_STATUS
	bpl wait_vblank

	; clear all RAM to 0
	lda #0
	ldx #0
clear_ram:
	sta $0000,x
	sta $0100,x
	sta $0200,x
	sta $0300,x
	sta $0400,x
	sta $0500,x
	sta $0600,x
	sta $0700,x
	inx
	bne clear_ram

	; place all sprites offscreen at Y=255
	lda #255
	ldx #0
clear_oam:
	sta oam,x
	inx
	inx
	inx
	inx
	bne clear_oam

; wait for second vBlank
wait_vblank2:
	bit PPU_STATUS
	bpl wait_vblank2
	
	; NES is initialized and ready to begin
	; - enable the NMI for graphical updates and jump to our main program
	lda #%10001000
	sta PPU_CONTROL
	jmp main
.endproc

;*****************************************************************
; NMI Routine - called every vBlank
;*****************************************************************

.segment "CODE"
.proc nmi
	; save registers
	pha
	txa
	pha
	tya
	pha

	lda nmi_ready
	bne :+ ; nmi_ready == 0 not ready to update PPU
		jmp ppu_update_end
	:
	cmp #2 ; nmi_ready == 2 turns rendering off
	bne cont_render
		lda #%00000000
		sta PPU_MASK
		ldx #0
		stx nmi_ready
		jmp ppu_update_end
cont_render:

	; transfer sprite OAM data using DMA
	ldx #0
	stx PPU_SPRRAM_ADDRESS
	lda #>oam
	sta SPRITE_DMA

	; transfer current palette to PPU
	lda #%10001000 ; set horizontal nametable increment
	sta PPU_CONTROL 
	lda PPU_STATUS
	lda #$3F ; set PPU address to $3F00
	sta PPU_VRAM_ADDRESS2
	stx PPU_VRAM_ADDRESS2
	ldx #0 ; transfer the 32 bytes to VRAM
loop:
	lda palette, x
	sta PPU_VRAM_IO
	inx
	cpx #32
	bcc loop

	; enable rendering
	lda #%00011110
	sta PPU_MASK
	; flag PPU update complete
	ldx #0
	stx nmi_ready
ppu_update_end:

	; restore registers and return
	pla
	tay
	pla
	tax
	pla
	rti
.endproc

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

.proc draw_obstacle
	lda #GROUND_Y
	ldx #16
	sta oam,x
	inx
	lda #$02
	sta oam,x
	inx
	lda #%00000001 ; Sprite Attributes
	sta oam,x
	inx
	lda obstacle_x
	sta oam,x
.endproc

; update Physics for duck sprite - apply velocity to position
.proc update_physics
	lda duck_y
	clc
	adc d_y
	sta duck_y

	; clamp to ground and clear jump state when landing
	lda duck_y
	cmp #GROUND_Y
	bcc apply_gravity
	lda #GROUND_Y
	sta duck_y
	lda #0
	sta d_y
	sta is_jumping
	jmp update_obstacle

apply_gravity:
	; apply gravity in-air and clamp to max fall speed
	lda d_y
	bmi gravity_step
	cmp #MAX_FALL_SPEED
	bcs update_obstacle
gravity_step:
	clc
	adc #GRAVITY
	bmi store_dy
	cmp #MAX_FALL_SPEED
	bcc store_dy
	lda #MAX_FALL_SPEED
store_dy:
	sta d_y

update_obstacle:
	lda obstacle_x
	cmp obstacle_dx
	bcc reset_obstacle
	sec
	sbc obstacle_dx
	sta obstacle_x
	rts
reset_obstacle:
	lda #255
	sta obstacle_x 
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

.proc jump_duck
	lda jump_pressed
	cmp #0
	beq end_jump
	lda is_jumping
	cmp #0
	bne end_jump
	lda #1
	sta is_jumping
	; signed upward impulse (negative velocity)
	lda #($100 - JUMP_VELOCITY)
	sta d_y
	lda #0
	sta jump_pressed
end_jump:
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

;*****************************************************************
; IRQ Clock Interrupt Routine
;*****************************************************************

.segment "CODE"
irq:
	rti

