; CH05 - Programming Games for NES
; Base NES game shell demo

;*****************************************************************
; Define NES control register values
;*****************************************************************

.include "constants.s"

.include "header.s"
.include "variables.s"

.include "interrupt.s"

.include "graphics.s"

.include "physics.s"

.include "input.s"


;*****************************************************************
; Main application logic section includes the game loop
;*****************************************************************
 .segment "CODE"
 .proc main
	lda #0
	sta frame_count
	; main application - rendering is currently off
	lda #0
	sta is_jumping
	lda #0
	sta jump_pressed
	lda #0
	sta a_was_down
	lda #TITLE
	sta current_state
	lda #0
	sta scene_loaded
	lda #0
	sta d_y
	lda #GROUND_Y
	sta duck_y ; set duck Y position
	lda #8
	sta duck_x ; set duck X position
	lda #1
	sta obstacle_dx
	lda #240
	sta obstacle_x ; set obstacle X position
	; initialize palette table
	ldx #0
paletteloop:
	lda default_palette, x
	sta palette, x
	inx
	cpx #32
	bcc paletteloop

	; clear 1st name table
	jsr clear_nametable
	jsr load_scene

	; get the screen to render
	jsr ppu_update

mainloop:
	; wait until the previous frame upload finishes
	lda nmi_ready
	bne mainloop

	; read controls once per rendered frame
	jsr gamepad_poll
	lda gamepad
	and #PAD_START
	beq not_gamepad_start
		ldx current_state
		cpx #TITLE
		bne not_gamepad_start
		lda #0
		sta scene_loaded
		lda #PLAYING
		sta current_state
not_gamepad_start:
	lda gamepad
	and #PAD_A
	beq a_released
		lda a_was_down
		bne a_done
		lda #1
		sta jump_pressed
		lda #1
		sta a_was_down
		jmp a_done
a_released:
	lda #0
	sta a_was_down
a_done:

	jsr load_scene
	jsr jump_duck
	jsr update_physics
	jsr draw_obstacle
	jsr draw_animation_duck

	; request NMI upload for this frame
	lda #1
	sta nmi_ready
	jmp mainloop
.endproc


.segment "CODE"
.proc load_scene
	lda scene_loaded
	cmp #1
	bne not_loaded
	rts
not_loaded:
	jsr ppu_off
	ldx current_state
	CPX #TITLE
	BNE NOT_TITLE
	; load title screen
	draw_background background_tiles_B
	JMP end_load_scene
NOT_TITLE:
	; load game screen
	draw_background background_tiles_A
end_load_scene:	
	lda #1
	sta scene_loaded
	rts
.endproc
 