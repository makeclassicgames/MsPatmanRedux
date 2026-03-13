;************************************************************************************
; PHysics Functions
;************************************************************************************

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

.proc check_collisions
	; check for collision between duck and obstacle
	lda duck_y
	cmp duck_x
	bcc no_collision
	lda duck_x
	cmp obstacle_x
	bcc no_collision
	lda duck_y
	cmp #GROUND_Y
	bcc no_collision
	lda duck_y
	cmp #GROUND_Y + 16 ; 16 is the height of the duck sprite
	bcs no_collision

	; collision detected - set game state to GAMEOVER
	lda #GAMEOVER
	sta current_state
	lda #0
	sta scene_loaded
	lda #0
	sta scroll_x
no_collision:
	rts
.endproc